/**
 * Created by harsh.mathur on 12/27/2017.
 */

public class ApttusConfig2LineItemsDispatcher{
    public static void run() {
        try {
            if (Trigger.isAfter) {
                if (Trigger.IsUpdate) {
                    ApttusConfig2LineItem.onAfterUpdate((map<Id, Apttus_Config2__LineItem__c>) trigger.NewMap, (map<Id, Apttus_Config2__LineItem__c>) trigger.OldMap); 
                }
                if (Trigger.isDelete) {
                    ApttusConfig2LineItem.onAfterInsert((map<Id, Apttus_Config2__LineItem__c>) trigger.NewMap, (map<Id, Apttus_Config2__LineItem__c>) trigger.OldMap);
                }
            }
        } catch (Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'ApttusConfig2LineItemsDispatcher', 'run', null);
        }
    }
}