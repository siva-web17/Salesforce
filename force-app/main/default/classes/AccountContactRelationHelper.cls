/**
 * Created by arjun.mohan on 2/9/2018.
 */

public with sharing class AccountContactRelationHelper {

    public static List<Map<String, String>> validateAndSendDetailsToPoseidon(Map<Id, AccountContactRelation> AccountContactMap, String DMLType,Boolean IsComplicatedBooking) {
        Id MasterRecordId;
        List<Map<String, String>> updateAccountInfo = new List<Map<String, String>>();
        String market='';
        Set<Id> accountIdSet=new Set<Id>();
        List<Id> userIdList=new List<Id>();
        //system.debug('Inside validateAndSendDetailsToPoseidon');
        for (AccountContactRelation accountContactRecord : AccountContactMap.values()) {
            if(accountContactRecord.AccountContactID__c == null){
                continue;
            }
            accountIdSet.add(Id.valueOf(accountContactRecord.AccountContactID__c));
            userIdList.add(accountContactRecord.CreatedById);
            userIdList.add(accountContactRecord.LastModifiedById);
        }
        Map<Id,Account> accountmap=  AccountsSelector.getAccountDetailsbasedonAccountId(accountIdSet);

        Map<Id,User> UserMap= UsersHelper.getUserDetailsForUserIds(userIdList);
        for (AccountContactRelation accountContactRecord : AccountContactMap.values()) {
            Map<String, String> AccountContactrelationfieldValueMap = new Map<String, String>();
            if (accountContactRecord.TotalBooking__c > 0 || IsComplicatedBooking) {
                if(accountContactRecord.AccountContactID__c == null){
                    continue;
                }
                market=accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c))?accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).Market__c:'';
                //system.debug('Inside accountContactRecord.TotalBooking__c > 0)');
                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UpdatePersonalInfo.getFields()) {
                    if (accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c))) {
                        AccountContactrelationfieldValueMap.put(f.getFieldPath(), String.valueOf(accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).get(f.getFieldPath())));
                    }
                }
                if (AccountContactrelationfieldValueMap.size() > 0) {

                    AccountContactrelationfieldValueMap.put('Roles',String.valueOf(accountContactRecord.Roles));
                    if (UserMap.containsKey(accountContactRecord.CreatedById) && UserMap.containsKey(accountContactRecord.LastModifiedById)) {
                        AccountContactrelationfieldValueMap.put('CreatedBy',String.valueOf(UserMap.get(accountContactRecord.CreatedById).Email.substringBefore('@')));
                        AccountContactrelationfieldValueMap.put('LastModifiedBy',String.valueOf(UserMap.get(accountContactRecord.LastModifiedById).Email.substringBefore('@')));
                    }
                    else
                    {
                        AccountContactrelationfieldValueMap.put('CreatedBy','No User Found for :'+accountContactRecord.CreatedById);
                        AccountContactrelationfieldValueMap.put('CreatedBy','No User Found for :'+accountContactRecord.LastModifiedById);
                    }

                    AccountContactrelationfieldValueMap.put('CreatedDate',String.valueOf(accountContactRecord.CreatedDate));
                    AccountContactrelationfieldValueMap.put('LastModifiedDate',String.valueOf(accountContactRecord.LastModifiedDate));
                    AccountContactrelationfieldValueMap.put('AccountId', String.valueOf(accountContactRecord.AccountContactID__c));
                    AccountContactrelationfieldValueMap.put('DMLType', DMLType);
                    AccountContactrelationfieldValueMap.put('FirstName',  (accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c)))?accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).Firstname:'');
                    AccountContactrelationfieldValueMap.put('LastName', (accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c)))?accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).LastName:'');
                    AccountContactrelationfieldValueMap.put('MasterRecordId', String.valueOf(accountContactRecord.accountid));
                    updateAccountInfo.add(AccountContactrelationfieldValueMap);
                }

            }
        }
        if (updateAccountInfo.size() > 0) {
            //system.debug('Inside updateAccountInfo.size() > 0) ' +updateAccountInfo);
            SyncAccountRelationWrapper objSyncAccountRelationWrapper=new SyncAccountRelationWrapper(updateAccountInfo,market);
            String JSONValue= JSON.serialize(objSyncAccountRelationWrapper);
            //system.debug('Before Hitting service  ' +JSONValue);
            /*ExceptionHandler.errorLogAsync('Test Family Sync', JSONValue,
                    'AccountContactHelper', 'validateAndSendDetailsToPose*//*idon', MasterRecordId);*/
            if (!IsComplicatedBooking) {
                ExternalRouter.callUpdateAccountFamilyDetailsService(JSONValue);
            }
        }
        return updateAccountInfo;
    }

    public static void findAndDeleteReversRelations(List<AccountContactRelation> relations){
        Set<Id> relationIds = (new Map<Id, AccountContactRelation>(relations)).keySet();

        List<AccountContactRelation> detailedRelations = AccountContactRelationsSelector.getRelationsByIdsIncludingDeleted(relationIds);

        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation acr : detailedRelations){
            accountIds.add(acr.Contact.AccountId);
            contactIds.add(acr.Account.PersonContactId);
        }

        List<AccountContactRelation> reverseRelations = AccountContactRelationsSelector.getRelationsByAccountsAndContacts(accountIds, contactIds);
        if(reverseRelations.size() > 0){
            delete reverseRelations;
        }
    }

    public class SyncAccountRelationWrapper
    {
        public String market { get; set; }
        public List<Map<String, String>> updateAccountInfo { get; set; }

        public SyncAccountRelationWrapper(List<Map<String, String>> updateAccountInfo, String market) {
            this.updateAccountInfo = updateAccountInfo;
            this.market = market;
        }
    }
}