/**
 * Created by savita.b on 7/26/2017.
 */

public class SFLangUtil {

    public static Date ConvertDateTimeTodate(DateTime inputDatetime) {
        return date.newInstance(inputDatetime.year(), inputDatetime.month(), inputDatetime.day());
    }

    public static string[] splitString(string splitStringValue, string splitChar) {
        return splitStringValue.split('\\' + splitChar);
    }

    public static boolean bypassTriggerForObject(String objectName) {
        Boolean isDisable = false;
        BypassTriggersValidation__c runningUserSetting = BypassTriggersValidation__c.getInstance();
        if (runningUserSetting != null &&
                runningUserSetting.DisableTrigger__c &&
                runningUserSetting.TriggerObject__c!=null
                ) {
            //Fetch all Objects to bypass
            List<String> objectNames = runningUserSetting.TriggerObject__c.split(',');
            if (objectNames!=null) {
                isDisable = new Set<String>(objectNames).contains(objectName);
            }
        }
        return isDisable;
    }
}