<#import "template.ftl" as layout>
  <@layout.registrationLayout displayInfo=social.displayInfo; section>
    <#if section="title">
      ${msg("loginTitle",(realm.displayName!''))}
      <#elseif section="header">
        <#elseif section="form">
          <#if realm.password>
            <div class="custom-wrapper">
              <div class="">

                <div class="ui raised shadow container segment  login-section">
                  <div class="ui one column grid stackable">
                    <#-- <div class="ui column tablet only computer only">
                  </div> -->
                  <div class="ui column height-fix">
                    <div class="logo">
                      <a href="/public/home">
                        <img alt="Logo" src="${url.resourcesPath}/img/aastar-logo.svg" width="120">
                      </a>
                    </div>
                    <div class="max-container">
                      <div class="ui header mtb">
                        <h1> Welcome! </h1>
                      </div>
                      <p class="fwb">Login with your Aastrika account</p>
                      <div class="formMsg  textCenter">
                        <#if message?has_content>
                          <div class="ui text mb-30 ${message.type}">
                            ${message.summary}
                          </div>
                        </#if>
                        <div id="success-msg" class="ui text success hide">suceess</div>
                        <div id="error-msg" class="ui text error hide">error</div>
                      </div>
                      <div class="field ${properties.kcFormGroupClass!} type-container mw-100">
                        <div>
                          <input type="radio" onclick="javascript:passwordOrOtp();" name="usePasswordOrOTP"
                            id="useOTPRB" class="" checked=true>&nbsp;
                          <label id="useOTPLabel" for="useOTPRB" class="">
                            Login with OTP
                          </label>

                        </div>
                        <div>
                          <input type="radio" onclick="javascript:passwordOrOtp();" name="usePasswordOrOTP"
                            id="usePasswordRB">&nbsp;
                          <label id="usePasswordLabel" for="usePasswordRB" class="">
                            Login with Password
                          </label>
                        </div>
                      </div>
                      <div id="usePasswordDiv" class="mw-100" style="display:none">
                        <form id="kc-form-login" onsubmit="login.disabled = true; return true;" class="ui form"
                          method="POST" action="${url.loginAction}">
                          <input type="hidden" name="page_type" value="login_with_pass" />
                          <div class="field">
                            <!-- <label id="usernameLabel" for="username" class="">
                              <#if !realm.loginWithEmailAllowed>${msg("username")}
                                <#elseif !realm.registrationEmailAsUsername>
                                  ${msg("emailOrPhone")}
                                  <#else>${msg("email")}
                              </#if>
                            </label>
                            <label id="usernameLabelPlaceholder" for="username" class="activeLabelColor hide">
                              <#if !realm.loginWithEmailAllowed>${msg("username")}
                                <#elseif !realm.registrationEmailAsUsername>
                                  ${msg("placeholderForEmailOrPhone")}
                                  <#else>${msg("email")}
                              </#if>
                            </label> -->
                            <#if usernameEditDisabled??>
                              <#-- TODO: need to find alternative for prepopulating username -->
                                <input class="mt-8" id="username" name="username" type="text" disabled />
                                <#else>
                                  <input class="mt-8" id="username" name="username" onfocusin="inputBoxFocusIn(this)"
                                    placeholder="Phone Number/Email ID" onfocusout="inputBoxFocusOut(this)" type="text"
                                    autofocus autocomplete="off" />
                            </#if>
                          </div>
                          <div class="field">
                            <div>
                              <label id="passwordLabel" for="password" class="">
                                ${msg("password")}
                              </label>
                              <label id="passwordLabelPlaceholder" for="password" class="activeLabelColor hide">
                                ${msg("placeholderForPassword")}
                              </label>
                            </div>
                            <input placeholder="${msg('passwordPlaceholder')}" class=" mt-8" id="password"
                              onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" name="password"
                              type="password" autocomplete="off" />
                            <span class="ui text error hide"
                              id="inCorrectPasswordError">${msg("inCorrectPasswordError")}</span>
                          </div>
                          <div class="field">
                            <#if recaptchaRequired??>
                              <div class="form-group">
                                <div class="${properties.kcInputWrapperClass!}">
                                  <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                                </div>
                              </div>
                            </#if>
                          </div>
                          <div>
                            <#if realm.resetPasswordAllowed>
                            <a id="fgtKeycloakFlow" class="ui right floated forgetPasswordLink hide" tabindex="1"
                              onclick="javascript:storeLocation(); javascript:makeDivUnclickable()"
                              href="${client.baseUrl}public/forgot-password?value=true">${msg("doForgotPassword")}</a>
                           
                          </#if>
                          </div>
                          <div class="field mt-10">
                            <button id="login" class="ui fluid button blueButton" onclick="otpClick(event, 'Login Button', 'login')">${msg("doLogIn")}</button>
                          </div>
                          <div class="field or-container">
                            <div class="or-holder">
                              <span class=""></span>
                              <span class="">OR</span>
                            </div>
                          </div>

                          <div id="kc-registration" class="field">
                            <div class="ui content mt-20 signUpMsg">
                              <!-- <span> -->
                                <!-- ${msg("noAccount")} -->
                                <a class="ui fluid button whiteButton"
                                  href="${client.baseUrl}app/create-account" onclick="otpClick(event, 'Create Account', 'createAccount-loginOTP')" id="createAccount-help">${msg("registerHere")}</a>
                                  <span class="whatsApp">
                                    <img alt="Logo" src="${url.resourcesPath}/img/whatsapp.png" width="30">
                                </span>
                                  <a class="ui fluid button greenButton"
                                  href="https://wa.me/919632013414?text=Hi%2C%20Need%20help%20on%20Aastrika%20Platform"
                                  target="_blank" id="WhatsApp-loginOTP" onclick="otpClick(event,'WhatsApp', 'WhatsApp-loginOTP')">Get Help on WhatsApp?</a>
                              <!-- </span> -->
                            </div>
                          </div>
                          <div id="selfSingUp" class="hide">
                            <p class="or my-16 textCenter">OR</p>
                            <div class="field">
                              <#if realm.password && social.providers??>
                                <!--div id="kc-social-providers">
                                                    <#list social.providers as p>
                                                    <a href="${p.loginUrl}" id="zocial-${p.alias}" class="zocial ${p.providerId} ui fluid blue basic button textCenter">
                                                    <i class="icon signInWithGoogle"></i>${msg("doSignIn")} ${msg("doSignWithGoogle")}
                                                    </a>
                                                    </#list>
                                                </div-->
                              </#if>
                              <button type="button" id="stateButton"
                                class="sb-btn sb-btn-normal sb-btn-success width-100 mb-16" onclick="navigate('state')">
                                ${msg("doSignWithState")}
                              </button>
                              <button type="button"
                                class="sb-btn sb-btn-normal sb-btn-outline-primary width-100 d-flex flex-ai-center flex-jc-center"
                                onclick="navigate('google')">
                                <img class="signInWithGoogle" src="${url.resourcesPath}/img/google.png">
                                ${msg("doLogIn")} ${msg("doSignWithGoogle")}
                              </button>
                            </div>
                            <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                              <div id="kc-registration" class="field">
                                <div class="ui content mt-20 signUpMsg">
                                  ${msg("noAccount")} <span id="signup" tabindex="0" class="registerLink"
                                    onclick="navigate('self')">${msg("registerHere")}</span>
                                  <span>${msg("noAccount")} <a class="signUpLink"
                                      href="${url.registrationUrl}">${msg("doRegister")}</a></span>
                                </div>
                              </div>
                            </#if>
                          </div>
                        </form>
                      </div>
                      <div id="useOTPDiv" class="mw-100">
                        <form id="kc-form-login" class="${properties.kcFormClass!} ui form"
                          action="${url.loginAction}" method="post">
                          <input type="hidden" name="page_type" value="login_page" />
                          <#-- <div class="${properties.kcFormGroupClass!}">
                            <div
                              class="mdc-text-field mdc-text-field--with-leading-icon ${properties.kcLabelClass!} <#if usernameEditDisabled??>mdc-text-field--disabled</#if>">
                              <i class="material-icons mdc-text-field__icon" role="button">phone</i>
                              <input tabindex="0" required id="user.attributes.mobile_number"
                                class="mdc-text-field__input ${properties.kcInputClass!}"
                                name="user.attributes.mobile_number" type="text" autofocus autocomplete="off">
                              <div class="mdc-line-ripple"></div>
                              <label for="user.attributes.mobile_number"
                                class="mdc-floating-label ${properties.kcLabelClass!}">
                                Phone Number
                              </label>
                            </div>
                      </div> -->

                      <div class="field">
                        <div>
                          <!-- <label id="phoneNumberLabel" for="emailOrPhone" class="">
                                                Email/Phone number
                                            </label> -->
                          <label id="phoneNumberLabelPlaceholder" for="emailOrPhone" class="activeLabelColor hide">
                            Phone Number/Email ID
                          </label>
                        </div>
                        <input tabindex="0" required id="emailOrPhone" placeholder="Phone Number/Email ID"
                          class="mdc-text-field__input ${properties.kcInputClass!} mt-8" name="emailOrPhone" type="text"
                          autofocus autocomplete="off" onfocusin="inputBoxFocusIn(this)"
                          onfocusout="inputBoxFocusOut(this)">
                      </div>

                      <div class="mdc-card__actions">
                        <#-- <a href="${url.registrationUrl}"
                          class="mdc-button mdc-card__action mdc-card__action--button">
                          <i class="material-icons mdc-button__icon">arrow_back</i>Sign Up
                          </a> -->

                          <div class="field">
                            <button tabindex="0" name="login" id="kc-login" type="submit" class="ui fluid button blueButton" onclick="otpClick(event, 'Login Button with OTP', 'kc-login')">Get OTP</button>
                          </div>
                          <div class="field or-container">
                            <div class="or-holder">
                              <span class=""></span>
                              <span class="">OR</span>
                            </div>
                          </div>

                          <div id="kc-registration" class="field">
                            <div class="ui content mt-20 signUpMsg">
                              <!-- <span> -->
                                <!-- ${msg("noAccount")}  -->
                                <a class="ui fluid button whiteButton"
                                  href="${client.baseUrl}app/create-account" onclick="otpClick(event, 'Create Account', 'createAccount-loginOTP')" id="createAccount-help">${msg("registerHere")}</a>
                              <!-- </span> -->
                              <span class="whatsApp">
                                <img alt="Logo" src="${url.resourcesPath}/img/whatsapp.png" width="30">
                            </span>
                              <a class="ui fluid button greenButton"
                                href="https://wa.me/919632013414?text=Hi%2C%20Need%20help%20on%20Aastrika%20Platform"
                                target="_blank" id="WhatsApp-loginOTP" onclick="otpClick(event, 'WhatsApp', 'WhatsApp-loginOTP')">Get Help on WhatsApp?</a>
                            </div>
                          </div>
                          <div id="selfSingUp" class="hide">
                           
                            <div class="field">
                             
                              
                             
                            </div>
                           
                          </div>
                      </div>
                      </form>
                    </div>
                  </div>
                </div>
                <#-- <div class="ui column tablet only computer only">
              </div> -->
            </div>
            </div>
            </div>
            </div>
            <script type="text/javascript">
              var slideIndex = 0;
              showSlides();

              function otpClick(e, param1, param2){
                e.preventDefault()
                let obj = {
                EventDetails: {
                  EventName: param1,
                  Name : param2
                }
              }
              const userdata = Object.assign(MainVisitorDetails, obj)
              fetch("https://track.plumb5.com/EventDetails/SaveEventDetails", {
                method: "POST",
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify( userdata)
              }).then(res => {
                console.log(res)
              }).then(res => {
                var enteredValue = document.getElementById("emailOrPhone")
                sessionStorage.setItem(enteredValue, 'emailOrPhone')
                var emailRegex = /^[a-zA-Z0-9 .!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9- ]+)*$/
                var isEmail = emailRegex.test(enteredValue);
                var phoneRegex = /^(\+91-|\+91|0)?\d{10}$/; // Change this regex based on requirement
                var isPhone = phoneRegex.test(enteredValue);
                let userInfo
                if(isEmail) {
                  let obj2 = {
                    "answerDetails": ["", "",form.value.emailOrMobile.trim(), ""]
                  }
                  userInfo  = Object.assign(MainVisitorDetails, obj2)
                } 
                if(isPhone) {
                  let obj2 = {
                    "answerDetails": ["", "", "", form.value.emailOrMobile.trim()]
                  }
                  userInfo  = Object.assign(MainVisitorDetails, obj2)
                }
                let obj3 = {
                  "FormInfoDetails": {
                    "FormId": 8,
                    "OTPFormId": 0,
                    "FormType": 1,
                    "BannerId": 0,
                    "RedirectUrl": "",
                    "Name": "",
                    "EmailId": ""
                  },
                  "MainVisitorDetails": userInfo
                }
                fetch('https://track.plumb5.com/FormInfoDetails/SaveFormDetails',{
                  method: "POST",
                  headers: {'Content-Type': 'application/json'},
                  body: JSON.stringify( obj3)
                }).then(res => {
                console.log(res)
                if (document.getElementById("kc-form-login")) {
                  setTimeout("submitForm()", 1000); // set timout
                }
                })              
              })
          }
            function submitForm() { // submits form
              document.getElementById("kc-form-login").submit();
            }
              function showSlides() {
                var i;
                var slides = document.getElementsByClassName("mySlides");
                var dots = document.getElementsByClassName("dot");
                for (i = 0; i < slides.length; i++) {
                  slides[i].style.display = "none";
                }
                slideIndex++;
                if (slideIndex > slides.length) { slideIndex = 1 }
                for (i = 0; i < dots.length; i++) {
                  dots[i].className = dots[i].className.replace(" active", "");
                }
                slides[slideIndex - 1].style.display = "block";
                dots[slideIndex - 1].className += " active";
                setTimeout(showSlides, 5000); // Change image every 5 seconds
              }

              function passwordOrOtp() {
                if (document.getElementById('usePasswordRB').checked) {
                  document.getElementById('usePasswordDiv').style.display = 'block';
                  document.getElementById('useOTPDiv').style.display = 'none';
                } else {
                  document.getElementById('usePasswordDiv').style.display = 'none';
                  document.getElementById('useOTPDiv').style.display = 'block';
                }
              }

            </script>
          </#if>
    </#if>
  </@layout.registrationLayout>
