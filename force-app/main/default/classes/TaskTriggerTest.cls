/**
 * Created by Arkadiusz Celej on 08-dec-2017.
 */

@IsTest
private class TaskTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void shouldUpdateTaskOpportunityFieldBrochuresToSend() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 200;
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.withRecordType(Label.SBRTask).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.WhatId = opportunities[i].Id;
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when
            Test.startTest();
            Id[] opportunityIds = new List<Id>();

            Task[] newTasks = new Task[]{};
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.withRecordType(Label.SBRTask).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program2;
                t.IsUp__c = true;
                t.IsJunior__c = true;
                t.FalseBrochureProgramCodes__c = picklistValuesHelper.program2;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                newTasks.add(t);
                taskBuilder.build();
            }
            insert newTasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{TasksHelper.SBR_TASK_DEVELOPER_NAME});

            for(Opportunity opp : opportunities) {
                System.assertEquals(true, opp.BrochuresToSend__c.contains(picklistValuesHelper.program) && opp.BrochuresToSend__c.contains(picklistValuesHelper.program2));
                System.assertEquals(true, opp.BrochuresToSend__c.contains('UP'));
                System.assertEquals(true, opp.BrochuresToSend__c.contains('JU'));
            }
        }
    }

    @isTest
    static  void shouldUpdateTaskOpportunityFieldSendBrochures() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 10;
            Id[] opportunityIds = new List<Id>();
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.SBRTask).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.FalseBrochureProgramCodes__c = picklistValuesHelper.program2;
                t.IsUp__c = true;
                t.IsJunior__c = true;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                t.TaskResult__c = TasksHelper.SENT_BROCHURE;
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when

            String closeTaskStatus = tasks[0].Status;

            Test.startTest();
            for(Integer i = 0; i < numOfOpps; i++){
                tasks[i].Status = closeTaskStatus;
            }
            update tasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{TasksHelper.SBR_TASK_DEVELOPER_NAME});

            for(Opportunity opp : opportunities) {
                System.assertEquals(true, opp.SentBrochures__c.contains(picklistValuesHelper.program));
                System.assertEquals(true, opp.SentBrochures__c.contains('UP'));
                System.assertEquals(true, opp.SentBrochures__c.contains('JU'));
            }
        }
    }

    @isTest
    static void whenNoCallsMadeNumberOfCallsOnOpportunityShouldBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 10;
            Id[] opportunityIds = new List<Id>();
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.SystemCallTaskRecordTypeDeveloperName).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when
            String closeTaskStatus = tasks[0].Status;

            Test.startTest();
            for(Integer i = 0; i < numOfOpps; i++){
                tasks[i].Status = closeTaskStatus;
            }
            update tasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{});

            for(Opportunity opp : opportunities) {
                System.assertEquals(0, opp.NumberOfCalls__c);
            }
        }
    }

    @isTest
    static void whenCallsMadeNumberOfCallsOnOpportunityShouldNotBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 10;
            Id[] opportunityIds = new List<Id>();
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when

            String closeTaskStatus = tasks[0].Status;

            Test.startTest();
            for(Integer i = 0; i < numOfOpps; i++){
                tasks[i].Status = closeTaskStatus;
            }
            update tasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{});

            for(Opportunity opp : opportunities) {
                System.assertEquals(1, opp.NumberOfCalls__c);
            }
        }
    }

    @isTest
    static  void whenNoCallsMadeNumberOfCallsOnLeadShouldBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfLeads = 10;
            Id[] leadIds = new List<Id>();
            Lead[] leads = new Lead[]{};
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Lead lead = (Lead)leadBuilder.getRecord();
                leads.add(lead);
                leadBuilder.build();
            }
            insert leads;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.SystemCallTaskRecordTypeDeveloperName).getRecord();
                t.WhoId = leads[i].Id;
                leadIds.add(leads[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when

            String closeTaskStatus = tasks[0].Status;

            Test.startTest();
            for(Integer i = 0; i < numOfLeads; i++){
                tasks[i].Status = closeTaskStatus;
            }
            update tasks;
            Test.stopTest();
            //then
            leads = LeadsSelector.getLeadsByIdsWithTasks(leadIds);

            for(Lead l : leads) {
                System.assertEquals(0, l.NumberOfCalls__c);
            }
        }
    }

    @isTest
    static void whenCallsMadeNumberOfCallsOnLeadShouldNotBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfLeads = 10;
            Id[] leadIds = new List<Id>();
            Lead[] leads = new Lead[]{};
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Lead lead = (Lead)leadBuilder.getRecord();
                leads.add(lead);
                leadBuilder.build();
            }
            insert leads;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
                t.WhoId = leads[i].Id;
                leadIds.add(leads[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            //when

            String closeTaskStatus = tasks[0].Status;

            Test.startTest();
            for(Integer i = 0; i < numOfLeads; i++){
                tasks[i].Status = closeTaskStatus;
            }
            update tasks;
            Test.stopTest();
            //then
            leads = LeadsSelector.getLeadsByIdsWithTasks(leadIds);

            for(Lead l : leads) {
                System.assertEquals(1, l.NumberOfCalls__c);
            }
        }
    }

    /**
     * Consecutive call unreached counter tests
     */

    @isTest
    static void whenCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldBeOne() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 10;
            Id[] opportunityIds = new List<Id>();
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
                t.SalesAction__c = Label.CallNotReached;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }

            //when
            Test.startTest();
            insert tasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{});

            for(Opportunity opp : opportunities) {
                System.assertEquals(1, opp.NumberOfUnreachedCalls__c);
            }
        }
    }

    @isTest
    static void whenConsecutiveCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldNotBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = (Opportunity) opportunityBuilder.withPersonAccount().save().getRecord();

            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();

            Task t = (Task) taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
            t.SalesAction__c = Label.CallNotReached;
            t.WhatId = opp.Id;
            //when
            insert t;
            Opportunity updatedOpportunity = [SELECT NumberOfUnreachedCalls__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
            System.assertEquals(1, updatedOpportunity.NumberOfUnreachedCalls__c);

            taskBuilder.build();
            t = (Task) taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
            t.SalesAction__c = Label.CallNotReached;
            t.WhatId = opp.Id;
            insert t;
            updatedOpportunity = [SELECT NumberOfUnreachedCalls__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
            System.assertEquals(2, updatedOpportunity.NumberOfUnreachedCalls__c);

            taskBuilder.build();
            t = (Task) taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
            t.SalesAction__c = Label.CallReached;
            t.WhatId = opp.Id;
            insert t;
            updatedOpportunity = [SELECT NumberOfUnreachedCalls__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
            System.assertEquals(0, updatedOpportunity.NumberOfUnreachedCalls__c);
        }
    }

    @isTest
    static void whenCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldBeZero() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            //given
            Integer numOfOpps = 10;
            Id[] opportunityIds = new List<Id>();
            Opportunity[] opportunities = new Opportunity[]{};
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;

            Task[] tasks = new Task[]{};
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Task t = (Task)taskBuilder.closeTask().withRecordType(Label.CallTaskRecordTypeDeveloperName).getRecord();
                t.SalesAction__c = Label.CallReached;
                t.WhatId = opportunities[i].Id;
                opportunityIds.add(opportunities[i].Id);
                tasks.add(t);
                taskBuilder.build();
            }

            //when
            Test.startTest();
            insert tasks;
            Test.stopTest();
            //then
            opportunities = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(opportunityIds, new Set<String>{});

            for(Opportunity opp : opportunities) {
                System.assertEquals(0, opp.NumberOfUnreachedCalls__c);
            }
        }
    }

    @isTest
    static void testConvertActivitiesToTask(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            List<Event> eventRecords = Test.loadData(Event.sObjectType, 'FileEventRecords');
            system.debug('eventRecords>>>'+eventRecords);
            List<Event> eventlist = new List<Event>();
            List<Account> accountList = new List<Account>();
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB'
            };
            Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);

            string dateValue = string.valueof(System.today().addDays(3));
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'SalesOffice__c' =>'DEB',
                    'Program__c' => 'AY',
                    'StageName' => System.Label.LeadStageWon,
                    'Closedate' => dateValue,
                    'TimeOutDate__c'=> dateValue

            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);
            system.debug('newOpportunityPersonAccount>>>'+newOpportunityPersonAccount);

            for(Event evtRecord: eventRecords){
                evtRecord.whatId=newOpportunityPersonAccount.id;
                eventlist.add(evtRecord);
            }
            update eventlist;
        }
    }

    @isTest
    static void testConvertActivitiesToTaskOppStageBooking(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            Map<String,TaskSetting__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada();
            List<Event> eventRecords = Test.loadData(Event.sObjectType, 'FileEventRecords');
            system.debug('eventRecords>>>'+eventRecords);
            List<Event> eventlist = new List<Event>();
            List<Account> accountList = new List<Account>();

            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
            Boolean input =TRUE;
            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'PersonMailingStreet'=>'Ulsoor',
                    'PersonMailingCity'=>'Bang',
                    'PersonMailingCountry'=>'Germany',
                    'PersonHomePhone'=>'7965415341',
                    'PersonEmail'=>'test@rg.com'
            };
            Account accountRecord = TestDataFactory.createPersonAccount('testname', 'TestAccountName', recordTypeId, personAccountFieldValues, TRUE);
            accountRecord=[select id,hasaddress__c, personmailingstreet,personmailingpostalcode,HadAddressonCreation__c from account where id =: accountRecord.id];

            string dateValue = string.valueof(System.today().addDays(3));
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'SalesOffice__c' =>'DEB',
                    'Program__c' => 'AY',
                    'StageName' => system.label.OpportunityBookingStage,
                    'Closedate' => dateValue,
                    'TimeOutDate__c'=> dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccountPerson(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True, True);
            Opportunity opprec =[select id,SendBrochure__c, Account.hasaddress__c from opportunity where id =: newOpportunityPersonAccount.id];

            for(Event evtRecord: eventRecords){
                evtRecord.whatId=opprec.id;
                eventlist.add(evtRecord);
            }
            update eventlist;
            system.debug('eventlist>>>'+eventlist);

            Set<Id> eventIds =  new set<Id>();
            for(Event eventRec: eventList){
                eventIds.add(eventRec.Id);
            }

            List<Task> taskList = [select id, Program__c,TaskSubtype,Type,IsExpressCall__c, whatId from task where EventId__c in :eventIds];

            Event imEvent = new Event();
            imEvent.WhatID = opprec.Id;
            imEvent.DurationInMinutes = 30;
            imEvent.ActivityDateTime = DateTime.now();
            imEvent.program__c='ILSP';
            imEvent.Type = 'BR';
            insert imEvent;
        }
    }

    @isTest
    static void testConvertActivitiesToTaskSBR(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            Map<String,TaskSetting__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada();
            List<Event> eventRecords = Test.loadData(Event.sObjectType, 'FileEventRecords');
            system.debug('eventRecords>>>'+eventRecords);
            List<Event> eventlist = new List<Event>();

            List<Account> accountList = new List<Account>();
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
            Boolean input =TRUE;
            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'PersonMailingStreet'=>'Ulsoor',
                    'PersonMailingCity'=>'Bang',
                    'PersonMailingCountry'=>'Germany',
                    'PersonHomePhone'=>'7965415341',
                    'PersonEmail'=>'test@rg.com'
            };
            Account accountRecord = TestDataFactory.createPersonAccount('testname', 'TestAccountName', recordTypeId, personAccountFieldValues, TRUE);
            accountRecord=[select id,hasaddress__c, personmailingstreet,personmailingpostalcode,HadAddressonCreation__c from account where id =: accountRecord.id];


            string dateValue = string.valueof(System.today().addDays(3));
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'SalesOffice__c' =>'DEB',
                    'Program__c' => 'AY',
                    'StageName' => system.label.LeadStageFollowup,
                    'Closedate' => dateValue,
                    'TimeOutDate__c'=> dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccountPerson(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True, True);
            Opportunity opprec =[select id,SendBrochure__c, Account.hasaddress__c from opportunity where id =: newOpportunityPersonAccount.id];

            for(Event evtRecord: eventRecords){
                evtRecord.whatId=opprec.id;
                eventlist.add(evtRecord);
            }
            update eventlist;

            Set<Id> eventIds =  new set<Id>();
            for(Event eventRec: eventList){
                eventIds.add(eventRec.Id);
            }


            Event imEvent = new Event();
            imEvent.WhatID = opprec.Id;
            imEvent.DurationInMinutes = 30;
            imEvent.ActivityDateTime = DateTime.now();
            imEvent.program__c='ILSP';
            imEvent.Type = 'BR';
            insert imEvent;
        }
    }

    @isTest
    static void testActivitiesToTaskonLead(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            Map<String,TaskSetting__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada();
            List<Event> eventRecords = Test.loadData(Event.sObjectType, 'FileEventRecords');
            system.debug('eventRecords>>>'+eventRecords);

            List<Event> eventlist = new List<Event>();


            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
            List<Lead> leadlist = new List<Lead>();
            Map<String, String> leadFieldValues = new Map<String, String>{
                    'program__c' => 'AY',
                    'Market__c' => 'DEB',
                    'SalesOffice__c'=>'DEB',
                    'Email'=>'record@ef.com'
            };
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '',leadFieldValues, true);
            newLead=[select id, program__c from Lead];
            leadlist.add(newLead);


            for(Event evtRecord: eventRecords){
                evtRecord.whoId=newLead.id;
                eventlist.add(evtRecord);
            }
            update eventlist;

            Event imEvent = new Event();
            imEvent.WhoID = newLead.Id;
            imEvent.DurationInMinutes = 30;
            imEvent.ActivityDateTime = DateTime.now();
            imEvent.program__c='ILSP';
            imEvent.Type = 'BR';
            insert imEvent;

        }
    }

    @IsTest
    static void when_TaskIsCreated_Expect_SubjectIsPopulated(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_1:
        //New Task is created
        //Task.SalesAction__c IS NOT blank

        String testSalesAction = 'Call Reached';
        String testProgram = 'AY';
        String testNewSubject = testSalesAction + ' - ' + testProgram;
        Integer numOfTasks = 5;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            for(Integer i = 0; i<numOfTasks; i++){
                Task t = new Task(
                        Program__c = testProgram,
                        SalesAction__c = testSalesAction
                );
                tasks.add(t);
            }

            for(Task task : tasks){
                System.assertNotEquals(testNewSubject, task.Subject, 'Expecting Task Subject is not set before inserting');
            }

            //when
            Test.startTest();
                insert tasks;
            Test.stopTest();

            //then
            tasks = [SELECT Subject FROM Task];
            for(Task task : tasks){
                System.assertEquals(testNewSubject, task.Subject, 'Expecting new Task Subject matches pattern: <SalesAction__c> - <Program__c>');
            }
        }
    }

    @IsTest
    static void when_TaskIsCreated_Expect_HyphenAndProgramIsAddedToSubject(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_2:
        //New Task is created
        //Task.SalesAction__c IS blank
        //Task subject IS NOT null
        //Task subject does not contain '-' (hyphen)

        String testSubject = 'Some Test Subject';
        String testProgram = 'AY';
        String testNewSubject = testSubject + ' - ' + testProgram;
        Integer numOfTasks = 5;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            for(Integer i = 0; i<numOfTasks; i++){
                Task t = new Task(
                        Program__c = testProgram,
                        Subject = testSubject
                );
                tasks.add(t);
            }

            for(Task task : tasks){
                System.assertNotEquals(testNewSubject, task.Subject, 'Expecting program is not added to subject before inserting');
            }

            //when
            Test.startTest();
            insert tasks;
            Test.stopTest();

            //then
            tasks = [SELECT Subject FROM Task];
            for(Task task : tasks){
                System.assertEquals(testNewSubject, task.Subject, 'Expecting new Task Subject matches pattern: <current subject> - <Program__c>');
            }
        }
    }

    @IsTest
    static void when_TaskIsCreated_Expect_SubjectIsNotChanged(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_3:
        //New Task is created
        //Task.SalesAction__c IS blank
        //Task subject is NULL (t1) or Task Subject contain '-' (hyphen) (t2)

        String testSubject = 'Some test subject with hyphen -';
        String testProgram = 'AY';

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            Task t1 = new Task(
                    Program__c = testProgram
            );
            Task t2 = new Task(
                    Program__c = testProgram,
                    Subject = testSubject
            );
            tasks.add(t1);
            tasks.add(t2);

            System.assertEquals(null, t1.Subject, 'Checking if subject is set properly');
            System.assertEquals(testSubject, t2.Subject, 'Checking if subject is set properly');

            //when
            Test.startTest();
            insert tasks;
            Test.stopTest();

            //then
            Integer taskWithNullSubject = [SELECT Count() FROM Task WHERE Subject = null];
            System.assertEquals(1, taskWithNullSubject, 'Expecting task subject is not changed');

            List<Task> taskWithHyphenInSubject = [SELECT Subject FROM Task WHERE Subject != null];
            System.assertEquals(testSubject,taskWithHyphenInSubject[0].Subject, 'Expecting task subject is not changed');
        }
    }

    @IsTest
    static void when_TaskIsUpdated_Expect_SubjectIsPopulated(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_4:
        //Existing Task is modified
        //Field Task.SalesAction__c is changed

        String testSalesAction = 'Call Reached';
        String testNewSalesAction = 'Called Us';
        String testProgram = 'AY';
        String testNewSubject = testNewSalesAction + ' - ' + testProgram;
        Integer numOfTasks = 5;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            for(Integer i = 0; i<numOfTasks; i++){
                Task t = new Task(
                        Program__c = testProgram,
                        SalesAction__c = testNewSalesAction
                );
                tasks.add(t);
            }
            insert tasks;
            System.assertEquals(numOfTasks, [SELECT COUNT() FROM Task], 'Checking if tasks are inserted correctly');

            tasks = [SELECT Subject, SalesAction__c FROM Task];
            for(Task task : tasks){
                task.SalesAction__c = testNewSalesAction;
            }

            //when
            Test.startTest();
            update tasks;
            Test.stopTest();

            //then
            for(Task task : tasks){
                System.assertEquals(testNewSubject, task.Subject, 'Expecting new Task Subject matches pattern: <SalesAction__c> - <Program__c>');
            }
        }
    }

    @IsTest
    static void when_TaskIsUpdated_Expect_HyphenAndProgramIsAddedToSubject(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_5:
        //Existing Task is modified
        //Field Task.SalesAction__c is NOT changed
        //Task subject is NOT null
        //Task subject does NOT contain '-' (hyphen)

        String testProgram = 'AY';
        String testSubject = 'Some test subject';
        String testNewSubjectBeforeInsert = 'Some updated test subject';
        String testNewSubjectAfterInsert = testNewSubjectBeforeInsert + ' - ' + testProgram;
        Integer numOfTasks = 5;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            for(Integer i = 0; i<numOfTasks; i++){
                Task t = new Task(
                        Program__c = testProgram,
                        Subject = testSubject
                );
                tasks.add(t);
            }
            insert tasks;
            System.assertEquals(numOfTasks, [SELECT COUNT() FROM Task], 'Checking if tasks are inserted correctly');
            tasks = [SELECT Subject FROM Task];

            for(Task task : tasks){
                task.Subject = testNewSubjectBeforeInsert;
            }

            //when
            Test.startTest();
            update tasks;
            Test.stopTest();

            //then
            tasks = [SELECT Subject FROM Task];
            for(Task task : tasks){
                System.assertEquals(testNewSubjectAfterInsert, task.Subject, 'Expecting new Task Subject matches pattern: <current subject> - <Program__c>');
            }
        }
    }

    @IsTest
    static void when_TaskIsUpdated_Expect_SubjectIsNotChanged(){

        //given
        //Conditions for when_TaskIsCreated_Expect_SpecificSubjectBehavior_6:
        //Existing Task is modified
        //Field Task.SalesAction__c is NOT changed
        //Task subject is null OR Task subject contains '-' (hyphen)

        String testProgram = 'AY';
        String testNewProgram = 'ILS';
        String testSubject = 'Some test subject with hyphen -';
        String testNewSubject = testSubject + ' - ' + testNewProgram;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            List<Task> tasks = new List<Task>();
            Task t1 = new Task(
                    Program__c = testProgram
            );
            Task t2 = new Task(
                    Program__c = testProgram,
                    Subject = testSubject
            );
            tasks.add(t1);
            tasks.add(t2);

            insert tasks;
            System.assertEquals(2, [SELECT COUNT() FROM Task], 'Checking if tasks are inserted correctly');
            System.assertEquals(null, t1.Subject, 'Checking if subject is set properly');
            System.assertEquals(testSubject, t2.Subject, 'Checking if subject is set properly');

            List<Task> tasksToUpdate = new List<Task>();

            List<Task> taskWithoutSubject = [SELECT Subject FROM Task WHERE Subject = null];
            taskWithoutSubject[0].Program__c = testNewProgram;

            List<Task> taskWithHyphenInSubject = [SELECT Subject FROM Task WHERE Subject != null];
            taskWithoutSubject[0].Program__c = testNewProgram;

            tasksToUpdate.add(taskWithoutSubject[0]);
            tasksToUpdate.add(taskWithHyphenInSubject[0]);

            //when
            Test.startTest();
            update tasksToUpdate;
            Test.stopTest();

            //then
            Integer taskWithoutSubjectNumber = [SELECT Count() FROM Task WHERE Subject = null];
            System.assertEquals(1, taskWithoutSubjectNumber, 'Expecting task subject is not changed');

            taskWithHyphenInSubject = [SELECT Subject FROM Task WHERE Subject != null];
            System.assertEquals(testSubject,taskWithHyphenInSubject[0].Subject, 'Expecting task subject is not changed');
        }
    }
}
