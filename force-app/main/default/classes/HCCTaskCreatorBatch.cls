/**************************************************************************************
Apex Class Name    : HCCTaskCreatorBatch
Version            : 1.0
Created Date       : March 26 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  26/03/2018              Original Version
*******************************************************************************/

public without sharing class HCCTaskCreatorBatch implements Database.Batchable<SObject>, Schedulable{

    public Id SystemCallTaskRecordTypeId =
            RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
    public Integer numberOfDays = Integer.valueOf(Label.HCCTaskCreatorBatchNoOfDaysParameter);

    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
                'SELECT Id, MaxActiveBookingEndDate__c, (SELECT MainSalesResponsible__c, MaxEndDate__c, Program__c  FROM Bookings__r' +
                        ' WHERE MaxEndDate__c < TODAY AND MaxEndDate__c = LAST_N_DAYS:' + numberOfDays + ') '+
                        'FROM Account ' +
                        'WHERE MaxActiveBookingEndDate__c < TODAY' +
                        ' AND MaxActiveBookingEndDate__c = LAST_N_DAYS:' + numberOfDays +
                        ' AND ActiveOpportunities__c = 0' +
                        ' AND HasHappyCallTask__c = FALSE'
        );
    }

    public void execute(Database.BatchableContext context,List<Account> scope){

        List<Task> tasks = new List<Task>();
        Booking__c booking = new Booking__c();
        List<Account> accounts = new List<Account>();
        Account acc = new Account();

        for(Account account : scope){
            account.HasHappyCallTask__c = TRUE;
            account.ReadyForHappyCall__c = TRUE;
            accounts.add(account);
            booking = account.Bookings__r[0];
            account.LatestBooking__c = booking.Id;
            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = account.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.HCC_Task_Type,
                    ActivityDate = account.MaxActiveBookingEndDate__c + 1,
                    FollowUpDate__c = account.MaxActiveBookingEndDate__c + 1,
                    Status = Label.Not_Started,
                    Subject = Label.Happy_Call + ' ' + booking.Program__c,
                    OwnerId = booking.MainSalesResponsible__c,
                    Program__c = booking.Program__c
            );
            tasks.add(task);
        }
        try{
            insert tasks;
            update accounts;
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'HCCTaskCreatorBatch', 'execute', null);
        }
    }
    public void finish(Database.BatchableContext bc){
    }

    //Scheduling method
    public void execute(SchedulableContext sc){
        HCCTaskCreatorBatch tcb = new HCCTaskCreatorBatch();
        Database.executeBatch(tcb);
    }
}