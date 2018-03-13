/**
 * Created by britenet-patrykzak on 12/03/2018.
 */

@IsTest
private class AccountContactRelationTriggerTest {
    static testMethod void When_DeleteOneAccountContactRelation_Expect_FindAndDeleteReverseRelation() {
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Account');
        Map<String,RecordType> recordtypeMap = RecordTypesSelector.getActiveRecTypesByDevName(convertType);
        System.debug(recordtypeMap);
        Id personAccountRecordType = recordtypeMap.get('PersonAccount').Id;

        Account accPerson = new Account(recordTypeId = personAccountRecordType,FirstName = 'Patryk',LastName = 'Zak');
        insert accPerson;

        Account accPerson2 = new Account(recordTypeId = personAccountRecordType,FirstName = 'Patryyk',LastName = 'Zaak');
        insert accPerson2;

        accPerson2 = [SELECT PersonContactId FROM Account Where Id =: accPerson2.Id LIMIT 1];
        accPerson = [SELECT PersonContactId FROM Account Where Id =: accPerson.Id LIMIT 1];

        AccountContactRelation accContRelationParentToChild = new AccountContactRelation(AccountId = accPerson.Id, ContactId = accPerson2.PersonContactId, AccountContactID__c = accPerson2.Id, roles = 'Mother');
        AccountContactRelation accContRelationChildToParent = new AccountContactRelation(AccountId = accPerson2.Id, ContactId = accPerson.PersonContactId, AccountContactID__c = accPerson.Id, roles = 'Child');

        insert accContRelationParentToChild;
        insert accContRelationChildToParent;

        Test.startTest();

        List<AccountContactRelation> accContRelationListBeforeDelete = [SELECT Id FROM AccountContactRelation];
        delete accContRelationChildToParent;

        Test.stopTest();

        List<AccountContactRelation> accContRelationList = [SELECT Id FROM AccountContactRelation];
        System.assertEquals(2,accContRelationListBeforeDelete.size(),'There should be 2 Relation Records');
        System.assertEquals(0,accContRelationList.size(),'There should be 0 Relation Records');
    }
}