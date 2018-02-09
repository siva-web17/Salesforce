/**
 * Created by harsh.mathur on 12/27/2017.
 */

public class ApttusConfig2LineItem {
    public static void onAfterUpdate(Map<Id, Apttus_Config2__LineItem__c> newLineItemMap, Map<Id, Apttus_Config2__LineItem__c> oldLineItemMap){
        ApttusConfig2lineItemHelper.updateSeasonOnLineItem(newLineItemMap, oldLineItemMap); 
    }

    public static void onAfterInsert(Map<Id, Apttus_Config2__LineItem__c> newLineItemMap, Map<Id, Apttus_Config2__LineItem__c> oldLineItemMap){
        ApttusConfig2lineItemHelper.updateStartdateEnddateOfCourserelatedArticlesIfCourseIsChanged(newLineItemMap, oldLineItemMap);
    }
}