/**************************************************************************************
Apex Class Name    : UserRecordAccessSelector
Version            : 1.0
Created Date       : March 09 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  03/09/2018              Original Version
*******************************************************************************/

public class UserRecordAccessSelector{

    /**
    * @author Adam Osiecki
    * ver 1.0 09-Mar-2018
    * @description Returns list of UserRecordAccessess (Delete, Edit and Read Access) for
    * a list of record Ids
    *
    * @param recordIds Ids of selected records of any type
    *
    * @return List<UserRecordAccess> accesses for selected Ids, contains booleans for delete,
    * edit and read access
    */

    public static List<UserRecordAccess> getUserRecordAccesses(Set<Id> recordIds){

        try{
            List<UserRecordAccess> userRecordAccesses = new List<UserRecordAccess>();
            userRecordAccesses = [
                    SELECT RecordId, HasDeleteAccess, HasEditAccess, HasReadAccess
                    FROM UserRecordAccess WHERE RecordId IN :recordIds
                    AND UserId = :UserInfo.getUserId()];
            return userRecordAccesses;
        }catch(Exception exc){
            throw new AuraHandledException('ERROR: ' + exc);
        }

    }
}