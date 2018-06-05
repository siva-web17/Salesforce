/**************************************************************************************
Apex Class Name    : ConfirmRecordDeleteModalController
Version            : 1.0
Created Date       : March 13 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  03/13/2018              Original Version
*******************************************************************************/

public with sharing class ConfirmRecordDeleteModalController{

    /**
    * @author Adam Osiecki
    * ver 1.0 13-Mar-2018
    * @description Deletes records with selected Id
    *
    * @param recordId selected record Id
    */

    @AuraEnabled
    public static void deleteRecord(Id recordId){
        List<Id> ids = new List<Id>();
        ids.add(recordId);
        try{
            Database.delete(ids);
        }catch(DmlException exc){
            throw new AuraHandledException(exc.getMessage());
        }
    }

    @AuraEnabled
    public static string getSObjectType(Id recordId){
        return recordId.getSobjectType().getDescribe().getName();
    }
}