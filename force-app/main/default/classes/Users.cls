/**************************************************************************************
Apex Class Name    : Users
Version            : 1.0
Created Date       : Jan 22 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej             22/01/2018             Original Version
*******************************************************************************/
public class Users {
//    public static void onBeforeInsert(List<SObject> newItems){
//    }
//
//    public static void onBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
//    }
//
//    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
//    }
//
    public static void onAfterInsert(Map<Id, SObject> newItems) {
        UsersHelper.createUsersGroupMembership((Map<Id, User>)newItems);
    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        UsersHelper.synchronizeUsersGroupMembership((Map<Id, User>)newItems, (Map<Id, User>)oldItems);
    }
}