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

    static testMethod void When_BookingMaxEndDateIsPast_Expect_CreatingATask(){

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
        }
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

        System.assertEquals(1,[SELECT Count() FROM Task]);
        System.assertEquals(account.Id,createdTask.WhatId);
        System.assert(account.HasHappyCallTask__c);
        System.assertEquals(SystemCallTaskRecordTypeId,createdTask.RecordTypeId);
        System.assertEquals(Label.HCC_Next_Call_Type,createdTask.NextCallType__c);
        System.assertEquals(Date.today(),createdTask.ActivityDate);
        System.assertEquals(Date.today(),createdTask.FollowUpDate__c);
        System.assertEquals('Happy Call - AY',createdTask.Subject);
        System.assertEquals(booking.MainSalesResponsible__c,createdTask.OwnerId);
    }

    static testMethod void When_MultipleBookingsMaxEndDateIsPast_Expect_CreatingATasks(){

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
                    System.assertEquals(SystemCallTaskRecordTypeId, task.RecordTypeId);
                    System.assertEquals(Label.HCC_Next_Call_Type, task.NextCallType__c);
                    System.assertEquals(Date.today(), task.ActivityDate);
                    System.assertEquals(Date.today(), task.FollowUpDate__c);
                    System.assertEquals('Happy Call - AY', task.Subject);
                }
            }
        }
    }
}