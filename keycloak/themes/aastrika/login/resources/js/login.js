function getQueryStringValue (key) {
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}

window.onload = function(){
	var mergeaccountprocess = (new URLSearchParams(window.location.search)).get('mergeaccountprocess');
	var version = getValueFromSession('version');
	var isForgetPasswordAllow = getValueFromSession('version');
	var renderingType = 'queryParams';
	let url = document.baseURI

	console.log(url, '0000')
	if(url.includes('app=Ekshamata') || url.includes('app=Sphere')){
		sessionStorage.removeItem('url')		
		//if(url.includes('&client_id=android')) {
			sessionStorage.setItem('url',url)
		//}
	}
	//let ele = document.getElementById('createAccount-loginOTP')
	let ele1 =  document.querySelectorAll("#createAccount-loginOTP");
	let orId = document.querySelectorAll("#or-holder");
	let wId = document.querySelectorAll("#WhatsApp-loginOTP");
	let a1id = document.querySelectorAll("#sphere-anchor");
	let a2id = document.querySelectorAll("#otp-anchor");
	let a3id = document.querySelectorAll("#logoRedirect");
	let a4id = document.querySelectorAll("#backToApplication");
	let a5id = document.querySelectorAll(".whatsApp");
  let a6id = document.querySelectorAll(".whatsApp-otp")
  let urlCheck = sessionStorage.getItem('url')
	console.log(ele1.length, 'ele1', orId.length, wId.length, a3id.length, a4id.length, a5id.length, 'ids')
	if(url.includes('app=Ekshamata') || urlCheck.includes('app=Ekshamata')) {
	 console.log('ele') 
   for (let i = 0; i < a1id.length; i++) {
    a1id[i].setAttribute("class","pointer-eOff");
    }

	 for (let i = 0; i < ele1.length; i++) {
		ele1[i].style.display = "none";
	  }
	  for (let i = 0; i < a5id.length; i++) {
		a5id[i].style.display = "none";
	  }
	  for (let i = 0; i < orId.length; i++) {
		orId[i].style.display = "none";
	  }
	  for (let i = 0; i < wId.length; i++) {
		wId[i].style.display = "none";
	  }
    for (let i = 0; i < a2id.length; i++) {
			a2id[i].setAttribute("class","pointer-eOff");
		  }
		  for (let i = 0; i < a3id.length; i++) {
			a3id[i].setAttribute("class","pointer-eOff");
		  }
      for (let i = 0; i < a4id.length; i++) {
        a4id[i].setAttribute("class","pointer-eOff");
        }
        for (let i = 0; i < a6id.length; i++) {
          a6id[i].style.display = "none";
          }
	//   ele.style.display = 'none';
	//    ele.classList.add("hide");
	//orId.classList.add('hide');
	  // ele1.classList.add('hide');
	} else if(url.includes('app=Sphere') || urlCheck.includes('app=Sphere')) {
		for (let i = 0; i < a1id.length; i++) {
			a1id[i].setAttribute("class","pointer-eOff");
		  }
		  for (let i = 0; i < a2id.length; i++) {
			a2id[i].setAttribute("class","pointer-eOff");
		  }
		  for (let i = 0; i < a3id.length; i++) {
			a3id[i].setAttribute("class","pointer-eOff");
		  }
		  for (let i = 0; i < a4id.length; i++) {
			a4id[i].setAttribute("class","pointer-eOff");
		  }
	} else {
		for (let i = 0; i < ele1.length; i++) {
			ele1[i].style.display = "block";
		  }
		  for (let i = 0; i < orId.length; i++) {
			orId[i].style.display = "block";
			orId[i].style.textAlign = "center";
		  }
		  for (let i = 0; i < wId.length; i++) {
			wId[i].style.display = "block";
		  }
		// orId.classList.add('block');
		// ele1.classList.add('block');
		//ele.style.display = 'block';
	}

	if (!mergeaccountprocess) {
		mergeaccountprocess = localStorage.getItem('mergeaccountprocess');
		if (mergeaccountprocess === '1') {
			if (!version) {
				version = localStorage.getItem('version');
			}
			hideElement("mergeAccountMessage");
			renderingType = 'local-storage';
			var error_summary = document.getElementById('error-summary');
			if (error_summary) {
				var errorMessage = error_summary.innerHTML.valueOf();
				error_summary.innerHTML = errorMessage + 'to merge';
			}
		}
	} else {
		localStorage.clear()
	}
	addVersionToURL(version);
	var error_message = (new URLSearchParams(window.location.search)).get('error_message');
	var success_message = (new URLSearchParams(window.location.search)).get('success_message');

	if(error_message){
		var error_msg = document.getElementById('error-msg');
		error_msg.className = error_msg.className.replace("hide","");
		error_msg.innerHTML = error_message;
	}else if(success_message){
		var success_msg = document.getElementById("success-msg");
		success_msg.className = success_msg.className.replace("hide","");
		success_msg.innerHTML = success_message;
	}
	if (version >= 4) {
		var forgotElement = document.getElementById("fgtPortalFlow");
		if(forgotElement){
			forgotElement.className = forgotElement.className.replace("hide","");
		}
	} else {
		var forgotElement = document.getElementById("fgtKeycloakFlow");
		if(forgotElement){
			forgotElement.className = forgotElement.className.replace("hide","");
			forgotElement.href = forgotElement.href + '&version=' + version ;
		}
	}
	if(!version && isForgetPasswordAllow >=4 ){
		hideElement("fgtKeycloakFlow");
		var forgotElement = document.getElementById("fgtPortalFlow");
		if(forgotElement){
			forgotElement.className = forgotElement.className.replace("hide","");
		}
	}
	if (mergeaccountprocess === '1') {
		hideElement("kc-registration");
		hideElement("stateButton");
		hideElement("fgtKeycloakFlow");
		hideElement("fgtPortalFlow");
		// change sign in label with merge label
		var signIn = document.getElementById("signIn");
		if (signIn) {
			signIn.innerText = 'Merge Account';
			signIn.classList.add('fs-22');
		}
		// adding link to go back url
		var goBackElement = document.getElementById("goBack");
		if (goBackElement) {
			goBackElement.className = goBackElement.className.replace("hide", "");
		}
		// if rendering type is local-storage get redirect url from localstorage else from query param
		if (renderingType === 'local-storage') {
			goBackElement.href = localStorage.getItem('redirectUrl');
		} else {
			goBackElement.href = (new URLSearchParams(window.location.search)).get('goBackUrl');
			localStorage.setItem('mergeaccountprocess', mergeaccountprocess);
			localStorage.setItem('version', version);
			localStorage.setItem('redirectUrl', (new URLSearchParams(window.location.search)).get('goBackUrl'));
		}
		var mergeAccountMessage = document.getElementById("mergeAccountMessage");
		if (mergeAccountMessage && renderingType === 'queryParams') {
			mergeAccountMessage.className = mergeAccountMessage.className.replace("hide", "");
		}
	}
	var autoMerge = getValueFromSession('automerge');
	if (autoMerge === '1') {
		decoratePage('autoMerge');
		storeValueForMigration();
	}
};

