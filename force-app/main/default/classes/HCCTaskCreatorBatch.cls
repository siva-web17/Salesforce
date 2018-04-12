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

    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
                'SELECT Id, MaxActiveBookingEndDate__c, (SELECT MainSalesResponsible__c, MaxEndDate__c, Program__c  FROM Bookings__r)'+
                        'FROM Account ' +
                        'WHERE MaxActiveBookingEndDate__c < TODAY' +
                        ' AND ActiveOpportunities__c = 0' +
                        ' AND HasHappyCallTask__c = FALSE'
        );
    }

    public void execute(Database.BatchableContext context,List<Account> scope){

        List<Task> tasks = new List<Task>();
        List<Booking__c> bookings = new List<Booking__c>();
        List<Account> accounts = new List<Account>();
        Account acc = new Account();

        for(Account account : scope){

            account.HasHappyCallTask__c = TRUE;
            bookings = account.Bookings__r;
            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = account.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.HCC_Task_Type,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );

            for(Booking__c booking : bookings){
                if(booking.MaxEndDate__c == account.MaxActiveBookingEndDate__c){
                    task.Subject = Label.Happy_Call + ' ' + booking.Program__c;
                    task.OwnerId = booking.MainSalesResponsible__c;
                    break;
                }
            }
            tasks.add(task);
            accounts.add(account);
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