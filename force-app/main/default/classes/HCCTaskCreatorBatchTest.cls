/**************************************************************************************
Apex Class Name    : HCCTaskCreatorBatchTest
Version            : 1.0
Created Date       : March 26 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  22/03/2018              Original Version
*******************************************************************************/

@IsTest
private class HCCTaskCreatorBatchTest{

    private static Id SystemCallTaskRecordTypeId =
            RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void When_BookingMaxEndDateIsPast_Expect_CreatingATask(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Program__c = picklistValuesHelper.program;
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-1),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = picklistValuesHelper.program
            );
            insert book;

            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            //then
            List<Task> createdTasks = [
                    SELECT Id, WhatId, RecordTypeId, NextCallType__c, ActivityDate, FollowUpDate__c, Subject, OwnerId
                    FROM Task
            ];

            Account account =[
                SELECT Id, HasHappyCallTask__c
                FROM Account
                WHERE Id = :accPerson.Id
            ];

            Booking__c booking =[
                SELECT MainSalesResponsible__c
                FROM Booking__c
                WHERE Id = :book.Id
            ];

            System.assertEquals(1, createdTasks.size(), 'Expecting one task is created');
            System.assertEquals(account.Id, createdTasks[0].WhatId, 'Expecting Task is related with created account');
            System.assert(account.HasHappyCallTask__c, 'Expecting Account Has Happy Call Task');
            System.assertEquals(SystemCallTaskRecordTypeId, createdTasks[0].RecordTypeId, 'Expecting specific Task Record type');
            System.assertEquals(Label.HCC_Next_Call_Type, createdTasks[0].NextCallType__c, 'Expecting specific Next Call Type');
            System.assertEquals(Date.today(), createdTasks[0].ActivityDate, 'Expecting task\'s activity date is today');
            System.assertEquals(Date.today(), createdTasks[0].FollowUpDate__c, 'Expecting task\'s follow up date is today');
            System.assertEquals('Happy Call - ' + picklistValuesHelper.program, createdTasks[0].Subject, 'Expecting task\'s subject match');
            System.assertEquals(booking.MainSalesResponsible__c, createdTasks[0].OwnerId, 'Expecting Task owner is booking\'s Main Sales Responsible');
        }
    }

    @isTest
    static void When_MultipleBookingsMaxEndDateIsPast_Expect_CreatingATasks(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numberOfRecords = 3;
            Account[] accounts = new Account[]{};
            Opportunity[] opportunities = new Opportunity[]{};
            List<Booking__c> bookings = new List<Booking__c>();

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i<numberOfRecords; i++){

                Opportunity opp = new Opportunity();
                opp = (Opportunity)oppBuilder.withPersonAccount().getRecord();
                opp.Program__c = picklistValuesHelper.program;
                opportunities.add(opp);
                accounts.add(oppBuilder.getAccount());
                oppBuilder.build();
            }
            insert accounts;

            for(Integer i = 0; i<numberOfRecords; i++){
                opportunities[i].AccountId = accounts[i].Id;
            }
            insert opportunities;

            for(Opportunity opportunity : opportunities){
                Booking__c book = new Booking__c(
                        AccountId__c = opportunity.AccountId,
                        OpportunityId__c = opportunity.Id,
                        MaxEndDate__c = Date.today().addDays(-1),
                        Status__c = 'BKN',
                        MainSalesResponsible__c = adminUser.Id,
                        Program__c = picklistValuesHelper.program
                );
                bookings.add(book);
            }
            insert bookings;

            for(Opportunity opportunity : opportunities){
                opportunity.StageName = 'Closed Won';
            }
            update opportunities;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            //then
            List<Task> tasks = [
                    SELECT Id, RecordTypeId, NextCallType__c, ActivityDate, FollowUpDate__c, Subject, OwnerId
                    FROM Task
            ];

            System.assertEquals(numberOfRecords, tasks.size(), 'Expecting specific number of Task records are created');

            for(Task task : tasks){
                System.assertEquals(SystemCallTaskRecordTypeId, task.RecordTypeId, 'Expecting specific Task Record type');
                System.assertEquals(Label.HCC_Next_Call_Type, task.NextCallType__c, 'Expecting specific Next Call Type');
                System.assertEquals(Date.today(), task.ActivityDate, 'Expecting task\'s activity date is today');
                System.assertEquals(Date.today(), task.FollowUpDate__c, 'Expecting task\'s follow up date is today');
                System.assertEquals('Happy Call - ' + picklistValuesHelper.program, task.Subject, 'Expecting task\'s subject match the pattern');
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
            Test.startTest();
            HCCTaskCreatorBatch executer = new HCCTaskCreatorBatch();
            String jobId = System.schedule('TestJobName', cronExpr, executer);
            Test.stopTest();

            //then
            List<AsyncApexJob> jobsScheduled = [
                    SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                    FROM AsyncApexJob
                    WHERE JobType = 'ScheduledApex'
            ];
            System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
            System.assertEquals('HCCTaskCreatorBatch', jobsScheduled[0].ApexClass.Name, 'Expecting specific scheduled job');

            List<AsyncApexJob> jobsApexBatch = [
                    SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                    FROM AsyncApexJob
                    WHERE JobType = 'BatchApex'
            ];
            System.assertEquals(1, jobsApexBatch.size(), 'Expecting one apex batch job');
            System.assertEquals('HCCTaskCreatorBatch', jobsApexBatch[0].ApexClass.Name, 'Expecting specific batch job');
        }
    }

    @isTest
    static void When_AccountDataIsNotValid_Expect_ExceptionIsThrown(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.FirstName = null;
            insert accPerson;

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = picklistValuesHelper.market;
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-1),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = picklistValuesHelper.program
            );
            insert book;
            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

            List<BypassTriggersValidation__c> bypassTriggersValidations = [
                    SELECT DisableValidation__c
                    FROM BypassTriggersValidation__c
            ];
            bypassTriggersValidations[0].DisableValidation__c = false;
            bypassTriggersValidations[0].DisableTrigger__c= false;
            update bypassTriggersValidations;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            try{
                Id batchId = Database.executeBatch(tcb);
            }catch(Exception exc){}
            Test.stopTest();

            //then
            List<ErrorLog__c> errorLogs =[
                    SELECT Id, Name, MethodName__c
                    FROM ErrorLog__c
            ];

            System.assertEquals(1, errorLogs.size(), 'Expecting one error log');
            System.assertEquals('HCCTaskCreatorBatch', errorLogs[0].Name, 'Expecting specific error log data');
            System.assertEquals('execute', errorLogs[0].MethodName__c, 'Expecting specific error log data');
        }
    }

    @isTest
    static void When_BookingMaxEndDateIsToday_Expect_TaskIsNotCreated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Program__c = picklistValuesHelper.program;
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today(),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = picklistValuesHelper.program
            );
            insert book;

            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            //then
            System.assertEquals(0, [SELECT Count() FROM Task], 'Expecting no task is created');
        }
    }

    @isTest
    static void When_BookingMaxEndDateDayBeforeExpectedRange_Expect_TaskIsNotCreated(){

        Integer numberOfDays = Integer.valueOf(Label.HCCTaskCreatorBatchNoOfDaysParameter) + 1;

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Program__c = picklistValuesHelper.program;
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-numberOfDays),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = picklistValuesHelper.program
            );
            insert book;

            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            //then
            System.assertEquals(0, [SELECT Count() FROM Task], 'Expecting no task is created');
        }
    }

    @isTest
    static void When_BookingMaxEndDateDayIsInExpectedRange_Expect_TaskIsCreated(){

        Integer numberOfDays = Integer.valueOf(Label.HCCTaskCreatorBatchNoOfDaysParameter);

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Program__c = picklistValuesHelper.program;
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-numberOfDays),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = picklistValuesHelper.program
            );
            insert book;

            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

            //when
            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            //then
            List<Task> createdTasks = [
                    SELECT ActivityDate, FollowUpDate__c
                    FROM Task
            ];
            System.assertEquals(1, createdTasks.size(), 'Expecting one task is created');
            System.assertEquals(Date.today().addDays(-numberOfDays+1), createdTasks[0].ActivityDate, 'Expecting task\'s activity date is today');
            System.assertEquals(Date.today().addDays(-numberOfDays+1), createdTasks[0].FollowUpDate__c, 'Expecting task\'s follow up date is today');
        }
    }
}