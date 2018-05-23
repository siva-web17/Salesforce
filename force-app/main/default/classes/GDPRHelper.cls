/**
* Created by thejasvi.a on 5/21/2018.
*/

public with sharing class GDPRHelper {

    public static Boolean PseudonymiseAccount(Map<Id, Account> accountForgetMap) {
        Boolean datasaved = false;
        Id currentAccountId;
        try {
            List<AccountToPseudoAccountMapping__mdt> accountPseudoMdtList = [Select Id,IsMandatoryOnAccount__c, AccountAPIName__c, PseudoAccountAPIName__c from AccountToPseudoAccountMapping__mdt];
            Map<Id, Opportunity> activeOpportunityMap =
                    OpportunitiesSelector.getOpportunitiesforAccount(accountForgetMap.Keyset(), TRUE);
            List<PseudoAccount__c> pseudoAccountList = new List<PseudoAccount__c>();
            for (Account accountRec:accountForgetMap.values()) {
                currentAccountId = accountRec.Id;
                pseudoAccountList.add(maskAccountFields(accountPseudoMdtList,accountRec));
                setUnsubscribeFields(accountRec);
                deactivateOpportunity(activeOpportunityMap, currentAccountId);
                accountRec.IsPseudonymised__pc = true;
            }
            if (activeOpportunityMap.Size() > 0) {
                update activeOpportunityMap.values();
            }
            Insert pseudoAccountList;
            update accountForgetMap.values();
            datasaved=true;
        } Catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'GDPRHelper', 'PseudonymiseAccount', currentAccountId);
            datasaved = false;
        }
        return datasaved;
    }

    private static PseudoAccount__c maskAccountFields(List<AccountToPseudoAccountMapping__mdt> accountPseudoMdtList,Account accountRec) {
        //Before Deleting the details, we will map that to new object
        PseudoAccount__c pseudoAccount = new PseudoAccount__c();
        // Mask Account fields
        for (AccountToPseudoAccountMapping__mdt accountPseudoMappingRecord:accountPseudoMdtList) {
            pseudoAccount.put(accountPseudoMappingRecord.PseudoAccountAPIName__c, accountRec.get(accountPseudoMappingRecord.AccountAPIName__c));

            if (accountPseudoMappingRecord.IsMandatoryOnAccount__c) {
                accountRec.put(accountPseudoMappingRecord.AccountAPIName__c, accountRec.ID);
            } else {
                accountRec.put(accountPseudoMappingRecord.AccountAPIName__c, null);
            }
        }
        return pseudoAccount;
    }

    private static void setUnsubscribeFields(Account accountRec) {
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UnsubscribeFields.getFields()) {
            accountRec.put(f.getFieldPath(), TRUE);
        }
    }

    private static void deactivateOpportunity(Map<Id, Opportunity> activeOpportunityMap,Id accountId) {
        if (activeOpportunityMap.containsKey(accountId)) {
            activeOpportunityMap.get(accountId).StageName = Label.SalesClosed;
        }
    }
}