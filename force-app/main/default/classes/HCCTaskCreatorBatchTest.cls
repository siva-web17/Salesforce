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

    Static Id SystemCallTaskRecordTypeId =
            RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

    @isTest
    static void When_BookingMaxEndDateIsPast_Expect_CreatingATask(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'ARB';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-1),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = 'AY'
            );
            insert book;

            testOpportunity.StageName = 'Closed Won';
            update testOpportunity;

        Test.startTest();
        HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
        Id batchId = Database.executeBatch(tcb);
        Test.stopTest();

        Task createdTask =[
                SELECT Id, WhatId, RecordTypeId, NextCallType__c, ActivityDate, FollowUpDate__c, Subject, OwnerId
                FROM Task
                LIMIT 1
        ];
        Account account =[
                SELECT Id, HasHappyCallTask__c
                FROM Account
                LIMIT 1
        ];

        Booking__c booking =[
                SELECT Id, MainSalesResponsible__c
                FROM Booking__c
                LIMIT 1
        ];

        System.assertEquals(1,[SELECT Count() FROM Task], 'Expecting one task is created');
        System.assertEquals(account.Id, createdTask.WhatId, 'Expecting Task is related with created account');
        System.assert(account.HasHappyCallTask__c, 'Expecting Account Has Happy Call Task');
        System.assertEquals(SystemCallTaskRecordTypeId, createdTask.RecordTypeId, 'Expecting specific Task Record type');
        System.assertEquals(Label.HCC_Next_Call_Type, createdTask.NextCallType__c, 'Expecting specific Next Call Type');
        System.assertEquals(Date.today(), createdTask.ActivityDate, 'Expecting task\'s activity date is today');
        System.assertEquals(Date.today(), createdTask.FollowUpDate__c, 'Expecting task\'s follow up date is today');
        System.assertEquals('Happy Call - AY', createdTask.Subject, 'Expecting task\'s subject match');
        System.assertEquals(booking.MainSalesResponsible__c, createdTask.OwnerId, 'Expecting Task owner is booking\'s Main Sales Responsible');
        }
    }

    @isTest
    static void When_MultipleBookingsMaxEndDateIsPast_Expect_CreatingATasks(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            Integer numberOfRecords = 3;
            Account[] accounts = new Account[]{};
            Opportunity[] opportunities = new Opportunity[]{};
            List<Booking__c> bookings = new List<Booking__c>();

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i<numberOfRecords; i++){

                Opportunity opp = new Opportunity();
                opp = (Opportunity)oppBuilder.withPersonAccount().getRecord();
                opp.IsActive__c = true;
                opp.Market__c = 'ARB';
                opp.Program__c = 'AY';
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
                        Program__c = 'AY'
                );
                bookings.add(book);
            }
            insert bookings;

            for(Opportunity opportunity : opportunities){
                opportunity.StageName = 'Closed Won';
            }
            update opportunities;

            Test.startTest();
            HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
            Id batchId = Database.executeBatch(tcb);
            Test.stopTest();

            for(List<Task> tasks :[
                    SELECT Id, RecordTypeId, NextCallType__c, ActivityDate, FollowUpDate__c, Subject, OwnerId
                    FROM Task])
            {
                for(Task task : tasks){
                    System.assertEquals(SystemCallTaskRecordTypeId, task.RecordTypeId, 'Expecting specific Task Record type');
                    System.assertEquals(Label.HCC_Next_Call_Type, task.NextCallType__c, 'Expecting specific Next Call Type');
                    System.assertEquals(Date.today(), task.ActivityDate, 'Expecting task\'s activity date is today');
                    System.assertEquals(Date.today(), task.FollowUpDate__c, 'Expecting task\'s follow up date is today');
                    System.assertEquals('Happy Call - AY', task.Subject, 'Expecting task\'s subject match the pattern');
                }
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
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'ARB';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Booking__c book = new Booking__c(
                    AccountId__c = accPerson.Id,
                    OpportunityId__c = testOpportunity.Id,
                    MaxEndDate__c = Date.today().addDays(-1),
                    Status__c = 'BKN',
                    MainSalesResponsible__c = adminUser.Id,
                    Program__c = 'AY'
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

            System.assertEquals(1,errorLogs.size(),'Expecting one error log');
            System.assertEquals('HCCTaskCreatorBatch',errorLogs[0].Name,'Expecting specific error log data');
            System.assertEquals('execute',errorLogs[0].MethodName__c,'Expecting specific error log data');
        }
    }
}