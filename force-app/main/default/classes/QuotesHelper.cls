/**
 * Created by thejasvi.a on 3/16/2018.
 */

public with sharing class QuotesHelper {
    private class QuoteToOpportunityAndTaskMap{
        public Set<Id> OppIdSet {get;set;}
        public Map<Id, String> TaskMap{get;set;}
        public QuoteToOpportunityAndTaskMap(Set<Id> oppIdSet,Map<Id, String> taskMap){
            this.OppIdSet = oppIdSet;
            this.TaskMap = taskMap;
        }
    }

    public static void closeSPQTasksOnOpportunity(List<Quote__c> quoteList) {
        QuoteToOpportunityAndTaskMap quoteToOppAndTaskMap = getOpportunitiesAndTasksForQuote(quoteList);
        createTaskforEmailSent(quoteToOppAndTaskMap.TaskMap);
        List<Task> taskList= TasksSelector.getSPQTasks(quoteToOppAndTaskMap.OppIdSet, system.label.SPQTask);
        closeSPQTasks(taskList);
    }

    private static QuoteToOpportunityAndTaskMap getOpportunitiesAndTasksForQuote(List<Quote__c> quoteList){
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, String> taskMap = new Map<Id, String>();
        List<Task> taskList = new List<Task>();
        List<Task> pqTaskList = new List<Task>();
        Id currentRecordId;

        for(Quote__c quoteRecord: quoteList){
            if(quoteRecord.Opportunity__c!=null){
                oppIdSet.add(quoteRecord.Opportunity__c);
            }

            if(quoteRecord.SentByEmail__c && quoteRecord.QuotePDF__c!=null){
                taskMap.put(quoteRecord.Opportunity__c, quoteRecord.QuotePDF__c);
            }
        }
        return new QuoteToOpportunityAndTaskMap(oppIdSet,taskMap);
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

    private static void createTaskforEmailSent(Map<Id, String> taskMap){
        List<Task> taskList = new List<Task>();
        List<Opportunity> oppList=OpportunitiesSelector.getOpportunityForQuote(taskMap);
        Id oppRecordId;
        try {
            for (Opportunity oppRecord: oppList) {
                oppRecordId = oppRecord.Id; 
                Task taskRecord = new Task();
                taskRecord.TaskSubtype = System.Label.Email;
                taskRecord.Description = taskMap.get(oppRecord.Id);
                taskRecord.Status = System.Label.TaskStatusCompleted;
                taskRecord.Whatid = oppRecord.Id;
                taskRecord.Program__c = oppRecord.Program__c;
                taskRecord.Subject = System.Label.EmailPriceQuote;
                taskList.add(taskRecord);
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