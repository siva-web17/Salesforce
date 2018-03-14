/**
 * Created by britenet-patrykzak on 12/03/2018.
 */

@IsTest
private class AccountContactRelationTriggerTest {

    @isTest
    static void When_DeleteOneAccountContactRelation_Expect_FindAndDeleteReverseRelation() {

        Test.setMock(HttpCalloutMock.class, new ExternalRouterMock());

        TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
        Account accPerson = (Account)pab.save().getRecord();
        Account accPerson2 = (Account)pab.build().save().getRecord();

        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        Opportunity testOpportunity = (Opportunity) opportunityBuilder.getRecord();
        testOpportunity.IsActive__c = true;
        testOpportunity.AccountId = accPerson.Id;
        insert testOpportunity;

        accPerson2 = [SELECT PersonContactId FROM Account Where Id =: accPerson2.Id LIMIT 1];
        accPerson = [SELECT PersonContactId FROM Account Where Id =: accPerson.Id LIMIT 1];

        Booking__c book = new Booking__c(AccountId__c = accPerson.Id,OpportunityId__c = testOpportunity.Id);
        insert book;

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

    @isTest
    static void When_UpdateAccountContactRelation_Expect_ExpectedBehavior() {

        String role = 'Other';

        TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
        Account accPerson = (Account)pab.save().getRecord();
        Account accPerson2 = (Account)pab.build().save().getRecord();

        accPerson2 = [SELECT PersonContactId FROM Account Where Id =: accPerson2.Id LIMIT 1];
        accPerson = [SELECT PersonContactId FROM Account Where Id =: accPerson.Id LIMIT 1];

        AccountContactRelation accContRelationParentToChild = new AccountContactRelation(AccountId = accPerson.Id, ContactId = accPerson2.PersonContactId, AccountContactID__c = accPerson2.Id, roles = 'Mother');

        insert accContRelationParentToChild;

        Test.startTest();

        accContRelationParentToChild.roles = role;
        update accContRelationParentToChild;

        Test.stopTest();

        AccountContactRelation accContRelationUpdated = [SELECT Id, Roles FROM AccountContactRelation WHERE Id =: accContRelationParentToChild.Id LIMIT 1];
        System.assertEquals(role,accContRelationUpdated.roles,'The role should be updated');
    }

    @isTest
    static void When_DeleteOneAccountContactRelationAndAccountContactIdIsNull_Expect_FindAndDeleteReverseRelation() {

        Test.setMock(HttpCalloutMock.class, new ExternalRouterMock());

        TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
        Account accPerson = (Account)pab.save().getRecord();
        Account accPerson2 = (Account)pab.build().save().getRecord();

        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        Opportunity testOpportunity = (Opportunity) opportunityBuilder.getRecord();
        testOpportunity.IsActive__c = true;
        testOpportunity.AccountId = accPerson.Id;
        upsert testOpportunity;

        accPerson2 = [SELECT PersonContactId FROM Account Where Id =: accPerson2.Id LIMIT 1];
        accPerson = [SELECT PersonContactId FROM Account Where Id =: accPerson.Id LIMIT 1];

        Booking__c book = new Booking__c(AccountId__c = accPerson.Id,OpportunityId__c = testOpportunity.Id);
        insert book;

        AccountContactRelation accContRelationParentToChild = new AccountContactRelation(AccountId = accPerson.Id, ContactId = accPerson2.PersonContactId, AccountContactID__c = null, roles = 'Mother');
        AccountContactRelation accContRelationChildToParent = new AccountContactRelation(AccountId = accPerson2.Id, ContactId = accPerson.PersonContactId, AccountContactID__c = null, roles = 'Child');

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