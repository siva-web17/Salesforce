/**
 * Created by Arkadiusz Celej on 19.01.2018.
 */

@IsTest
private class CampaignMemberTriggerTest {
    static testMethod void whenCampaignMemberIsCreatedOpportunityIdShouldBePopulated() {

        //given
        TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
        oppBuilder.withPersonAccount().save();
        Opportunity opp = (Opportunity)oppBuilder.getRecord();
        Account oppAccount = oppBuilder.getAccount();
        oppAccount = [SELECT PersonContactId FROM Account WHERE Id =:oppAccount.Id LIMIT 1];
        Campaign testCampaign = (Campaign)(new TestDataFactory.CampaignBuilder()).save().getRecord();

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = testCampaign.Id;
        cm.ContactId = oppAccount.PersonContactId;
        //when

        Test.startTest();
        insert cm;
        Test.stopTest();
        //then
        cm = [SELECT Opportunity__c FROM CampaignMember WHERE Id = :cm.Id];
        System.assertEquals(opp.Id, cm.Opportunity__c);
    }

    static testMethod void whenCampaignMemberIsCreatedOpportunityIdShouldBePopulatedForMultipleRecords() {
        //given
        Integer numberOfRecords = 200;
        Opportunity[] opportunities = new Opportunity[]{};
        Account[] accounts = new Account[]{};

        TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
        for(Integer i = 0 ; i < numberOfRecords; i++){
            oppBuilder.withPersonAccount();
            opportunities.add((Opportunity)oppBuilder.getRecord());
            accounts.add(oppBuilder.getAccount());
            oppBuilder.build();
        }
        insert accounts;
        for(Integer i = 0 ; i < numberOfRecords; i++){
            opportunities[i].AccountId = accounts[i].Id;
        }
        insert opportunities;
        Set<Id> accountIds = (new Map<Id, Account>(accounts)).keySet();
        Map<Id, Account> accountsByIds = new Map<Id, Account>([SELECT PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE) FROM Account WHERE Id IN :accountIds]);
        accounts = accountsByIds.values();
        Campaign testCampaign = (Campaign)(new TestDataFactory.CampaignBuilder()).save().getRecord();

        CampaignMember[] testMembers = new CampaignMember[]{};

        for(Integer i = 0 ; i < numberOfRecords; i++) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = testCampaign.Id;
            cm.ContactId = accounts[i].PersonContactId;
            testMembers.add(cm);
        }
        //when

        Test.startTest();
        insert testMembers;
        Test.stopTest();
        Set<Id> testMemberIds = (new Map<Id, CampaignMember>(testMembers)).keySet();
        //then
        testMembers = [SELECT Contact.AccountId, Opportunity__c FROM CampaignMember WHERE Id IN :testMemberIds];
        for(CampaignMember cm: testMembers) {
            Account acc = accountsByIds.get(cm.Contact.AccountId);
            System.assertEquals(acc.Opportunities[0].Id, cm.Opportunity__c);
        }
    }
}