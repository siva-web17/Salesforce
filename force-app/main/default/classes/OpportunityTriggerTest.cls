@isTest
private class OpportunityTriggerTest {


    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    static testMethod void whenProgramChangesUpdateProgramOnSystemCallTasks() {
        //given
        Integer numberOfOpportunities = 50;
        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        opportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Opportunity[] opportunities = new Opportunity[]{};

        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            opportunityBuilder.build();
            Opportunity opp = (Opportunity)opportunityBuilder.getRecord();

            opp.Product__c = picklistValuesHelper.product;
            opp.Program__c = picklistValuesHelper.program;
            opportunities.add(opp);
        }
        insert opportunities;

        Task[] systemTasks = new Task[]{};
        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setWhat(opportunities[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Opportunity opp : opportunities){
            opp.Program__c = picklistValuesHelper.program2;
        }

        //when
        Test.startTest();
        update opportunities;
        Test.stopTest();

        //then
        Set<Id> opportunityIds = (new Map<Id, Opportunity>(opportunities)).keySet();
        opportunities = OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(opportunities.size() > 0);
        for(Opportunity opp : opportunities){
            System.assertEquals(picklistValuesHelper.program2, opp.Tasks[0].Program__c,'Incorrect program');
        }
    }

    static testMethod void whenOwnerChangesReassignOpenTasks() {
        User u = TestDataFactory.createAdminUser(true);

        Integer numberOfOpportunities = 50;
        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        opportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Opportunity[] opportunities = new Opportunity[]{};

        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            opportunityBuilder.build();
            Opportunity opp = (Opportunity)opportunityBuilder.getRecord();
            opportunities.add(opp);
        }
        insert opportunities;

        Task[] systemTasks = new Task[]{};
        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setField('Program__c', picklistValuesHelper.program);
            tb.setWhat(opportunities[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Opportunity opp : opportunities){
            opp.OwnerId = u.Id;
        }

        //when
        Test.startTest();
        update opportunities;
        Test.stopTest();

        //then
        Set<Id> opportunityIds = (new Map<Id, Opportunity>(opportunities)).keySet();
        opportunities = OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(opportunities.size() > 0);
        for(Opportunity opp : opportunities){
            System.assertEquals(u.Id, opp.Tasks[0].OwnerId,'Incorrect program');
        }
    }
}