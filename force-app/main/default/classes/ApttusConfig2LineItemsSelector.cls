/**
 * Created by harsh.mathur on 12/27/2017.
 */

public class ApttusConfig2LineItemsSelector {
    public static List<Apttus_Config2__LineItem__c> getLineItemsForCartId(Id cartId, String productType){
        return [Select Id,Program__c,Apttus_Config2__AttributeValueId__r.APTS_DestinationCode__c,Apttus_Config2__AttributeValueId__r.APTS_Beginner__c
                from Apttus_Config2__LineItem__c
                where Apttus_Config2__ConfigurationId__c=:cartId
                and Apttus_Config2__OptionId__r.Apttus_Config2__ProductType__c=:productType
                and APTS_HasStartDateConfigured__c=FALSE ];
    }

    public static List<Apttus_Config2__LineItem__c> getLineItemsForSelectedConfigId(List<Id> configIdset, List<Decimal> lineNumberList){
        return [Select Id,Program__c,Apttus_Config2__Quantity__c,Apttus_Config2__EndDate__c,Apttus_Config2__StartDate__c
                from Apttus_Config2__LineItem__c
                where Apttus_Config2__ConfigurationId__c in :configIdset
                and Apttus_Config2__LineNumber__c in :lineNumberList];
    }
}