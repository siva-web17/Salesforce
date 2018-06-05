@isTest
private class EventsHelperTest{
    @testSetup static void setup(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            String campaignQAndA = '{"CampaignQuestionAnswer":[{"ExtraQuestion":[{"Question":"SchoolName","Answer":"English Championship 2018"},{"Question":"code","Answer":"Quam dolores architecto harum duis neque officia sint dolorum fugiat"}]},{"Question":"Vocabulary Score","Answer":"18"},{"Question":"Vocabulary Percentage","Answer":"A1"},{"Question":"Reading Percentage","Answer":"A1"},{"Question":"Reading Score","Answer":"18"},{"Question":"Listening Percentage","Answer":"A1"},{"Question":"Listening Score","Answer":"18"},{"Question":"Proficiency Level","Answer":"A1"},{"Question":"Total Percentage","Answer":"18"},{"Question":"Total Score","Answer":"18"},{"Question":"Result Level","Answer":"beginner"},{"Question":"Time Taken","Answer":"00:01:28"}]}';
            leadBuilder.setField('CampaignQuestionsAnswer__c',campaignQAndA);
            Lead lead = (Lead)leadBuilder.save().getRecord();
            Event event = new Event();
            event.WhoId = lead.Id;
            event.DurationInMinutes = 30;
            event.ActivityDateTime = DateTime.now();
            event.CampaignName__c = 'Sample';
            event.Type = 'CAM';
            insert event;
        }
    }

    @isTest
    static void testUpdateSubjectOnEvents(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Event event = [SELECT Id,Type,Program__c FROM Event WHERE Type = 'CAM' LIMIT 1];
            EventsHelper.updateSubjectOnEvents(new List<Event>{event});
        }
    }

    @isTest
    static void testCreateAttachmentForQuestionAnswers(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Event event = [SELECT Id FROM Event WHERE Type = 'CAM' LIMIT 1];
            EventsHelper.createAttachmentForQuestionAnswers(new list<Event>{event});
        }
    }

    @isTest
    static void testAddLeadOrContactAsCampaignMember(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Lead lead = [SELECT Id FROM Lead LIMIT 1];
            Map<String, String> campaignFields = new Map<String, String>{
                    'DateFrom__c'=>String.valueOf(DateTime.now().addminutes(1)),
                    'DateTo__c'=>String.valueOf(DateTime.now().addminutes(31)),
                    'MeetingType__c'=>'ONM'
            };

            Campaign campaign = TestDataFactory.createCampaign('Test Campaign',campaignFields,true);
            Campaign = [Select Id,CampaignID__c FROM Campaign];
            Event imEvent = new Event();
            imEvent.WhoId = lead.Id;
            imEvent.DurationInMinutes = 30;
            imEvent.ActivityDateTime = DateTime.now();
            imEvent.CampaignName__c = 'Sample';
            imEvent.InfoMeetingID__c = decimal.valueOf(campaign.CampaignID__c);
            imEvent.Type = 'IM';
            insert imEvent;

            EventsHelper.AddLeadOrContactAsCampaignMember(new list<Event>{imEvent});
        }
    }

    @isTest
    static void whenLeadsMergedThenReassignCustomerRequestEventsToOpportunity(){
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
            lc.setAccountId(personAccount.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Test.stopTest();

            //then
            Event event = [SELECT WhatId FROM Event WHERE Id = :eb.getRecord().Id];
            System.assertEquals(opportunityBuilder.getRecord().Id, event.WhatId);
        }
    }

    @isTest
    static void whenLeadsMergedThenReassignCustomerRequestEventsToNewlyCreatedOpportunity(){
        User adminUser = TestDataFactory.createAdminUser(true);
        System.runAs(adminUser) {
            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account personAccount = (Account)pab.save().getRecord();
            TestDataFactory.LeadBuilder lb = new TestDataFactory.LeadBuilder();
            Lead testLead = (Lead)lb.save().getRecord();
            TestDataFactory.EventBuilder eb = new TestDataFactory.EventBuilder();
            eb.setWho(testLead.Id);
            eb.withRecordType(Label.CustomerRequestEventRecordTypeDeveloperName);
            eb.save();

            //when
            Test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(testLead.Id);
            lc.setAccountId(personAccount.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Test.stopTest();

            //then
            Event event = [SELECT WhatId FROM Event WHERE Id = :eb.getRecord().Id];
            System.assertNotEquals(NULL, event.WhatId);
            Opportunity opportunity = [SELECT Id, IsActive__c FROM Opportunity WHERE Id = :event.WhatId];
            System.assert(opportunity.IsActive__c);
        }
    }
}