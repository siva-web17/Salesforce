/**************************************************************************************
Apex Class Name    : AccountsHelper
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  07/16/2017              Original Version
*******************************************************************************/
public class AccountsHelper {

    /**Method will update standard unsubscribe field with same value as in custom field. 
       This method should be removed when salesforce allows to add person account fields to account layout quick actions
    **/
    public static void updateUnSubscribeFields(List<Account> lstAccounts) {
        /**
        1. Loop on account records
        2. For person accounts, update Unsubscribe fields        
        **/
        try {
            for (Account accountRecord : lstAccounts) {
                if (accountRecord.IsPersonAccount) {
                    accountRecord.PersonHasOptedOutOfEmail = accountRecord.EmailOptOut__c;
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'AccountsHelper', 'updateSubscribeFields', null);
        }
    }

    /**
     * @author Arkadiusz Celej
     *
     * @description This method should track if changes made on Accounts should set/reset letter and label values for
     * corresponding opportunities
     *
     * @param newAccounts list of changed accounts
     * @param oldAccountsByIds map of original accounts
     */
    public static void setDefaultLetterAndLabelOnOpportunities(List<Account> newAccounts, Map<Id, Account> oldAccountsByIds) {
        try {
            List<Id> accountsToResetTemplates = new List<Id>();
            Map<Id, Account> newAccountsById = new Map<Id, Account>(newAccounts);
            for (Account newAccount : newAccounts) {
                Account oldAccount = oldAccountsByIds.get(newAccount.Id);
                if (newAccount.Language__c != oldAccount.Language__c || newAccount.PersonBirthdate != oldAccount.PersonBirthdate) {
                    accountsToResetTemplates.add(newAccount.Id);
                }
            }
            if (accountsToResetTemplates.size() > 0) {
                List<Opportunity> opportunitiesWithSBRTasks = new List<Opportunity>();
                Map<Id, Date> accountBirthdatesByOppIds = new Map<Id, Date>();
                for (Opportunity o : OpportunitiesSelector.getOpportunitiesWithSBRTaskByAccountIds(accountsToResetTemplates)) {
                    if (o.Tasks.size() > 0) {
                        opportunitiesWithSBRTasks.add(o);
                        accountBirthdatesByOppIds.put(o.Id, newAccountsById.get(o.AccountId).PersonBirthdate);
                    }
                }
                if (opportunitiesWithSBRTasks.size() > 0) {
                    List<Opportunity> changedOpportunities = OpportunitiesHelper.setTemplatesForOpportunities(opportunitiesWithSBRTasks, accountBirthdatesByOppIds);
                    if (changedOpportunities.size() > 0) {
                        update changedOpportunities;
                    }
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'AccountsHelper', 'setDefaultLetterAndLabelOnOpportunities', null);
        }
    }

    public static void saveAccountInformation(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) {
        List<Map<String, Map<String, Map<String, String>>>> updatedAccountList = new List<Map<String, Map<String, Map<String, String>>>>();
        ID currentRecordID;
        try {
            //return if current user is configured for not pushing data to Poseidon     
            if (BypassTriggersValidation__c.getInstance().DoNotPushToPoseidon__c == True) {
                return;
            }
            //We dont need to check for active opportunity in this case as we are sending the details irrespective of opportunity state
            Map<Id, Opportunity> accountOpportunityMap = OpportunitiesSelector.getOpportunitiesforAccount(newAccountMap.keySet(), false);
//            Boolean hasActiveOpportunity = true;
//            if (accountOpportunityMap.size() < newAccountMap.size()) {
//                hasActiveOpportunity = false;
//            }
            List<Id> userIdList = new List<Id>();
            for (Account accountRecord : newAccountMap.values()) {
                userIdList.add(accountRecord.CreatedById);
                userIdList.add(accountRecord.LastModifiedById);
            }
            Map<Id, User> UserMap = UsersHelper.getUserDetailsForUserIds(userIdList);
            for (Account accountRecord : newAccountMap.values()) {
                currentRecordID = accountRecord.Id;
                Map<String, Map<String, Map<String, String>>> changedAccountRecordMap = new Map<String, Map<String, Map<String, String>>>();
                Map<String, Map<String, String>> changedAccountWithTableNameMap = new Map<String, Map<String, String>>();
                //SF-1988
                //Send details to Poseidon only when account has booking or Account is synched with Poseidon
                if (accountRecord.TotalBooking__c > 0 || (accountRecord.AccountExternalId__c != null && accountRecord.IsSyncedToPoseidon__c)) {
                    /* if (!hasActiveOpportunity) {
                        accountRecord.addError(Label.NoActiveOpportunity);
                        return;
                    }*/
                    Map<String, String> AddressfieldValueMap = new Map<String, String>();
                    for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Address.getFields()) {
                        if (accountRecord.get(f.getFieldPath()) != oldAccountMap.get(accountRecord.Id).get(f.getFieldPath())) {
                            AddressfieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                        }
                    }
                    AddressfieldValueMap.putAll(FieldChangedvalues(oldAccountMap.get(accountRecord.Id), AccountsService.MissingAddressfields(accountRecord)));
                    if (AddressfieldValueMap.size() > 0) {
                        changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.Address.getName(), AddressfieldValueMap);
                        changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                    }
                    system.debug(' changed Account With Table Name Map ' + changedAccountWithTableNameMap);
                    system.debug(' changed Account Record Map ' + changedAccountRecordMap);

                    Map<String, String> CustomerfieldValueMap = new Map<String, String>();
                    for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Customer.getFields()) {
                        if (accountRecord.get(f.getFieldPath()) != oldAccountMap.get(accountRecord.Id).get(f.getFieldPath())) {
                            CustomerfieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                        }
                    }
                    CustomerfieldValueMap.putAll(FieldChangedvalues(oldAccountMap.get(accountRecord.Id), AccountsService.MissingCustomerDetails(accountRecord)));
                    if (CustomerfieldValueMap.size() > 0) {
                        changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.Customer.getName(), CustomerfieldValueMap);
                        changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                    }
                    system.debug(' changed Account With Customer ' + changedAccountWithTableNameMap);
                    system.debug(' changed Account Record Map Customer ' + changedAccountRecordMap);

                    Map<String, String> CustomerMarketingPreffieldValueMap = new Map<String, String>();
                    for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.CustomerMarketingPref.getFields()) {
                        if (accountRecord.get(f.getFieldPath()) != oldAccountMap.get(accountRecord.Id).get(f.getFieldPath())) {
                            CustomerMarketingPreffieldValueMap.put(f.getFieldPath(), String.valueOf(accountRecord.get(f.getFieldPath())));
                        }
                    }
                    if (CustomerMarketingPreffieldValueMap.size() > 0) {
                        changedAccountWithTableNameMap.put(SObjectType.Account.FieldSets.CustomerMarketingPref.getName(), CustomerMarketingPreffieldValueMap);
                        changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                    }
                    system.debug(' changed Account With CustomerMarketingPref ' + changedAccountWithTableNameMap);
                    system.debug(' changed Account Record Map CustomerMarketingPref ' + changedAccountRecordMap);

                    Map<String, String> OpportunityfieldValueMap = new Map<String, String>();
                    for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.OppDetailsForAccountSyncing.getFields()) {
                        if (accountOpportunityMap.containsKey(accountRecord.Id)) {
                            OpportunityfieldValueMap.put(f.getFieldPath(), String.valueOf(accountOpportunityMap.get(accountRecord.Id).get(f.getFieldPath())));
                        }
                    }
                    if (OpportunityfieldValueMap.size() > 0) {
                        if (accountOpportunityMap.containsKey(accountRecord.Id)) {
                            OpportunityfieldValueMap.put('OpportunityId', String.valueOf(accountOpportunityMap.get(accountRecord.Id).Id));
                        }
                        changedAccountWithTableNameMap.put(SObjectType.Opportunity.FieldSets.OppDetailsForAccountSyncing.getName(), OpportunityfieldValueMap);
                        changedAccountRecordMap.put(accountRecord.Id, changedAccountWithTableNameMap);
                    }
                    system.debug(' changed Account With OppDetailsForAccountSyncing' + changedAccountWithTableNameMap);
                    system.debug(' changed Account Record Map OppDetailsForAccountSyncing ' + changedAccountRecordMap);

