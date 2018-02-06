/**
 * Created by Arkadiusz Celej on 08-dec-2017.
 */

@IsTest
private class TaskTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    static testMethod void shouldUpdateTaskOpportunityFieldBrochuresToSend() {
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

    static testMethod void shouldUpdateTaskOpportunityFieldSendBrochures() {
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

    static testMethod void whenNoCallsMadeNumberOfCallsOnOpportunityShouldBeZero() {
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

    static testMethod void whenCallsMadeNumberOfCallsOnOpportunityShouldNotBeZero() {
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

    static testMethod void whenNoCallsMadeNumberOfCallsOnLeadShouldBeZero() {
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

    static testMethod void whenCallsMadeNumberOfCallsOnLeadShouldNotBeZero() {
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

    /**
     * Consecutive call unreached counter tests
     */

    static testMethod void whenCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldBeOne() {
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

    static testMethod void whenConsecutiveCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldNotBeZero() {
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

    static testMethod void whenCallNotReachedNumberOfUnreachedCallsOnOpportunityShouldBeZero() {
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