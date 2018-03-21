/**
 * Created by Arkadiusz Celej on 04.01.2018.
 */

@IsTest
private class AccountTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void whenDateOfBirthOrLanguageChangeResetLetterAndLabelOnOpportunity() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            //given
            TestDataFactory.TemplateSettingBuilder templateSettingBuilder = new TestDataFactory.TemplateSettingBuilder();
            TemplateSetting__c ts = (TemplateSetting__c) templateSettingBuilder.getRecord();
            ts.Market__c = picklistValuesHelper.market;
            ts.Program__c = picklistValuesHelper.program;
            ts.Language__c = picklistValuesHelper.language;
            templateSettingBuilder.withAge(10);
            templateSettingBuilder.withLetter();
            templateSettingBuilder.withLabel();
            templateSettingBuilder.save();
            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = (Opportunity) oppBuilder.getRecord();
            opp.Market__c = picklistValuesHelper.market;
            opp.SalesOffice__c = picklistValuesHelper.salesOffice;
            opp.Program__c = picklistValuesHelper.program;
            opp.Product__c = picklistValuesHelper.product;
            oppBuilder.withPersonAccount();
            oppBuilder.getAccount().Language__c = picklistValuesHelper.language;
            oppBuilder.save();

            Account personAccount = oppBuilder.getAccount();
            TestDataFactory.TaskBuilder sbrTaskBuilder = new TestDataFactory.TaskBuilder();
            sbrTaskBuilder.withRecordType(TasksHelper.SBR_TASK_DEVELOPER_NAME);
            sbrTaskBuilder.setWhat(oppBuilder.getRecord().Id);
            sbrTaskBuilder.save();
            //when
            Test.startTest();
            personAccount.PersonBirthdate = System.today().addYears(-10);

            update personAccount;
            Test.stopTest();
            //then

            opp = [SELECT Id, Letter__c, Label__c FROM Opportunity WHERE Id = :oppBuilder.getRecord().Id];
            System.assertEquals(templateSettingBuilder.templateLetter.Id, opp.Letter__c, 'Invalid Letter');
            System.assertEquals(templateSettingBuilder.templateLabel.Id, opp.Label__c, 'Invalid Label');
        }
    }

    @isTest
    static void whenAccountHasInactiveOpportunityThenSkipSaveToPoseidonCall(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            ob.withPersonAccount();
            ob.setField('IsActive__c', false);
            ob.save();
            Account personAccount = ob.getAccount();

            Test.startTest();
            try {
                Booking__c book = new Booking__c(AccountId__c = personAccount.Id, OpportunityId__c = ob.getRecord().Id);
                insert book;
                personAccount.FirstName = personAccount.FirstName + 'ChangedName';
                update personAccount;
                System.assert(false);
            }catch (Exception ex){
                String message = ex.getMessage();
                System.assert(message.contains(Label.NoActiveOpportunity));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void whenAccountHasActiveOpportunityThenCallSaveToPoseidon(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ExternalRouterMock());
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            ob.withPersonAccount().save();
            Account personAccount = ob.getAccount();
            Booking__c book = new Booking__c(AccountId__c = personAccount.Id, OpportunityId__c = ob.getRecord().Id);
            insert book;

            Test.startTest();
            personAccount.FirstName = personAccount.FirstName+'ChangedName';
            personAccount.PersonMailingStreet = 'NewStreet';
            personAccount.InvalidEmail__c = true;
            update personAccount;
            Test.stopTest();
        }
    }


    @isTest
    static void whenAccountsMergedThenReassignCustomerRequestEventsToOpportunity(){
        User adminUser = TestDataFactory.createAdminUser(true);
        System.runAs(adminUser) {
            //given
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            opportunityBuilder.withPersonAccount().save();
            Account personAccount = opportunityBuilder.getAccount();
            TestDataFactory.LeadBuilder lb = new TestDataFactory.LeadBuilder();
            Lead testLead = (Lead)lb.save().getRecord();
            TestDataFactory.EventBuilder eb = new TestDataFactory.EventBuilder();
            eb.setWho(testLead.Id).save();

            //when
            Test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(testLead.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            merge personAccount lcr.getAccountId();
            Test.stopTest();

            //then
            Event event = [SELECT WhatId FROM Event WHERE Id = :eb.getRecord().Id];
            System.assertEquals(opportunityBuilder.getRecord().Id, event.WhatId);
        }
    }
}