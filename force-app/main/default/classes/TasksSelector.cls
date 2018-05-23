/**************************************************************************************
Apex Class Name    : TasksSelector
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * shravan.boddula                 07/12/2017              Original Version
*******************************************************************************/

public class TasksSelector {

    public static List<AggregateResult> getTodaysTasksByRecordTypeAndWhoType(String taskRecordType, String whoType, Id userId) {
        return [
                SELECT count_distinct(whoid) cnt
                FROM Task
                WHERE RecordType.DeveloperName = :taskRecordType
                AND (FollowUpDate__c = NULL OR FollowUpDate__c <= TODAY)
                AND IsClosed <> TRUE AND Who.Type = :whoType AND OwnerId = :userId
        ];
    }

    public static List<Task> getTodaysCallTasksClosedByUser(Id userId) {
        Id callTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.CALL_TASK_DEVELOPER_NAME).Id;
        return [
                SELECT Id, IsTaskCallReached__c
                FROM Task
                WHERE RecordTypeId = :callTaskRecordTypeId
                AND OwnerId = :userId
                AND CreatedDate = TODAY
                AND IsClosed = TRUE 
        ];
    }

    public static List<Task> getSPQTasks(Set<Id> opportunityId, String typeoftask) {
        Id recordId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(typeofTask).getRecordTypeId();
        return [
                select id,RecordTypeId,Status,Program__c,Description,IsClosed,Subject,TaskSubtype,IsParentClosing__c,WhatId
                from Task
                where whatid = :opportunityId and RecordTypeId = :recordId and status != 'Completed'
        ];
    }
    public static List<Task> getSPQTasksByTaskId(Set<Id> taskId, String typeoftask) {
        Id recordId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(typeofTask).getRecordTypeId();
        return [
                select id,RecordTypeId,Status,WhatId
                from Task
                where id = :taskId and RecordTypeId = :recordId and status != 'Completed' and WhatId != null
        ];
    }
    public static List<Task> getHappyCallTaskForAccounts(Set<Id> AccountIds){
        return [
                SELECT id,Program__c
                FROM Task
                WHERE WhatId in :AccountIds AND NextCallType__c = :Label.HCC_Next_Call_Type AND Type =:Label.HCC_Task_Type AND isClosed = false
                LIMIT 1
        ];
    }

}