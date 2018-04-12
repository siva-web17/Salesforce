/**************************************************************************************
Apex Class Name    : HCCTaskDeferrerBatch
Version            : 1.0
Created Date       : April 11 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  11/04/2018              Original Version
*******************************************************************************/

public without sharing class HCCTaskDeferrerBatch implements Database.Batchable<SObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
                'SELECT Id, Status, Account.HasHappyCallTask__c '+
                        'FROM Task ' +
                        'WHERE (Status != \'Deferred\' OR Status = \'Completed\')' +
                        ' AND Account.HasHappyCallTask__c = TRUE' +
                        ' AND Account.ActiveOpportunities__c > 0'
        );
    }

    public void execute(Database.BatchableContext context,List<Task> scope){

        List<Task> tasks = new List<Task>();
        for(Task task : scope){
            task.Status = Label.Task_Status_Deferred;
            tasks.add(task);
        }
        try{
            update tasks;
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'HCCTaskDeferrerBatch', 'execute', null);
        }
    }

    public void finish(Database.BatchableContext bc){
    }

    //Scheduling method
    public void execute(SchedulableContext sc){
        HCCTaskDeferrerBatch tdb = new HCCTaskDeferrerBatch();
        Database.executeBatch(tdb);
    }
}