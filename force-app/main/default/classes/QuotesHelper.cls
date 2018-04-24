/**
 * Created by thejasvi.a on 3/16/2018.
 */

public with sharing class QuotesHelper {

    public static void closeSPQTasksAndCreateNewTaskOnOpportunity(List<Quote__c> quoteList) {
        Set<Id> oppIdSet = new Set<Id>();
            for(Quote__c quoteRecord: quoteList){
                if(quoteRecord.Opportunity__c!= null){
                    oppIdSet.add(quoteRecord.Opportunity__c);
                }
            }
        List<Task> taskList= TasksSelector.getSPQTasks(oppIdSet, system.label.SPQTask);
        closeSPQTasks(taskList);
        createTaskforEmailSent(quoteList);
        } 

    private static void closeSPQTasks(List<Task> taskList){
        List<Task> tasksToUpdate = new List<Task>();
        Id currentRecordId;
        try {
            for (Task pqTaskRecord:taskList) {
                currentRecordId = pqTaskRecord.Id;
                if (!pqTaskRecord.IsClosed) {
                    pqTaskRecord.Status = System.label.TaskStatusCompleted;
                    tasksToUpdate.add(pqTaskRecord);
                }
            }
            if (tasksToUpdate.size() > 0) {
                update tasksToUpdate;
            }
        } catch(exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotesHelper', 'closeSPQTasks',currentRecordId );
        }
    }

    private static void createTaskforEmailSent(List<Quote__c> quoteList){
        List<Task> taskList = new List<Task>();
        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.getSObjectType()).get(Label.CallTaskRecordTypeDeveloperName).Id;
        Id oppRecordId;
        try {
            for (Quote__c quoteRecord: quoteList) {
                if (quoteRecord.SentByEmail__c && quoterecord.Opportunity__c!=null) {
                    oppRecordId = quoteRecord.Opportunity__c;
                    Task taskRecord = new Task();
                    taskRecord.TaskSubtype = System.Label.Email;
                    taskRecord.Description = quoteRecord.QuotePDF__c;
                    taskRecord.Status = System.Label.TaskStatusCompleted;
                    taskRecord.WhatId = quoteRecord.Opportunity__c;
                    taskRecord.Program__c = quoteRecord.Program__c;
                    taskRecord.Subject = System.Label.EmailPriceQuote;
                    taskRecord.OwnerId = quoteRecord.QuoteCreatedBy__c;
                    taskRecord.RecordTypeId = recordTypeId;
                    taskList.add(taskRecord);
                }
            }
            if (taskList.size() > 0) {
                insert taskList;
            }
        }
        catch(exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotesHelper', 'createTaskforEmailSent',oppRecordId );
        }
    }
}