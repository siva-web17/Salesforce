/**
 * Created by arjun.mohan on 2/12/2018.
 */

public class AccountContactRelationsSelector {

    public Static Map<Id, AccountContactRelation> getAccountContactRelationForAccountId(List<Id> AccountIdList) {
        Map<Id, AccountContactRelation> accountContactRelationMap = new Map<Id, AccountContactRelation>();
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        accountContactRelationList = [Select Id,AccountId,ContactId,Roles,AccountContactId__c,CreatedById,LastModifiedById,TotalBooking__c,CreatedDate,LastModifiedDate,IsParentSynchedToPoseidon__c from AccountContactRelation Where AccountId in :AccountIdList];
        for (AccountContactRelation accountContactRecord : accountContactRelationList) {
            accountContactRelationMap.put(accountContactRecord.Id, accountContactRecord);
        }
        return accountContactRelationMap;
    }

    public Static Map<Id, AccountContactRelation> getAccountContactRelationForFamilyAccountId(List<Id> AccountIdList) {
        Map<Id, AccountContactRelation> accountContactRelationMap = new Map<Id, AccountContactRelation>();
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        accountContactRelationList = [Select Id,AccountId,ContactId,Roles,AccountContactId__c,CreatedById,LastModifiedById,TotalBooking__c,CreatedDate,LastModifiedDate,IsParentSynchedToPoseidon__c from AccountContactRelation Where AccountContactId__c in :AccountIdList and IsParentSynchedToPoseidon__c = TRUE];
        for (AccountContactRelation accountContactRecord : accountContactRelationList) {
            accountContactRelationMap.put(accountContactRecord.Id, accountContactRecord);
        }
        return accountContactRelationMap;
    }

    public static List<AccountContactRelation> getRelationsByAccountsAndContacts(Set<Id> accountIds, Set<Id> contactIds) {
        return [
                SELECT Id, AccountId, ContactId
                FROM AccountContactRelation
                WHERE AccountId IN :accountIds AND ContactId IN :contactIds
        ];
    }

    public static List<AccountContactRelation> getRelationsByIdsIncludingDeleted(Set<Id> relationIds) {
        return [
                SELECT Id, AccountId, ContactId, Account.PersonContactId, Contact.AccountId
                FROM AccountContactRelation
                WHERE Id IN :relationIds
                ALL ROWS
        ];
    }

}