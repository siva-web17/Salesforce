/**************************************************************************************
Apex Class Name    : AccountsDispatcher
Version            : 1.0
Created Date       : Jan 04 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej            04-Jan-2018             Original Version
*******************************************************************************/
public class AccountsDispatcher {

    public static void Run()
    {
        // Before trigger logic
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert)
                Accounts.onBeforeInsert(trigger.new);
 
            if (Trigger.IsUpdate){
                 Accounts.onBeforeUpdate(trigger.old,trigger.new);
                 }
 
            if (Trigger.IsDelete)
                Accounts.onBeforeDelete(trigger.oldMap);
        }
         
        // After trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert)
                Accounts.onAfterInsert(Trigger.newMap);
 
            if (Trigger.IsUpdate)
                Accounts.onAfterUpdate(trigger.newMap, trigger.oldMap);
 
            if (trigger.IsDelete)
                Accounts.onAfterDelete(trigger.oldMap);
 
            if (trigger.isUndelete)
                Accounts.onAfterUndelete(trigger.oldMap);
        }
    }
}