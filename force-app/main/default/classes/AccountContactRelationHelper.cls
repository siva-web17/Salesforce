/**
 * Created by arjun.mohan on 2/9/2018.
 */

public with sharing class AccountContactRelationHelper {

    public static void validateAndSendDetailsToPoseidon(Map<Id, AccountContactRelation> AccountContactMap, String DMLType) {
        Id MasterRecordId;
        List<Map<String, String>> updateAccountInfo = new List<Map<String, String>>();
        String market='DEB';
        for (AccountContactRelation accountContactRecord : AccountContactMap.values()) {
            Map<String, String> AccountContactrelationfieldValueMap = new Map<String, String>();
            if (accountContactRecord.TotalBooking__c > 0) {

                for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UpdatePersonalInfo.getFields()) {
                    AccountContactrelationfieldValueMap.put(f.getFieldPath(), String.valueOf(accountContactRecord.get(f.getFieldPath())));
                }
                if (AccountContactrelationfieldValueMap.size() > 0) {
                    AccountContactrelationfieldValueMap.put('CreatedById',String.valueOf(accountContactRecord.CreatedById));
                    AccountContactrelationfieldValueMap.put('CreatedDate',String.valueOf(accountContactRecord.CreatedDate));
                    AccountContactrelationfieldValueMap.put('LastModifiedById',String.valueOf(accountContactRecord.LastModifiedById));
                    AccountContactrelationfieldValueMap.put('LastModifiedDate',String.valueOf(accountContactRecord.LastModifiedDate));
                    AccountContactrelationfieldValueMap.put('AccountId', String.valueOf(accountContactRecord.AccountContactID__c));
                    AccountContactrelationfieldValueMap.put('DMLType', DMLType);
                    AccountContactrelationfieldValueMap.put('MasterRecordId', String.valueOf(accountContactRecord.accountid));
                    updateAccountInfo.add(AccountContactrelationfieldValueMap);
                }

            }
        }
        if (updateAccountInfo.size() > 0) {
            SyncAccountRelationWrapper objSyncAccountRelationWrapper=new SyncAccountRelationWrapper(updateAccountInfo,market);
            String JSONValue= JSON.serialize(objSyncAccountRelationWrapper);
            ExternalRouter.callUpdateAccountFamilyDetailsService(updateAccountInfo);
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