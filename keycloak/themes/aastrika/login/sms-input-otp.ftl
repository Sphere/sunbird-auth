<#import "template.ftl" as layout>
    <@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTitle",realm.displayName)}
    <#elseif section = "form">
    <div class="custom-wrapper">
        <div class="ui raised shadow container segment fullpage-background-image">
            <div class="ui one column grid stackable">
                <div class="ui column height-fix">
                    <img alt="Logo" id="logoRedirect" src="${url.resourcesPath}/img/aastar-logo.svg" width="120">
                    <div class="max-container">
                        <div class="logo">
                            <a id="otp-anchor" href="/public/home">
                            <img alt="Logo" src="${url.resourcesPath}/img/SMS.png" width="100%">
                            </a>
                          </div>
                        <div class="signInHead mt-27">
                            <!-- ${msg("enterCode")} -->
                            Check your Email/SMS for OTP!
                        </div>
                        <div class="ui content textCenter mt-8 mb-28">
                            <#if message?has_content>
                            <div class="ui text ${message.type}">
                                ${message.summary}
                            </div>
                            </#if>
                        </div>
                        <form id="kc-totp-login-form" class="${properties.kcFormClass!} ui form pre-signin" action="${url.loginAction}" method="post">
                            <input type="hidden" name="page_type" value="sms_otp_page" />
                            <div class="field">
                                <input id="totp" name="smsCode" placeholder="Enter OTP" type="text" class=" smsinput" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)"/>
                            </div>
                            <div class="field">
                                <p style="text-align: right !important">OTP Expires in <span class="warnText">10 Minutes</span></p>
                            </div>
                            <div class="field mb-20">
                                <button onclick="otpClick(event,'Submit OTP', 'submit-OTP');javascript:makeDivUnclickable()" class="ui fluid submit button blueButton" name="submit-OTP" id="submit-OTP" type="submit" value="${msg("doLogIn")}">${msg("doSubmit")}</button>
                            </div>
                            <!-- <div class="field or-container">
                                <div class="or-holder">
                                    <span class="or-divider"></span>
                                    <span class="or-text">or</span>
                                </div>
                            </div>
                            <div class="field"></div> -->
                        </form>
                        <form id="kc-totp-login-form" class="${properties.kcFormClass!} ui form pre-signin" action="${url.loginAction}" method="post">
                            <input type="hidden" name="page_type" value="sms_otp_resend_page" />
                            <div class="field">
                                <button onclick="otpClick(event,'Resend OTP', 'resend-OTP');javascript:makeDivUnclickable()" class="ui fluid submit button whiteButton" name="resend-OTP" id="resend-OTP" type="submit" value="${msg("doLogIn")}">${msg("doResendOTP")}</button>
                            </div>
                        </form>
                        <div class="field rel">
                            <span class="whatsApp-otp">
                            <img alt="Logo" src="${url.resourcesPath}/img/whatsapp.png" width="30">
                        </span>
                            <a class="ui fluid button greenButton"                           
                            href="https://wa.me/919632013414?text=Hi"
                            target="_blank" id="WhatsApp-loginOTP" onclick="return otpClick(event,'WhatsApp', 'WhatsApp-loginOTP')">Get Help on WhatsApp?</a>
                        </div>
                        <#if client?? && client.baseUrl?has_content>
                            <div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-45 textCenter">
                                <span>
                                    <a id="backToApplication" onclick="javascript:makeDivUnclickable()" class="backToLogin" href="${client.baseUrl}">
                                        <span class="fs-14"><< </span>${msg("backToApplication")}
                                    </a>
                                </span>
                            </div>
                        </#if>
                    </div>
                </div>
                <div class="ui column tablet only computer only"></div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
          function otpClick(e, param1, param2){
						try {
          e.preventDefault()
          let obj = {
          EventDetails: {
            EventName: param1,
            Name : param2
          }
        }
        const userdata = Object.assign(MainVisitorDetails, obj)
        console.log(userdata)
        // fetch("https://track.plumb5.com/EventDetails/SaveEventDetails", {
        //   method: "POST",
        //   headers: {'Content-Type': 'application/json'},
        //   body: JSON.stringify( userdata)
        // }).then(res => {
          if (document.getElementById("kc-totp-login-form") && (param1 === 'Resend OTP' || param1 === 'Submit OTP')) {
            setTimeout("submitForm()", 500); // set timout
          } else if(param1 === 'WhatsApp'){
						var url = `https://wa.me/919632013414?text=Hi`
						window.open(url, '_blank').focus();
					}
        //}).catch(error => {
        // do something with error
		// 		if (document.getElementById("kc-totp-login-form") && (param1 === 'Resend OTP' || param1 === 'Submit OTP')) {
        //     setTimeout("submitForm()", 1000); // set timout
        //   } else if(param1 === 'WhatsApp'){
		// 				var url = `https://wa.me/919632013414?text=Hi%2C%20Need%20help%20on%20Aastrika%20Platform`
		// 				window.open(url, '_blank').focus();
		// 			}
        //})
			} catch(error) {
				if (document.getElementById("kc-totp-login-form") && (param1 === 'Resend OTP' || param1 === 'Submit OTP')) {
            setTimeout("submitForm()", 1000); // set timout
          } else if(param1 === 'WhatsApp'){
						var url = `https://wa.me/919632013414?text=Hi`
						window.open(url, '_blank').focus();
					}
			}
			return true
      }
      function submitForm() { // submits form
        document.getElementById("kc-totp-login-form").submit();
      }
      </script>
    </#if>
</@layout.registrationLayout>

