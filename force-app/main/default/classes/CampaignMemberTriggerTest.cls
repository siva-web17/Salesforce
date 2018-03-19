/**
 * Created by Arkadiusz Celej on 19.01.2018.
 */

@IsTest
private class CampaignMemberTriggerTest {

    @isTest
    static void whenCampaignMemberIsCreatedOpportunityIdShouldBePopulated() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {

            //given
            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            oppBuilder.withPersonAccount().save();
            Opportunity opp = (Opportunity)oppBuilder.getRecord();
            Account oppAccount = oppBuilder.getAccount();
            oppAccount = [
                SELECT PersonContactId
                FROM Account
                WHERE Id =:oppAccount.Id LIMIT 1
            ];
            Campaign testCampaign = (Campaign)(new TestDataFactory.CampaignBuilder()).save().getRecord();

            CampaignMember cm = new CampaignMember();
            cm.CampaignId = testCampaign.Id;
            cm.ContactId = oppAccount.PersonContactId;

            //when
            Test.startTest();
            insert cm;
            Test.stopTest();

            //then
            cm = [
                SELECT Opportunity__c
                FROM CampaignMember
                WHERE Id = :cm.Id
            ];
            System.assertEquals(opp.Id, cm.Opportunity__c);
        }
    }

    @isTest
    static void when_BatchInsertCampaignMember_Expect_OpportunityIdsShouldBePopulated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

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
            Map<Id, Account> accountsByIds = new Map<Id, Account>([
                SELECT PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE)
                FROM Account
                WHERE Id IN :accountIds
            ]);
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

            //then
            Set<Id> testMemberIds = (new Map<Id, CampaignMember>(testMembers)).keySet();
            testMembers = [SELECT Contact.AccountId, Opportunity__c FROM CampaignMember WHERE Id IN :testMemberIds];
            for(CampaignMember cm: testMembers) {
                Account acc = accountsByIds.get(cm.Contact.AccountId);
                System.assertEquals(acc.Opportunities[0].Id, cm.Opportunity__c);
            }
        }
    }

    @isTest
    static void When_LeadIsConverted_Expect_CampaignMemberOpportunityIsSet(){

        User adminUser = TestDataFactory.createAdminUser(true);
        System.runAs(adminUser){

            //Given
            TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Lead testLead = new Lead();

            testLead = (Lead)leadBuilder.build().getRecord();
            List<Lead> testLeadsList = new List<Lead>();
            testLeadsList.add(testLead);
            insert testLeadsList;

            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(testLead.Id);

            LeadStatus convertStatus = [
                    SELECT Id, MasterLabel
                    FROM LeadStatus
                    WHERE IsConverted = TRUE
                    LIMIT 1
            ];

            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            testLeadsList = [
                    SELECT IsConverted, ConvertedOpportunityId
                    FROM Lead LIMIT 1
            ];

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            oppBuilder.withPersonAccount().save();
            Account oppAccount = oppBuilder.getAccount();
            oppAccount = [
                    SELECT PersonContactId
                    FROM Account
                    WHERE Id =:oppAccount.Id LIMIT 1
            ];
            Campaign testCampaign = (Campaign)(new TestDataFactory.CampaignBuilder()).getRecord();
            insert testCampaign;

            List<Campaign> campList = new List<Campaign>();
            campList.add(testCampaign);

            CampaignMember cm = new CampaignMember(
                    CampaignId = testCampaign.Id,
                    ContactId = oppAccount.PersonContactId,
                    LeadId = testLeadsList[0].Id
            );
            insert cm;

            //When
            Test.startTest();
            CampaignMembersHelper.addOppToIMOnLeadConvert(testLeadsList);
            Test.stopTest();

            //Then
            cm = [
                    SELECT Opportunity__c
                    FROM CampaignMember LIMIT 1
            ];
            System.assertEquals(testLeadsList[0].ConvertedOpportunityId, cm.Opportunity__c);
        }
    }
}