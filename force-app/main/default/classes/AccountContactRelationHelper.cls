/**
 * Created by arjun.mohan on 2/9/2018.
 */

public with sharing class AccountContactRelationHelper {

    public static void validateAndSendDetailsToPoseidon(Map<Id, AccountContactRelation> AccountContactMap, String DMLType,Boolean IsComplicatedBooking) {
        Id MasterRecordId;
        List<Map<String, String>> updateAccountInfo = new List<Map<String, String>>();
        String market='';
        Set<Id> accountIdSet=new Set<Id>();
        List<Id> userIdList=new List<Id>();
        system.debug('Inside validateAndSendDetailsToPoseidon');
        for (AccountContactRelation accountContactRecord : AccountContactMap.values()) {
            accountIdSet.add(Id.valueOf(accountContactRecord.AccountContactID__c));
            userIdList.add(accountContactRecord.CreatedById);
            userIdList.add(accountContactRecord.LastModifiedById);
        }
        Map<Id,Account> accountmap=  AccountsSelector.getAccountDetailsbasedonAccountId(accountIdSet);

        Map<Id,User> UserMap= UsersHelper.getUserDetailsForUserIds(userIdList);
        for (AccountContactRelation accountContactRecord : AccountContactMap.values()) {
            Map<String, String> AccountContactrelationfieldValueMap = new Map<String, String>();
            if (accountContactRecord.TotalBooking__c > 0 || IsComplicatedBooking) {
                market=accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c))?accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).Market__c:'';
                system.debug('Inside accountContactRecord.TotalBooking__c > 0)');
                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UpdatePersonalInfo.getFields()) {
                    if (accountmap.containsKey(Id.valueOf(accountContactRecord.AccountContactID__c))) {
                        AccountContactrelationfieldValueMap.put(f.getFieldPath(), String.valueOf(accountmap.get(Id.valueOf(accountContactRecord.AccountContactID__c)).get(f.getFieldPath())));
                    }
                }
                if (AccountContactrelationfieldValueMap.size() > 0) {

                    AccountContactrelationfieldValueMap.put('Roles',String.valueOf(accountContactRecord.Roles));
                    if (UserMap.containsKey(accountContactRecord.CreatedById) && UserMap.containsKey(accountContactRecord.LastModifiedById)) {
                        AccountContactrelationfieldValueMap.put('CreatedBy',String.valueOf(UserMap.get(accountContactRecord.CreatedById).Name));
                        AccountContactrelationfieldValueMap.put('LastModifiedBy',String.valueOf(UserMap.get(accountContactRecord.LastModifiedById).Name));
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
                    AccountContactrelationfieldValueMap.put('MasterRecordId', String.valueOf(accountContactRecord.accountid));
                    updateAccountInfo.add(AccountContactrelationfieldValueMap);
                }

            }
        }
        if (updateAccountInfo.size() > 0) {
            system.debug('Inside updateAccountInfo.size() > 0) ' +updateAccountInfo);
            SyncAccountRelationWrapper objSyncAccountRelationWrapper=new SyncAccountRelationWrapper(updateAccountInfo,market);
            String JSONValue= JSON.serialize(objSyncAccountRelationWrapper);
            system.debug('Before Hitting service  ' +JSONValue);
            ExternalRouter.callUpdateAccountFamilyDetailsService(JSONValue);
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