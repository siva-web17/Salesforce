/**
 * Created by arjun.mohan on 2/19/2018.
 */

public  class AccountsService {

    public static String syncAccountDetailsToPoseidon (Map<Id, Account> newAccountMap) {
        List<Map<String, Map<String, Map<String, String>>>> updatedAccountList = new List<Map<String, Map<String, Map<String, String>>>>();
        List<Id> accountIdList = new List<Id>();
        String market = '';
        String returnMessage='';

        Map<Id, Opportunity> accountOpportunityMap = OpportunitiesSelector.getActiveOpportunitiesforAccount(newAccountMap.keySet());
        system.debug('Method hitting');
        Boolean hasActiveOpportunity=true;
        List<Id> userIdList=new List<Id>();
        system.debug('Inside AccountsService.syncAccountDetailsToPoseidon');
        for (Account accountRecord : newAccountMap.values()) {
            userIdList.add(accountRecord.CreatedById);
            userIdList.add(accountRecord.LastModifiedById);
        }
        Map<Id,User> UserMap= UsersHelper.getUserDetailsForUserIds(userIdList);
        if (accountOpportunityMap.size() < newAccountMap.size()) {
            hasActiveOpportunity=false;
            System.debug('hasActiveOpportunitarjun '+ hasActiveOpportunity);
        }
        try {
            for (Account accountRecord : newAccountMap.values()) {
                System.debug('Inside ForLoop '+ newAccountMap.values());
                if (!hasActiveOpportunity) {
                    returnMessage=Label.NoActiveOpportunity;
                    return returnMessage;
                }

                market = accountRecord.Market__c;
                Map<String, Map<String, Map<String, String>>> changedAccountRecordMap = new Map<String, Map<String, Map<String, String>>>();
                Map<String, Map<String, String>> changedAccountWithTableNameMap = new Map<String, Map<String, String>>();
                accountIdList.add(accountRecord.Id);
                //if (accountRecord.TotalBooking__c > 0) {
                Map<String, String> AddressfieldValueMap = new Map<String, String>();
                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Address.getFields()) {
                    AddressfieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                }
                System.debug('FieldSets.Address '+ AddressfieldValueMap);
                if (AddressfieldValueMap.size() > 0) {
                    changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.Address.getName(), AddressfieldValueMap);
                    changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                }
                System.debug('changedAccountRecordMap '+ changedAccountRecordMap);

                Map<String, String> CustomerfieldValueMap = new Map<String, String>();
                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Customer.getFields()) {
                    CustomerfieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                }
                System.debug('FieldSets.Customer '+ CustomerfieldValueMap);
                if (CustomerfieldValueMap.size() > 0) {
                    changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.Customer.getName(), CustomerfieldValueMap);
                    changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                }
                System.debug('changedAccountRecordMap '+ changedAccountRecordMap);

                Map<String, String> CustomerMarketingPreffieldValueMap = new Map<String, String>();
                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.CustomerMarketingPref.getFields()) {
                    CustomerMarketingPreffieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                }
                System.debug('FieldSets.CustomerMarketingPref '+ CustomerMarketingPreffieldValueMap);
                if (CustomerMarketingPreffieldValueMap.size() > 0) {
                    changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.CustomerMarketingPref.getName(), CustomerMarketingPreffieldValueMap);
                    changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                }
                System.debug('changedAccountRecordMap '+ changedAccountRecordMap);

                Map<String, String> OpportunityfieldValueMap = new Map<String, String>();
                for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.OppDetailsForAccountSyncing.getFields()) {
                    if (accountOpportunityMap.containsKey(accountRecord.Id)) {
                        OpportunityfieldValueMap.put(f.getFieldPath(), String.valueOf(accountOpportunityMap.get(accountRecord.Id).get(f.getFieldPath())));
                    }
                }
                System.debug('FieldSets.OppDetailsForAccountSyncing '+ OpportunityfieldValueMap);
                if (OpportunityfieldValueMap.size() > 0) {
                    if (accountOpportunityMap.containsKey(accountRecord.Id)) {
                        OpportunityfieldValueMap.put('OpportunityId', String.valueOf(accountOpportunityMap.get(accountRecord.Id).Id));
                    }
                    changedAccountWithTableNameMap.put(SObjectType.Opportunity.FieldSets.OppDetailsForAccountSyncing.getName(), OpportunityfieldValueMap);
                    changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                }
                System.debug('changedAccountRecordMap '+ changedAccountRecordMap);
                if (changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.Address.getName()) ||
                        changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.Customer.getName())
                        || changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.CustomerMarketingPref.getName())) {

                    updatedAccountList.add(changedAccountRecordMap);
                    System.debug('Inside Updating List '+ updatedAccountList);
                }

            }
            if (updatedAccountList.size() > 0) {
                Map<String, String> userDetailsMap = new Map<String, String>();
                if (UserMap.containsKey(newAccountMap.values()[0].CreatedById) && UserMap.containsKey(newAccountMap.values()[0].LastModifiedById)) {
                    userDetailsMap.put('CreatedBy',String.valueOf(UserMap.get(newAccountMap.values()[0].CreatedById).Email.substringBefore('@')));
                    userDetailsMap.put('LastModifiedBy',String.valueOf(UserMap.get(newAccountMap.values()[0].LastModifiedById).Email.substringBefore('@')));
                }
                else
                {
                    userDetailsMap.put('CreatedBy','No User Found for :'+newAccountMap.values()[0].CreatedById);
                    userDetailsMap.put('CreatedBy','No User Found for :'+newAccountMap.values()[0].LastModifiedById);
                }

                userDetailsMap.put('CreatedDate',String.valueOf(newAccountMap.values()[0].CreatedDate));
                userDetailsMap.put('LastModifiedDate',String.valueOf(newAccountMap.values()[0].LastModifiedDate));
                market = newAccountMap.values()[0].market__c;

                AccountsHelper.SyncAccountDetailsWrapper objwrapper = new AccountsHelper.SyncAccountDetailsWrapper(updatedAccountList, userDetailsMap, market);
                String JSONValue= JSON.serialize(objwrapper);
                System.debug('Girish Account JSON '+JSONValue);
                ExternalRouter.callNewAccountFamilyDetailsService(JSONValue);
                Map<Id, AccountContactRelation> accountContactRelationMap = AccountContactRelationsSelector.getAccountContactRelationForAccountId(accountIdList);
                if (accountContactRelationMap.size() > 0) {
                    Boolean IsComplicatedBooking=true;
                    AccountContactRelationHelper.validateAndSendDetailsToPoseidon(accountContactRelationMap,Label.DMLTypeInsert,IsComplicatedBooking);
                }
            }

        } catch (Exception ex) {
            returnMessage=ex.getMessage();
            System.debug('returnMessage '+returnMessage);
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'AccountsHelper', 'saveAccountInformation', '');
        }
        return returnMessage;

    }

}