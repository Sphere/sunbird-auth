package org.sunbird.keycloak.login;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.Response;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpResponse;
import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.authenticators.browser.AbstractUsernameFormAuthenticator;
import org.keycloak.credential.CredentialModel;
import org.keycloak.events.Details;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.AuthenticatorConfigModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.ModelDuplicateException;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserCredentialModel;
import org.keycloak.models.UserModel;
import org.keycloak.services.ServicesLogger;
import org.keycloak.services.messages.Messages;
import org.sunbird.keycloak.resetcredential.sms.KeycloakSmsAuthenticatorConstants;
import org.sunbird.keycloak.resetcredential.sms.KeycloakSmsAuthenticatorUtil;
import org.sunbird.keycloak.utils.Constants;
import org.sunbird.keycloak.utils.HttpClient;
import org.sunbird.keycloak.utils.SunbirdModelUtils;

import com.amazonaws.util.CollectionUtils;

public class PasswordAndOtpAuthenticator extends AbstractUsernameFormAuthenticator {

	Logger logger = Logger.getLogger(PasswordAndOtpAuthenticator.class);

	private enum CODE_STATUS {
		VALID, INVALID, EXPIRED
	}

	/**
	 * This page is called when UI calls
	 * "/realms/sunbird/protocol/openid-connect/auth" API.
	 */
	@Override
	public void authenticate(AuthenticationFlowContext context) {
		String flagPage = getValue(context, Constants.FLAG_PAGE);
		logger.info("OtpSmsFormAuthenticator::authenticate:: " + flagPage);
		goPage(context, Constants.LOGIN_PAGE);
	}

	@Override
	public boolean requiresUser() {
		return false;
	}

