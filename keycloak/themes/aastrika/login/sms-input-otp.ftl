<#import "template.ftl" as layout>
    <@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTitle",realm.displayName)}
    <#elseif section = "form">
    <div class="custom-wrapper">
        <div class="ui raised shadow container segment fullpage-background-image">
            <div class="ui one column grid stackable">
                <div class="ui column height-fix">
                    <img alt="Logo" src="${url.resourcesPath}/img/aastar-logo.svg" width="120">
                    <div class="max-container">
                        <div class="logo">
                            <img alt="Logo" src="${url.resourcesPath}/img/SMS.png" width="120">
                          </div>
                        <div class="signInHead mt-27">
                            <!-- ${msg("enterCode")} -->
                            Check your EMAIL/SMS for OTP!
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
                            <div class="field">
                                <button onclick="javascript:makeDivUnclickable()" class="ui fluid submit button" name="login" id="login" type="submit" value="${msg("doLogIn")}">${msg("doSubmit")}</button>
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
                                <button onclick="javascript:makeDivUnclickable()" class="ui fluid submit button" name="login" id="login" type="submit" value="${msg("doLogIn")}">${msg("doResendOTP")}</button>
                            </div>
                        </form>
                        <div class="field">
                            <span class="whatsApp">
                            <img alt="Logo" src="${url.resourcesPath}/img/whatsapp.png" width="30">
                        </span>
                            <a class="ui fluid button greenButton"
                            href="https://wa.me/919632013414?text=Hi%2C%20Need%20help%20on%20Aastrika%20Platform"
                            target="_blank">Get Help on WhatsApp?</a>
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
    </#if>
</@layout.registrationLayout>

