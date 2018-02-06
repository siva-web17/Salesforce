/**
 * Created by Arkadiusz Celej on 11.01.2018.
 */

@IsTest
private class LeadTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    static testMethod void whenProgramChangesUpdateProgramOnSystemCallTasks() {
        //given
        Integer numberOfLeads = 50;
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Lead[] leads = new Lead[]{};
        Task[] systemTasks = new Task[]{};
        for(Integer i = 0 ; i < numberOfLeads; i++){
            leads.add((Lead)leadBuilder.build().getRecord());
            systemTasks.addAll(leadBuilder.tasks);
        }
        insert leads;

        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfLeads; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setField('Program__c', picklistValuesHelper.program);
            tb.setWho(leads[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Lead l : leads){
            l.Program__c = picklistValuesHelper.program2;
        }

        //when
        Test.startTest();
        update leads;
        Test.stopTest();

        //then
        Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
        Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(updatedLeads.size() > 0);
        for(Lead l : updatedLeads){
            System.assertEquals(picklistValuesHelper.program2, l.Tasks[0].Program__c,' Incorrect program');
        }
    }

    static testMethod void whenOwnerChangesReassignOpenTasks() {
        User u = TestDataFactory.createAdminUser(true);

        Integer numberOfLeads = 50;
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Lead[] leads = new Lead[]{};
        Task[] systemTasks = new Task[]{};
        for(Integer i = 0 ; i < numberOfLeads; i++){
            leads.add((Lead)leadBuilder.build().getRecord());
        }
        insert leads;

        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfLeads; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setWho(leads[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Lead l : leads){
            l.OwnerId = u.Id;
        }

        Test.startTest();
        update leads;
        Test.stopTest();

        Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
        Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(updatedLeads.size() > 0);
        for(Lead l : updatedLeads){
            System.assertEquals(u.Id, l.Tasks[0].OwnerId,'Tasks should be reassigned to new Lead Owner');
        }
    }

    static testMethod void whenOwnerChangesCreateSystemCallTasks() {
        User u = TestDataFactory.createAdminUser(true);

        Integer numberOfLeads = 50;
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Lead[] leads = new Lead[]{};
        Task[] systemTasks = new Task[]{};
        for(Integer i = 0 ; i < numberOfLeads; i++){
            leads.add((Lead)leadBuilder.build().getRecord());
        }
        insert leads;

        for(Lead l : leads){
            l.OwnerId = u.Id;
        }

        Test.startTest();
        update leads;
        Test.stopTest();

        Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
        Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(updatedLeads.size() > 0);
        for(Lead l : updatedLeads){
            System.assertEquals(1, l.Tasks.size(),'Lead should have one and only one system call task');
            System.assertEquals(u.Id, l.Tasks[0].OwnerId,'Tasks should be reassigned to new Lead Owner');
        }
    }
}