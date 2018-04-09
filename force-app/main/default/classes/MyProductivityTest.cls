/**************************************************************************************
Apex Class Name    : MyProductivityTest
Version            : 1.0
Created Date       : Dec 6 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej             6-dec-2017              Original Version
*******************************************************************************/
@IsTest
private class MyProductivityTest {
    static testMethod void shouldRetrieveDefaultStatistics() {
        //given
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        Lead[] leads = new Lead[]{};
        for(Integer i = 0; i < 50; i++) {
            leads.add((Lead)leadBuilder.build().getRecord());
        }

        insert leads;

        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        opportunityBuilder.save();

        //when
        Test.startTest();
        MyProductivity.MyStatistics stats = MyProductivity.getMyStatistics();
        Test.stopTest();
        //then
        System.assertEquals(0, stats.myReachedTasks);
        System.assertEquals(0, stats.myCompletedTasks);
        System.assertEquals(0, stats.myLeads);
        System.assertEquals(0, stats.reachedRate);
    }

    static testMethod void shouldRetrieveStatistics() {
        //given
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        Lead[] leads = new Lead[]{};
        for(Integer i = 0; i < 50; i++) {
            leads.add((Lead)leadBuilder.build().getRecord());
        }

        insert leads;
        TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
        Task[] tasks = new Task[]{};
        for(Lead l : leads){
            taskBuilder.withRecordType(TasksHelper.CALL_TASK_DEVELOPER_NAME);
            taskBuilder.setWho(l.Id);
            taskBuilder.closeTask();
            tasks.add((Task)taskBuilder.getRecord());
            taskBuilder.build();
        }

        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        opportunityBuilder.save();
        Id opportunityId = opportunityBuilder.getRecord().Id;

        for(Integer i = 0; i < 50; i++){
            taskBuilder.withRecordType(TasksHelper.CALL_TASK_DEVELOPER_NAME);
            taskBuilder.setWhat(opportunityId);
            taskBuilder.closeTask().reachedTask();
            tasks.add((Task)taskBuilder.getRecord());
            taskBuilder.build();
        }

        insert tasks;
        //when
        Test.startTest();
        MyProductivity.MyStatistics stats = MyProductivity.getMyStatistics();
        Test.stopTest();
        //then
        System.assertEquals(50, stats.myReachedTasks);
        System.assertEquals(100, stats.myCompletedTasks);
        System.assertEquals(0, stats.myLeads);
        System.assertEquals(50, stats.reachedRate);
    }
}