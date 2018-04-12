/**************************************************************************************
Apex Class Name    : HCCTaskDeferrerBatchTest
Version            : 1.0
Created Date       : April 12 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  12/04/2018              Original Version
*******************************************************************************/

@IsTest
private class HCCTaskDeferrerBatchTest{

    @isTest
    static void When_AccountHasHappyCallTaskAndOppIsActive_Expect_DeferTask(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Id SystemCallTaskRecordTypeId =
                    RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.HasHappyCallTask__c = TRUE;
            insert accPerson;

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = TRUE;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'ARB';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.HCC_Task_Type,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );
            insert task;

            //when
            Test.startTest();
            HCCTaskDeferrerBatch tdb = new HCCTaskDeferrerBatch();
            Id batchId = Database.executeBatch(tdb);
            Test.stopTest();

            //then
            List<Task> updatedTasks = [
                    SELECT Status
                    FROM Task
            ];

            System.assertEquals('Deferred', updatedTasks[0].Status, 'Expecting specific Task\'s status');
        }
    }

    @isTest
    static void When_MultipleAccountHasHappyCallTaskAndOppIsActive_Expect_DeferTask(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Id SystemCallTaskRecordTypeId =
                    RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
            Integer numberOfRecords = 2;
            Account[] accounts = new Account[]{};
            Opportunity[] opportunities = new Opportunity[]{};
            Task[] tasks = new Task[]{};

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i<numberOfRecords; i++){

                Opportunity opp = new Opportunity();
                opp = (Opportunity)oppBuilder.withPersonAccount().getRecord();
                opp.IsActive__c = TRUE;
                opp.Market__c = 'ARB';
                opp.Program__c = 'AY';
                opportunities.add(opp);
                Account acc = oppBuilder.getAccount();
                acc.HasHappyCallTask__c = TRUE;
                accounts.add(acc);
                oppBuilder.build();
            }
            insert accounts;

            for(Integer i = 0; i<numberOfRecords; i++){
                opportunities[i].AccountId = accounts[i].Id;
            }
            insert opportunities;

            for(Account account : accounts){
                Task task = new Task(
                        RecordTypeId = SystemCallTaskRecordTypeId,
                        WhatId = account.Id,
                        NextCallType__c = Label.HCC_Next_Call_Type,
                        Type = Label.HCC_Task_Type,
                        ActivityDate = Date.today(),
                        FollowUpDate__c = Date.today(),
                        Status = Label.Not_Started
                );
                tasks.add(task);
            }
            insert tasks;

            //when
            Test.startTest();
            HCCTaskDeferrerBatch tdb = new HCCTaskDeferrerBatch();
            Id batchId = Database.executeBatch(tdb);
            Test.stopTest();

            //then
            List<Task> updatedTasks = [
                    SELECT Status
                    FROM Task
            ];

            for(Task task : updatedTasks){
                System.assertEquals('Deferred', task.Status, 'Expecting specific Task\'s status');
            }
        }
    }

    @isTest
    static void When_ScheduleJob_Expect_JobIsScheduled(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            String cronExpr = '0 0 0 ? * * *';

            List<AsyncApexJob> jobsBefore = [
                    SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                    FROM AsyncApexJob
            ];
            System.assertEquals(0, jobsBefore.size(), 'Not expecting any async jobs');

            //when
            HCCTaskDeferrerBatch tdb = new HCCTaskDeferrerBatch();

            Test.startTest();
            String jobId = System.schedule('TestJobName', cronExpr, tdb);
            Test.stopTest();

            //then
            List<AsyncApexJob> jobsScheduled = [
                    SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                    FROM AsyncApexJob
                    WHERE JobType = 'ScheduledApex'
            ];
            System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
            System.assertEquals('HCCTaskDeferrerBatch', jobsScheduled[0].ApexClass.Name, 'Expecting specific scheduled job');

            List<AsyncApexJob> jobsApexBatch = [
                    SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                    FROM AsyncApexJob
                    WHERE JobType = 'BatchApex'
            ];
            System.assertEquals(1, jobsApexBatch.size(), 'Expecting one apex batch job');
            System.assertEquals('HCCTaskDeferrerBatch', jobsApexBatch[0].ApexClass.Name, 'Expecting specific batch job');
        }
    }

    @isTest
    static void When_TaskDataIsNotValid_Expect_ExceptionIsThrown(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Id SystemCallTaskRecordTypeId =
                    RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.HasHappyCallTask__c = TRUE;
            insert accPerson;

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = TRUE;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'ARB';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.HCC_Task_Type,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started,
                    Priority = 'Incorrect Value'
            );
            insert task;
        }

        Test.startTest();
        HCCTaskDeferrerBatch tdb = new HCCTaskDeferrerBatch();
        try{
            Id batchId = Database.executeBatch(tdb);
        }catch(Exception ex){
            System.assert(false,'Exception was not caught');
        }
        Test.stopTest();

        //then
        List<ErrorLog__c> errorLogs =[
                SELECT Id, Name, MethodName__c
                FROM ErrorLog__c
        ];

        System.assertEquals(1,errorLogs.size(),'Expecting one error log');
        System.assertEquals('HCCTaskDeferrerBatch',errorLogs[0].Name,'Expecting specific error log data');
        System.assertEquals('execute',errorLogs[0].MethodName__c,'Expecting specific error log data');
    }
}