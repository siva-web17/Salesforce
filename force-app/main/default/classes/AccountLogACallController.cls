/**
 * Created by britenet-patrykzak on 11/04/2018.
 */

public with sharing class AccountLogACallController {

    @auraEnabled
    public static Account getInitialData(Id recordId){
        return AccountsSelector.getAccountOnId(recordId);
    }

    @auraEnabled
    public static Id getExPaxSource(){

        try {
            Set<String> SourceCodeValues = new Set<String>();
            SourceCodeValues.add(Label.ExPaxSourceCode);
            List<Source__c> SourceCodeList = SourcesSelector.getSourceRecords(SourceCodeValues);

            return SourceCodeList[0].Id;
        }
        catch(Exception e){
            throw new AuraHandledException('Log an action - ExPax Source missing, please contact with your administrator : ' + e.getMessage());
            return null;
        }
    }


    @AuraEnabled
    public static List<String> getSalesActions(){

        try{
            List<String> salesActions = new List<String>(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'SalesAction__c').keySet());
            List<String> trimmedActions = new List<String>();

            for(Integer i=0; i< salesActions.size(); i++){
                if(salesActions[i].equalsIgnoreCase(Label.CallReached) || salesActions[i].equalsIgnoreCase(Label.CallNotReached)) {
                    trimmedActions.add(salesActions[i]);
                }
            }

            return trimmedActions;
        }
        catch (Exception e){
            throw new AuraHandledException('Log an action - Could not load Sales Actions, please contact with your administrator : ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getSubActions(){

        try{
            List<String> subActions = new List<String>(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'CallNotReachedType__c').keySet());
            return subActions;
        }
        catch (Exception e){
            throw new AuraHandledException('Log an action - Could not load Sub Actions, please contact with your administrator : ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getCallResults(String callAction,Id recordId){

        try{
            Map<String,List<String>> dependentPicklists = FieldUtilityClass.getFieldDependencies(Task.getSObjectType().getDescribe().getName(),'SalesAction__c','ResultType__c');
            HappyCallRules__c HCCRules = HappyCallRules__c.getInstance(Label.HCC);
            Decimal minimalUnreachedCallAttempts = HCCRules.MinUnreachedCallAttempts__c;
            List<String> callResults = dependentPicklists.get(callAction);
            Account acc = AccountsSelector.getAccountOnId(recordId);

            for(Integer i=0; i< callResults.size() ; i++){
                if((!callResults[i].equalsIgnoreCase(Label.CallBack) && !callResults[i].equalsIgnoreCase(Label.LAC_Close)) || acc.NumberOfUnreachedHappyCalls__c < minimalUnreachedCallAttempts && callResults[i].equalsIgnoreCase(Label.LAC_Close)) {
                    callResults.remove(i);
                }
            }
            return callResults;
        }
        catch (Exception e){
            throw new AuraHandledException('Log an action - Could not load Call Results, please contact with your administrator : ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static void createTaskOnOpp(Id accountId, Id oppId, String comments, String callAction, String callResult, String actionDate){

        try {
            Set<Id> AccountIds = new Set<Id>{AccountId};
            List<Task> systemCallTasks = TasksSelector.getHappyCallTaskForAccounts(AccountIds);

            if (systemCallTasks.size() > 0 && systemCallTasks != null) {

                Task SystemCallTask = systemCallTasks[0];
                SystemCallTask.IsParentClosing__c = true;
                SystemCallTask.ActivityDate = Date.valueOf(actionDate);

                systemCallTask.Status = Label.LAC_Closed;
                update systemCallTask;

                Task task = new Task();
                task.WhatId = oppId;
                task.Description = comments;
                task.RecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.getSObjectType()).get(Label.CallTaskRecordTypeDeveloperName).Id;
                task.SalesAction__c = callAction;
                task.Type = Label.HCC;
                task.Status = Label.TaskStatusCompleted;
                task.ResultType__c = callResult;
                task.NextCallType__c = Label.OpportunityStageFollowUp;
                task.TaskSubtype = Label.Call;
                task.FollowUpDate__c = Datetime.valueOfGmt(actionDate.replace('T', ' '));
                task.Program__c = systemCallTask.Program__c;

                LogACallHelper.handleLogAnAction(oppId, task, task.FollowUpDate__c, systemCallTask.Program__c);
            }
        } catch (Exception e){
            throw new AuraHandledException('Log an action - No System Call Task for current Account to update : ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveData(Id AccountId, String comments, String callAction, String subAction, String callResult, String actionDate) {

        try {
            Set<Id> AccountIds = new Set<Id>{AccountId};
            List<Task> systemCallTasks = TasksSelector.getHappyCallTaskForAccounts(AccountIds);

            if (systemCallTasks.size() > 0 && systemCallTasks != null) {

                Task SystemCallTask = systemCallTasks[0];
                SystemCallTask.IsParentClosing__c = true;

                Task task = new Task();
                task.WhatId = AccountId;
                task.Description = comments;
                task.RecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.getSObjectType()).get(Label.CallTaskRecordTypeDeveloperName).Id;
                task.SalesAction__c = callAction;
                task.Type = Label.HCC;
                task.Status = Label.TaskStatusCompleted;
                task.ResultType__c = callResult;
                task.TaskSubtype = Label.Call;
                task.Program__c = systemCallTask.Program__c;

                if (callAction.equalsIgnoreCase(Label.CallReached) && callResult.equalsIgnoreCase(Label.LAC_Close)) {

                    systemCallTask.Status = Label.LAC_Closed;

                    task.CloseMainReason__c = Label.WillNotTravelAgain;

                } else if (callAction.equalsIgnoreCase(Label.CallNotReached) && callResult.equalsIgnoreCase(Label.CallBack)) {

                    systemCallTask.FollowUpDate__c = Datetime.valueOfGmt(actionDate.replace('T', ' '));
                    systemCallTask.ActivityDate = Date.valueOf(actionDate);
                    systemCallTask.Status = Label.Not_Started;

                    task.CallNotReachedType__c = subAction;

                } else if (callAction.equalsIgnoreCase(Label.CallNotReached) && callResult.equalsIgnoreCase(Label.LAC_Close)) {

                    systemCallTask.status = Label.Deferred;

                    task.CallNotReachedType__c = subAction;
                    task.CloseMainReason__c = Label.NotAbleToContactCustomer;
                }

                insert task;
                update systemCallTask;
            }
        } catch (Exception e){
            throw new AuraHandledException('Log an action - No System Call Task for current Account to update : ' + e.getMessage());
        }
    }
}