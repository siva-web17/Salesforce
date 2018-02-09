/**************************************************************************************
Apex Class Name    : SObjectUnitOfWork
Version            : 1.0
Created Date       : Sep 14 2017
Function           :Please delete this class after merging code with Sprint DEV sandbox as we already have this class available there
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arjun.Mohan                 09/14/2017              Original Version
*******************************************************************************/
public  class SObjectUnitOfWork {

    //********DataBase methods for DML Operation************//
    public void insertSObjects(list<SObject> listofSObjectInsert) {
        if(listofSObjectInsert.size() > 0){
            insert listofSObjectInsert;
        }
    }

    public void updateSObjects(list<SObject> listofSObjectUpdate) {
        if(listofSObjectUpdate.size() > 0){
            insert listofSObjectUpdate;
        }
    }

    public void deleteSObjects(list<SObject> listofSObjectDelete) {
        if(listofSObjectDelete.size() > 0){
            insert listofSObjectDelete;
        }
    }

    //allOrNone==>False-Partial insert
    public Database.SaveResult[] databaseInsertSObjects(list<SObject> listofSObjectDBInsert,Boolean allOrNone) {
        Database.SaveResult[] saveRes;
        if(listofSObjectDBInsert.size() > 0){
            saveRes=Database.insert(listofSObjectDBInsert,allOrNone);
        }
        return saveRes;
    }

    //allOrNone==>False-Partial update
    public Database.SaveResult[] databaseUpdateSObjects(list<SObject> listofSObjectDBupdate,Boolean allOrNone) {
        Database.SaveResult[] updateRes;
        if(listofSObjectDBupdate.size() > 0){
            updateRes=Database.update(listofSObjectDBupdate,allOrNone);
        }
        return updateRes;
    }

    //allOrNone==>False-Partial delete
    public Database.DeleteResult[] databaseDeleteSObjects(list<SObject> listofSObjectDBdelete,Boolean allOrNone) {
        Database.DeleteResult[] delResult;
        if(listofSObjectDBdelete.size() > 0){
            delResult=Database.delete(listofSObjectDBdelete,allOrNone);
        }
        return delResult;
    }

    public static void createErrorLog(ErrorLog__c err) {
        insert err;
    }

    public static void createBulkErrorLog(List<ErrorLog__c> errList) {
        Database.insert(errList,false);
    }
    
    public static Boolean executeUpdateProductAttributeValues(List<Apttus_Config2__ProductAttributeValue__c> updateAttributeValues) {
        Boolean success = false;
        if (updateAttributeValues != null && updateAttributeValues.size() > 0) {
            update updateAttributeValues;
            success=true;
        }
        return success;
    }

    public static Boolean executeUpdateLineItemValues(List<Apttus_Config2__LineItem__c> updateLineItemValues) {
        Boolean success = false;
        if (updateLineItemValues != null && updateLineItemValues.size() > 0) {
            update updateLineItemValues;
            success=true;
        }
        return success;
    }
    
    public static void saveTasks(List<Task> tasksList) {
        try  {
            if (tasksList != null && tasksList.size() > 0) {
                system.debug('tasksList*>>>>>'+tasksList);
                system.debug('Upsert  '+tasksList);
                Database.UpsertResult [] upsertResults = Database.upsert(tasksList,false);
                Database.UpsertResult [] failedRecords=new Database.UpsertResult []{};
                for (Database.UpsertResult resultObj:upsertResults) {
                    if(!resultObj.isSuccess())
                    {

                    }
                }
                //database.upsert tasksList;
            }
        }
        catch(exception ex) {
            system.debug(ex);
        }
    }
    
     public static void modifyEvents(List<Event> eventList) {
        if (eventList != null && eventList.size()>0) {
            update eventList;
        }
    }
    
    public static Boolean executeUpdateLeads(List<Lead> updatableLeads) {
        Boolean success = false;
        if (updatableLeads != null && updatableLeads.size() > 0) {
            update updatableLeads;
        }
        return success;
    }
    
    public static void deleteLead(Lead leadRecord) {
        delete leadRecord;
    }
    
     public static void executeUpdateEvents(List<event> updatableEvent) {
        if (updatableEvent!= null && updatableEvent.size() > 0) {
            update updatableEvent;
        }
    }
    
    public static void executeUpdateOpportunities(List<Opportunity> updatablOpps) {
        if (updatablOpps != null && updatablOpps.size() > 0) {
            update updatablOpps;
        }
    }
    
    public static void modifyOpportunity(Opportunity opportunityRecord) {
        update opportunityRecord;
    }    
}