                    //Added This Condition so that we send details to Poseidon only if we have data in Address,Customer,CustomerMarketingpref Maps
                    if (changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.Address.getName()) ||
                            changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.Customer.getName())
                            || changedAccountWithTableNameMap.containsKey(SObjectType.Account.FieldSets.CustomerMarketingPref.getName())) {
                        updatedAccountList.add(changedAccountRecordMap);
                    }
                }
            }
            if (updatedAccountList.size() > 0) {
                Map<String, String> userDetailsMap = new Map<String, String>();
                if (UserMap.containsKey(newAccountMap.values()[0].CreatedById) && UserMap.containsKey(newAccountMap.values()[0].LastModifiedById)) {
                    userDetailsMap.put('CreatedBy', String.valueOf(UserMap.get(newAccountMap.values()[0].CreatedById).Email.substringBefore('@')));
                    userDetailsMap.put('LastModifiedBy', String.valueOf(UserMap.get(newAccountMap.values()[0].LastModifiedById).Email.substringBefore('@')));

                } else {
                    userDetailsMap.put('CreatedBy', 'No User Found for :' + newAccountMap.values()[0].CreatedById);
                    userDetailsMap.put('CreatedBy', 'No User Found for :' + newAccountMap.values()[0].LastModifiedById);
                }
                userDetailsMap.put('CreatedDate', String.valueOf(newAccountMap.values()[0].CreatedDate));
                userDetailsMap.put('LastModifiedDate', String.valueOf(newAccountMap.values()[0].LastModifiedDate));
                String market = newAccountMap.values()[0].market__c;
                SyncAccountDetailsWrapper objwrapper = new SyncAccountDetailsWrapper(updatedAccountList, userDetailsMap, market);
                String JSONValue = JSON.serialize(objwrapper);
                system.debug(' Calling from Account trigger: ' + Trigger.isExecuting + ' --System.isBatch() :' + System.isBatch() + ' !!!System.isFuture(): ' + System.isFuture() + '##System.isQueueable(): ' + System.isQueueable() + '^^^System.isScheduled() :' + System.isScheduled());
                if (Trigger.isExecuting && !System.isBatch()) {
                    ExternalRouter.callUpdateAccountDetailsService(JSONValue);
                }
                //call service method only if the list is not empty
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'AccountsHelper', 'saveAccountInformation', currentRecordID);
        }
    }

    public static Map<String, String> FieldChangedvalues(Account OldAccount, Map<String, String> newAccountValues) {
        Map<String, String> changedValues = new Map<String, String>();
        for (String fieldApi : newAccountValues.keySet()) {
            if (OldAccount.get(fieldApi) != newAccountValues.get(fieldApi)) {
                changedValues.put(fieldApi, newAccountValues.get(fieldApi));
            }
        }
        System.debug('changed Account Values ' + changedValues);
        return changedValues;
        //pavLoopRecord.put(f.getFieldPath(), selectedLTCourse.get(f.getFieldPath()));
    }

    public class SyncAccountDetailsWrapper {
        public String market { get; set; }
        public List<Map<String, Map<String, Map<String, String>>>> updatedAccountList { get; set; }
        public Map<String, String> ModifiedDetailsfieldValueMap { get; set; }

        public SyncAccountDetailsWrapper(List<Map<String, Map<String, Map<String, String>>>> updatedAccountList, Map<String, String> ModifiedDetailsfieldValueMap, String market) {
            this.updatedAccountList = updatedAccountList;
            this.ModifiedDetailsfieldValueMap = ModifiedDetailsfieldValueMap;
            this.market = market;
        }
    }
}