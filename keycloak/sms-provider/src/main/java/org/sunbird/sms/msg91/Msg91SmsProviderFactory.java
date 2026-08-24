package org.sunbird.sms.msg91;

import org.sunbird.sms.provider.ISmsProvider;
import org.sunbird.sms.provider.ISmsProviderFactory;

import java.util.Map;

public class Msg91SmsProviderFactory implements ISmsProviderFactory {

//    private static Msg91SmsProvider msg91SmsProvider = null;
    // Aastrika specific
    private static EnhancedMsg91SmsProvider msg91SmsProvider = null;

    @Override
    public ISmsProvider create(Map<String, String> configurations) {
        if (msg91SmsProvider == null){
//            msg91SmsProvider = new Msg91SmsProvider();
            msg91SmsProvider = new EnhancedMsg91SmsProvider();
            try {
                msg91SmsProvider.configure(configurations);
            } catch (Exception e) {     // try catch block is Aastrika specific
            }
        }

        return msg91SmsProvider;
    }
}