	@Override
	public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
		return true;
	}

	@Override
	public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
	}

	/**
	 * This method is called when UI calls
	 * "/realms/sunbird/login-actions/authenticate" API
	 */
	@Override
	public void action(AuthenticationFlowContext context) {
		logger.info("OtpSmsFormAuthenticator::action... ");
		MultivaluedMap<String, String> qParamMap = context.getHttpRequest().getUri().getQueryParameters(false);
		Iterator<Entry<String, List<String>>> itr = qParamMap.entrySet().iterator();
		while (itr.hasNext()) {
			Entry<String, List<String>> entry = itr.next();
			logger.info(String.format("		query: key: %s, value: %s", entry.getKey(), entry.getValue()));
		}

		String flagPage = getValue(context, Constants.FLAG_PAGE);
		logger.info("OtpSmsFormAuthenticator::action:: " + flagPage);
		switch (flagPage) {
		case Constants.FLAG_OTP_PAGE:
			authenticateOtp(context);
			break;
		case Constants.FLAG_OTP_RESEND_PAGE:
			resendOtp(context);
			break;
		case Constants.FLAG_LOGIN_PAGE:
			sendOtp(context, qParamMap.getFirst(Constants.REDIRECT_URI_KEY));
			break;
		case Constants.FLAG_LOGIN_WITH_PASS:
			if (!validateForm(context, context.getHttpRequest().getDecodedFormParameters())) {
				goErrorPage(context, "Invalid credentials!");
			} else {
				logger.info("Validation of username + password is successful... setting redirect_uri with "
						+ qParamMap.getFirst(Constants.REDIRECT_URI_KEY));
				context.getAuthenticationSession().setAuthNote(Details.REDIRECT_URI,
						qParamMap.getFirst(Constants.REDIRECT_URI_KEY));
				context.success();
			}
			break;
		default:
			authenticate(context);
			break;
		}
	}

	private String getValue(AuthenticationFlowContext context, String key) {
		MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
		String value = formData.getFirst(key);
		if (null == value) {
			value = "";
		}
		return value;
	}

	private void authenticateOtp(AuthenticationFlowContext context) {
		CODE_STATUS status = validateCode(context);
		if (status == CODE_STATUS.VALID) {
			logger.info("Validation of username + password is successful... ");
			context.getAuthenticationSession().removeAuthNote(Constants.SESSION_OTP_CODE);
			context.success();
		} else if (status == CODE_STATUS.EXPIRED) {
			goErrorPage(context, Constants.PAGE_INPUT_OTP, Constants.OTP_EXPIRED);
		} else {
			goErrorPage(context, Constants.PAGE_INPUT_OTP, Constants.INVALID_OTP_ENTERED);
		}
	}

	private void goErrorPage(AuthenticationFlowContext context, String message) {
		Response challenge = context.form().setError(message).createForm(Constants.LOGIN_PAGE);
		context.failureChallenge(AuthenticationFlowError.INTERNAL_ERROR, challenge);
	}

	private void goErrorPage(AuthenticationFlowContext context, String page, String message) {
		Response challenge = context.form().setError(message).createForm(page);
		context.failureChallenge(AuthenticationFlowError.INVALID_CREDENTIALS, challenge);
	}

	private void goPage(AuthenticationFlowContext context, String page) {
		context.challenge(context.form().createForm(page));
	}

	private void goPage(AuthenticationFlowContext context, String page, String errorMsg,
			Map<String, String> attributes) {
		LoginFormsProvider resForm = context.form();
		for (Entry<String, String> entry : attributes.entrySet()) {
			resForm.setAttribute(entry.getKey(), entry.getValue());
		}
		if (StringUtils.isNotBlank(errorMsg)) {
			resForm.setError(errorMsg);
		}
		context.challenge(resForm.createForm(page));
	}

	protected boolean validateForm(AuthenticationFlowContext context, MultivaluedMap<String, String> formData) {
		return validateUserAndPassword(context, formData);
	}

	private String getEmailOrMobileNumber(AuthenticationFlowContext context) {
		MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
		String emailOrMobile = formData.getFirst(Constants.ATTR_USER_EMAIL_OR_PHONE);
		if (null == emailOrMobile) {
			return "";
		}
		return emailOrMobile;
	}

	private UserModel getUserByMobileNumber(AuthenticationFlowContext context, String mobilePhone) {
		UserModel user = null;
		try {
			user = SunbirdModelUtils.getUserByNameEmailOrPhone(context, mobilePhone);
		} catch (ModelDuplicateException mde) {
			ServicesLogger.LOGGER.modelDuplicateException(mde);
			// Could happen during federation import
			if (mde.getDuplicateFieldName() != null && mde.getDuplicateFieldName().equals(UserModel.EMAIL)) {
				setDuplicateUserChallenge(context, Errors.EMAIL_IN_USE, Messages.EMAIL_EXISTS,
						AuthenticationFlowError.USER_CONFLICT);
			} else if (mde.getDuplicateFieldName() != null && mde.getDuplicateFieldName().equals(UserModel.USERNAME)) {
				setDuplicateUserChallenge(context, Errors.USERNAME_IN_USE, Messages.USERNAME_EXISTS,
						AuthenticationFlowError.USER_CONFLICT);
			} else if (mde.getDuplicateFieldName() != null
					&& mde.getDuplicateFieldName().equals(KeycloakSmsAuthenticatorConstants.ATTR_MOBILE)) {
				setDuplicateUserChallenge(context, Constants.MULTIPLE_USER_ASSOCIATED_WITH_PHONE,
						Constants.MULTIPLE_USER_ASSOCIATED_WITH_PHONE, AuthenticationFlowError.USER_CONFLICT);
			}

			return null;
		}

		if (invalidUser(context, user)) {
			return null;
		}
		return user;
	}

	private void sendOtp(AuthenticationFlowContext context, String redirectUri) {
		String emailOrMobile = getEmailOrMobileNumber(context);
		UserModel user = getUserByMobileNumber(context, emailOrMobile);
		if (null == user) {
			goErrorPage(context, "Oops, Member not found.");
			return;
		}

		context.setUser(user);

		// Generate Random Digit
		Map<String, String> attributes = generateOTP(context);

		// Put the data into session, to be compared
		context.getAuthenticationSession().setAuthNote(Constants.ATTEMPTED_EMAIL_OR_MOBILE_NUMBER, emailOrMobile);
		context.getAuthenticationSession().setAuthNote(Details.REDIRECT_URI, redirectUri);

		// Send the key into the User Mobile Phone
		logger.error("Send OTP Code [" + attributes.get(Constants.SESSION_OTP_CODE) + "] to Phone Number ["
				+ emailOrMobile + "]");
		if (sendOtpByEmailOrSms(context, emailOrMobile, attributes.get(Constants.SESSION_OTP_CODE))) {
			goPage(context, Constants.PAGE_INPUT_OTP, StringUtils.EMPTY, attributes);
		} else {
			goErrorPage(context, "Failed to send out SMS. Please contact Administrator.");
		}
	}

	private void resendOtp(AuthenticationFlowContext context) {
		String mobileNumber = context.getAuthenticationSession()
				.getAuthNote(Constants.ATTEMPTED_EMAIL_OR_MOBILE_NUMBER);
		// Generate Random Digit
		Map<String, String> attributes = generateOTP(context);

		// Put the data into session, to be compared
		context.getAuthenticationSession().setAuthNote(Constants.SESSION_OTP_CODE,
				attributes.get(Constants.SESSION_OTP_CODE));
		// Send the key into the User Mobile Phone
		logger.error("Send OTP Code [" + attributes.get(Constants.SESSION_OTP_CODE) + "] to Phone Number ["
				+ mobileNumber + "]");
		if (sendOtpByEmailOrSms(context, mobileNumber, attributes.get(Constants.SESSION_OTP_CODE))) {
			goPage(context, Constants.PAGE_INPUT_OTP);
		} else {
			goErrorPage(context, "Failed to send out SMS. Please contact Administrator.");
		}
	}

	private boolean sendOtpByEmailOrSms(AuthenticationFlowContext context, String mobileNumber, String otp) {
		boolean retValue = false;
		String userNameType = isEmailOrMobileNumber(mobileNumber);
		switch (userNameType) {
		case Constants.PHONE:
			AuthenticatorConfigModel configModel = context.getAuthenticatorConfig();
			String smsProvider = null;
			if (configModel.getConfig() != null) {
				smsProvider = configModel.getConfig().get(KeycloakSmsAuthenticatorConstants.CONF_PRP_SMS_PROVIDER);
			}
			if (Constants.MSG91_PROVIDER.equalsIgnoreCase(smsProvider)) {
				retValue = KeycloakSmsAuthenticatorUtil.send(mobileNumber, otp);
			} else if (Constants.Free2SMS_PROVIDER.equalsIgnoreCase(smsProvider)) {
				retValue = sendSmsViaFast2Sms(mobileNumber, otp);
			}
			break;
		case Constants.EMAIL:
			retValue = sendEmailViaSunbird(context, mobileNumber, otp);
			break;
		}
		return retValue;
	}

	private boolean sendSmsViaFast2Sms(String mobileNumber, String otp) {
		List<String> acceptedNumbers = new ArrayList<String>();
		if (StringUtils.isNotBlank(System.getenv(Constants.SMS_OTP_NUMBERS))) {
			acceptedNumbers = Arrays.asList(System.getenv(Constants.SMS_OTP_NUMBERS).split(",", -1));
		}
		if (!acceptedNumbers.contains(mobileNumber)) {
			return false;
		}

		try {
			// Construct data
			StringBuilder strUrl = new StringBuilder(System.getenv(Constants.FAST2SMS_API_URL));
			strUrl.append("?authorization=").append(System.getenv(Constants.FAST2SMS_API_KEY));
			strUrl.append("&route=v3");
			strUrl.append("&sender_id=FTWSMS");
			strUrl.append("&message=Your%20OTP%20login%20into%20iGOT%20System%20is%20:%20" + otp);
			strUrl.append("&language=english&flash=0");
			strUrl.append("&numbers=").append(mobileNumber);

			// Send SMS
			HttpURLConnection conn = (HttpURLConnection) new URL(strUrl.toString()).openConnection();
			conn.setDoOutput(true);
			conn.setRequestMethod("GET");
			final BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			final StringBuffer stringBuffer = new StringBuffer();
			String line;
			while ((line = rd.readLine()) != null) {
				stringBuffer.append(line);
			}
			rd.close();

			logger.info(stringBuffer.toString());
			return true;
		} catch (Exception e) {
			System.out.println("Error SMS " + e);
			logger.error(e);
		}
		return false;
	}

	private Map<String, String> generateOTP(AuthenticationFlowContext context) {
		// The mobile number is configured --> send an SMS
		long nrOfDigits = KeycloakSmsAuthenticatorUtil.getConfigLong(context.getAuthenticatorConfig(),
				KeycloakSmsAuthenticatorConstants.CONF_PRP_SMS_CODE_LENGTH, 6L);

		// Get TTL from config. Default 5 minutes in seconds
		long ttl = KeycloakSmsAuthenticatorUtil.getConfigLong(context.getAuthenticatorConfig(),
				KeycloakSmsAuthenticatorConstants.CONF_PRP_SMS_CODE_TTL, 5 * 60L);

		String code = KeycloakSmsAuthenticatorUtil.getSmsCode(nrOfDigits);

		Long expireTime = (new Date()).getTime() + (ttl * 1000);
		storeSMSCode(context, code, expireTime);
		Map<String, String> attributes = new HashMap<String, String>();
		attributes.put(KeycloakSmsAuthenticatorConstants.CONF_PRP_SMS_CODE_TTL, String.valueOf(expireTime));
		attributes.put(Constants.SESSION_OTP_CODE, code);
		return attributes;
	}

	private boolean sendEmailViaSunbird(AuthenticationFlowContext context, String userEmail, String smsCode) {

		Map<String, Object> otpResponse = new HashMap<String, Object>();

		otpResponse.put(Constants.RECIPIENT_EMAILS, Arrays.asList(userEmail));
		otpResponse.put(Constants.SUBJECT, Constants.MAIL_SUBJECT_LOGIN);
		otpResponse.put(Constants.REALM_NAME, context.getRealm().getDisplayName());
		otpResponse.put(Constants.EMAIL_TEMPLATE_TYPE, System.getenv(Constants.LOGIN_OTP_EMAIL_TEMPLATE));
		otpResponse.put(Constants.BODY, Constants.BODY);
		otpResponse.put(Constants.OTP, smsCode);
		
		long ttl = KeycloakSmsAuthenticatorUtil.getConfigLong(context.getAuthenticatorConfig(),
				KeycloakSmsAuthenticatorConstants.CONF_PRP_SMS_CODE_TTL, 5 * 60L);
		otpResponse.put(Constants.TTL, ttl / 60);

		Map<String, Object> request = new HashMap<>();
		request.put(Constants.REQUEST, otpResponse);

		HttpResponse response = HttpClient.post(request,
				(System.getenv(Constants.SUNBIRD_LMS_BASE_URL) + Constants.SEND_NOTIFICATION_URI),
				System.getenv(Constants.SUNBIRD_LMS_AUTHORIZATION));

		int statusCode = response.getStatusLine().getStatusCode();
		if (statusCode == 200) {
			return true;
		}
		return false;
	}

	private String isEmailOrMobileNumber(String emailOrMobile) {
		String numberRegex = "\\d+";
		String emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
				+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
		if (emailOrMobile.matches(numberRegex) && 10 == emailOrMobile.length()) {
			return Constants.PHONE;
		} else if (emailOrMobile.matches(emailRegex)) {
			return Constants.EMAIL;
		}
		return StringUtils.EMPTY;
	}

	private void storeSMSCode(AuthenticationFlowContext context, String code, Long expiringAt) {
		context.getAuthenticationSession().setAuthNote(Constants.SESSION_OTP_CODE, code);
		context.getAuthenticationSession().setAuthNote(Constants.SESSION_OTP_EXPIRE_TIME, String.valueOf(expiringAt));
	}

	protected CODE_STATUS validateCode(AuthenticationFlowContext context) {
		CODE_STATUS result = CODE_STATUS.INVALID;

		MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
		String enteredCode = formData.getFirst(KeycloakSmsAuthenticatorConstants.ANSW_SMS_CODE);

		String storedCode = context.getAuthenticationSession().getAuthNote(Constants.SESSION_OTP_CODE);
		if (storedCode != null && enteredCode != null) {
			result = storedCode.equalsIgnoreCase(enteredCode) ? CODE_STATUS.VALID : CODE_STATUS.INVALID;
		}

		String storedExpiryValue = context.getAuthenticationSession().getAuthNote(Constants.SESSION_OTP_EXPIRE_TIME);
		if (result == CODE_STATUS.VALID && StringUtils.isNotBlank(storedExpiryValue)) {
			Long currentTime = (new Date()).getTime();
			Long storedExpiryTime = Long.parseLong(storedExpiryValue);
			logger.info(String.format("CurrentTime: %s, StoredExpiryTime: %s", currentTime, storedExpiryTime));
			result = storedExpiryTime >= currentTime ? CODE_STATUS.VALID : CODE_STATUS.EXPIRED;
		}
		return result;
	}

	private void storeSMSCodeInDB(AuthenticationFlowContext context, String code, Long expiringAt) {
		logger.debug("KeycloakSmsAuthenticator@storeSMSCode called");

		UserCredentialModel credentials = new UserCredentialModel();
		credentials.setType(KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_CODE);
		credentials.setValue(code);
		credentials.setNote(Constants.TTL, String.valueOf(expiringAt));

		context.getSession().userCredentialManager().updateCredential(context.getRealm(), context.getUser(),
				credentials);

		credentials = new UserCredentialModel();
		credentials.setType(KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_EXP_TIME);
		credentials.setValue((expiringAt).toString());
		context.getSession().userCredentialManager().updateCredential(context.getRealm(), context.getUser(),
				credentials);
	}

	private CODE_STATUS validateCodeUsingDB(AuthenticationFlowContext context) {
		CODE_STATUS result = CODE_STATUS.INVALID;

		MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
		String enteredCode = formData.getFirst(KeycloakSmsAuthenticatorConstants.ANSW_SMS_CODE);
		KeycloakSession session = context.getSession();

		List<?> codeCreds = session.userCredentialManager().getStoredCredentialsByType(context.getRealm(),
				context.getUser(), KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_CODE);

		if (!CollectionUtils.isNullOrEmpty(codeCreds)) {
			CredentialModel expectedCode = (CredentialModel) codeCreds.get(0);
			result = enteredCode.equals(expectedCode.getValue()) ? CODE_STATUS.VALID : CODE_STATUS.INVALID;
		}

		if (result == CODE_STATUS.VALID) {
			List<?> timeCreds = session.userCredentialManager().getStoredCredentialsByType(context.getRealm(),
					context.getUser(), KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_EXP_TIME);
			if (!CollectionUtils.isNullOrEmpty(timeCreds)) {
				CredentialModel expTimeString = (CredentialModel) timeCreds.get(0);
				Long currentTime = (new Date()).getTime();
				Long expiringAt = Long.parseLong(expTimeString.getValue());

				logger.info(String.format("CurrentTime: %s, ExpiringAt: %s, isExpired ?? %s", currentTime, expiringAt,
						(currentTime >= expiringAt)));
				// result = currentTime <= expiringAt ? CODE_STATUS.VALID : CODE_STATUS.INVALID;
			}
		}

		if (result == CODE_STATUS.VALID) {
			session.userCredentialManager().removeStoredCredential(context.getRealm(), context.getUser(),
					KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_CODE);
			session.userCredentialManager().removeStoredCredential(context.getRealm(), context.getUser(),
					KeycloakSmsAuthenticatorConstants.USR_CRED_MDL_SMS_EXP_TIME);
		}
		return result;
	}
}
