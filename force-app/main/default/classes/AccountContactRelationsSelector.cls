/**
 * Created by arjun.mohan on 2/12/2018.
 */

public  class AccountContactRelationsSelector {

    public Static Map<Id,AccountContactRelation> getAccountContactRelationForAccountId(List<Id> AccountIdList)
    {
        Map<Id,AccountContactRelation> accountContactRelationMap=new Map<Id,AccountContactRelation>();
        List<AccountContactRelation> accountContactRelationList=new List<AccountContactRelation>();
        accountContactRelationList=[Select Id,AccountId,ContactId,Roles,AccountContactId__c,CreatedById,LastModifiedById,TotalBooking__c,CreatedDate,LastModifiedDate from AccountContactRelation Where AccountId in : AccountIdList];
        for (AccountContactRelation accountContactRecord:accountContactRelationList) {
            accountContactRelationMap.put(accountContactRecord.Id,accountContactRecord);
        }
        return accountContactRelationMap;
    }

}