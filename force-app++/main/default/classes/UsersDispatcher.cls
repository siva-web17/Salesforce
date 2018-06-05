/**************************************************************************************
Apex Class Name    : UsersDispatcher
Version            : 1.0
Created Date       : January 22 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej             22/01/2018              Original Version
*******************************************************************************/
public class UsersDispatcher {
    public static void run() {
        // Before trigger logic
//        if (Trigger.IsBefore) {
//            if (Trigger.IsInsert)
//                Users.onBeforeInsert(trigger.new);
//
//            if (Trigger.IsUpdate)
//                Users.onBeforeUpdate(trigger.newMap, trigger.oldMap);
//
//            if (Trigger.IsDelete)
//                Users.onBeforeDelete(trigger.oldMap);
//        }

        // After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert)
                Users.onAfterInsert(Trigger.newMap);

            if (Trigger.IsUpdate)
                Users.onAfterUpdate(trigger.newMap, trigger.oldMap);
//
//            if (trigger.IsDelete)
//                Users.onAfterDelete(trigger.oldMap);
//
//            if (trigger.isUndelete)
//                Users.onAfterUndelete(trigger.oldMap);
        }
    }
}