package org.sunbird.sms.provider;

import java.util.Map;

public interface ISmsProvider {

    void configure(Map<String, String> configurations) throws Exception;     // throws is Aastrika specific

    boolean send(String phoneNumber, String smsText);
}