function checkMobileEmail() {
  var regex = /^((([6-9][0-9]{9}))|([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))$/;
  let input = document.getElementById("emailOrPhone");
  let btn = document.getElementById("otp-login")
  let match = input.value.match(regex)
  if(match !== null && match.length > 0 ) {
    btn.setAttribute("enabled", "")
  } else {
    btn.setAttribute("disabled", "");
  }
}

function checkCredentials() {
  var regex = /^((([6-9][0-9]{9}))|([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))$/;
  let input1 = document.getElementById("username");
  let input2 = document.getElementById("password")
  let btn = document.getElementById("login-username-password")
  let match = input1.value.match(regex)
  console.log(input1.test(regex), input2.value, input2.trim().length)
  if(match !== null && match.length > 0 && input2.value.trim().length > 7) {
    btn.setAttribute("enabled", "");
   } else {
   btn.setAttribute("disabled", "");
   }
}
var storeValueForMigration = function () {
	// storing values in sessionStorage for future references
	sessionStorage.setItem('automerge', getValueFromSession('automerge'));
	sessionStorage.setItem('goBackUrl', getValueFromSession('goBackUrl'));
	sessionStorage.setItem('identifierValue', getValueFromSession('identifierValue'));
	sessionStorage.setItem('identifierType', getValueFromSession('identifierType'));
	sessionStorage.setItem('userId', getValueFromSession('userId'));
};
var getValueFromSession = function (valueId) {
	var value = (new URLSearchParams(window.location.search)).get(valueId);
	if (value) {
		sessionStorage.setItem(valueId, value);
		sessionStorage.setItem('renderingType', 'queryParams');
		return value
	} else {
		value = sessionStorage.getItem(valueId);
		if (value) {
			sessionStorage.setItem('renderingType', 'sessionStorage');
		}
		return value
	}
};


var getValue = function (valueId) {
	var value = (new URLSearchParams(window.location.search)).get(valueId);
	if (value) {
		localStorage.setItem('renderingType', 'queryParams');
		return value
	} else {
		value = localStorage.getItem(valueId);
		if (value) {
			localStorage.setItem('renderingType', 'localStorage');
		}
		return value
	}
};


var decoratePage = function (pageType) {
	if (pageType === 'autoMerge') {
		var identifierValue = getValueFromSession('identifierValue');
		var goBackUrl = getValueFromSession('goBackUrl');
		var signIn = document.getElementById("signIn");
		if (signIn) {
			signIn.innerText = 'Merge Account';
			signIn.classList.add('fs-22');
		}
		var loginButton = document.getElementById("login");
		if (loginButton) {
			loginButton.innerText = 'Next';
		}
		setElementValue('username', identifierValue);

		var elementsToHide = ['kc-registration', 'stateButton', 'fgtKeycloakFlow', 'fgtPortalFlow',
			'usernameLabel', 'usernameLabelPlaceholder', 'username'];

		unHideElement('migrateAccountMessage');
		unHideElement('goBack');
		var goBackElement = document.getElementById("goBack");
		if (goBackElement) {
			goBackElement.href = goBackUrl;
		}
		if (sessionStorage.getItem('renderingType') === 'sessionStorage') {
			unHideElement('selfSingUp');
			var errorElement = document.getElementById('error-summary');
			if (errorElement) {
				var wrongPasswordError = 'Invalid Email Address/Mobile number or password. Please try again with valid credentials';
				if (errorElement.innerText.toLowerCase() === wrongPasswordError.toLowerCase()) {
					unHideElement('inCorrectPasswordError');
					handlePasswordFailure();
				}
				elementsToHide.push('error-summary');
			}
		}
		for (var i = 0; i < elementsToHide.length; i++) {
			hideElement(elementsToHide[i]);
		}
	}
};

var handlePasswordFailure = function () {
	var passwordFailCount = Number(sessionStorage.getItem('passwordFailCount') || 0);
	passwordFailCount = passwordFailCount + 1;
	sessionStorage.setItem('passwordFailCount', passwordFailCount);
	if (passwordFailCount >= 2) {
		const url = '/sign-in/sso/auth?status=error' + '&identifierType=' + getValueFromSession('identifierType');
		const query = '&userId=' + getValueFromSession('userId') + '&identifierValue=' + getValueFromSession('identifierValue');
		window.location.href = window.location.protocol + '//' + window.location.host + url + query;
	}
};

var unHideElement = function (elementId) {
	var elementToUnHide = document.getElementById(elementId);
	if (elementToUnHide) {
		elementToUnHide.className = elementToUnHide.className.replace("hide", "");
	}
};
var setElementValue = function (elementId, elementValue) {
	var element = document.getElementById(elementId);
	if (element) {
		element.value = elementValue;
	}
};

var storeLocation = function(){
	sessionStorage.setItem('url', window.location.href);
}
var addVersionToURL = function (version){

	if (version >= 1){
		var selfSingUp = document.getElementById("selfSingUp");

		if(selfSingUp) {
			selfSingUp.className = selfSingUp.className.replace(/\bhide\b/g, "");
		}

		var stateButton = document.getElementById("stateButton");

		if ((version >= 2) && stateButton) {
			stateButton.className = stateButton.className.replace(/\bhide\b/g, "");
		}
	}
}
var makeDivUnclickable = function() {
	var containerElement = document.getElementById('kc-form');
	var overlayEle = document.getElementById('kc-form-wrapper');
	overlayEle.style.display = 'block';
	containerElement.setAttribute('class', 'unClickable');
};

var inputBoxFocusIn = function(currentElement){
	let url = document.baseURI
	var autoMerge = getValueFromSession('automerge');
	if (autoMerge === '1') {
		return;
	}
	if(currentElement.id !== 'totp'){
		var placeholderElement = document.querySelector("label[id='"+currentElement.id+"LabelPlaceholder']");
		var labelElement = document.querySelector("label[id='"+currentElement.id+"Label']");
		placeholderElement.className = placeholderElement.className.replace("hide", "");
		addClass(labelElement,"hide");
	}
};
var inputBoxFocusOut = function (currentElement) {
	var autoMerge = getValueFromSession('automerge');
	if (autoMerge === '1') {
		return;
	}
	if(currentElement.id !== 'totp'){
		var placeholderElement = document.querySelector("label[id='"+currentElement.id+"LabelPlaceholder']");
		var labelElement = document.querySelector("label[id='"+currentElement.id+"Label']");
		labelElement.className = labelElement.className.replace("hide", "");
		addClass(placeholderElement,"hide");
	}
};

function hideElement(elementId) {
	var elementToHide = document.getElementById(elementId);
	if (elementToHide) {
		addClass(elementToHide, "hide");
	}
}

function addClass(element,classname)
{
	var arr;
  	arr = element.className.split(" ");
  	if (arr.indexOf(classname) == -1) {
    	element.className += " " + classname;
	}
}

var redirectToLib = () => {
	window.location.href = window.location.protocol + '//' + window.location.host + '/page/home';
};

var viewPassword = function(previewButton){
	var newPassword = document.getElementById("password-new");
  	if (newPassword.type === "password") {
		newPassword.type = "text";
		addClass(previewButton,"slash");
  	} else {
		newPassword.type = "password";
		previewButton.className = previewButton.className.replace("slash","");
  	}
}
var viewNewPassword = function(previewButton){
	var newPassword = document.getElementById("password-confirm");
  	if (newPassword.type === "password") {
		newPassword.type = "text";
		addClass(previewButton,"slash");
  	} else {
		newPassword.type = "password";
		previewButton.className = previewButton.className.replace("slash","");
  	}
}
var urlMap = {
	google: '/google/auth',
	state: '/sign-in/sso/select-org',
	self: '/signup',
	parichay:'/apis/public/v8/parichay/auth'
}
var navigate = function(type) {
	var version = getValueFromSession('version');
	if(version == '1' || version == '2') {
		if(type == 'google' || type == 'self'){
			redirect(urlMap[type]);
		} else if(type == 'state') {
			handleSsoEvent()
		}
	} else if (version >= '3') {
		if(type == 'google') {
			handleGoogleAuthEvent()
		} else if(type == 'state' || type == 'self') {
			redirectToPortal(urlMap[type])
		}
	}
}
var navigateToParichay= function(type){
	if(type == 'parichay'){
		redirect(urlMap[type]);
	}
}
var initialize = () => {
	getValueFromSession('redirect_uri');
	if (!sessionStorage.getItem('session_url')) {
		sessionStorage.setItem('session_url', window.location.href);
	}
};

initialize();

var forgetPassword = (redirectUrlPath) => {
	const curUrlObj = window.location;
	var redirect_uri = getValueFromSession('redirect_uri');
	var client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const sessionUrl = sessionStorage.getItem('session_url');
	if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if(client_id === 'android'){
				window.location.href = sessionUrlObj.protocol + '//' + sessionUrlObj.host + redirectUrlPath + updatedQuery;
			}
			else{
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host +
					redirectUrlPath + updatedQuery;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
}

var redirect  = (redirectUrlPath) => {
	console.log('redirect', redirectUrlPath)
	const curUrlObj = window.location;
	var redirect_uri = getValueFromSession('redirect_uri');
	var client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const sessionUrl = sessionStorage.getItem('session_url');
	if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if (client_id === 'android') {
				window.location.href = sessionUrlObj.protocol + '//' + sessionUrlObj.host + redirectUrlPath + updatedQuery;
			} else {
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host +
					redirectUrlPath + updatedQuery;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
};
var handleSsoEvent  = () => {
	const ssoPath = '/sign-in/sso/select-org';
	const curUrlObj = window.location;
	let redirect_uri = getValueFromSession('redirect_uri');
	let client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const sessionUrl = sessionStorage.getItem('session_url');
	if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if (client_id === 'android') {
				const ssoUrl = sessionUrlObj.protocol + '//' + sessionUrlObj.host + ssoPath;
				window.location.href = redirect_uri + '?ssoUrl=' + ssoUrl;
			} else {
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + ssoPath;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
};
var handleGoogleAuthEvent = () => {
	const googleAuthUrl = '/google/auth';
	const curUrlObj = window.location;
	let redirect_uri = getValueFromSession('redirect_uri');
	let client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const updatedQuery = curUrlObj.search + '&error_callback=' + curUrlObj.href.split('?')[0];
	const sessionUrl = sessionStorage.getItem('session_url');
	if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if (client_id === 'android') {
				const googleRedirectUrl = sessionUrlObj.protocol + '//' + sessionUrlObj.host + googleAuthUrl;
				window.location.href = redirect_uri + '?googleRedirectUrl=' + googleRedirectUrl + updatedQuery;
			} else {
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + googleAuthUrl + updatedQuery;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
};
var redirectToPortal = (redirectUrlPath) => { // redirectUrlPath for sso and self signUp
	const curUrlObj = window.location;
	var redirect_uri = getValueFromSession('redirect_uri');
	var client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const sessionUrl = sessionStorage.getItem('session_url');
	if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if (client_id === 'android') {
				window.location.href = sessionUrlObj.protocol + '//' + sessionUrlObj.host + redirectUrlPath + updatedQuery;
			} else {
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host +
					redirectUrlPath + updatedQuery;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
};
