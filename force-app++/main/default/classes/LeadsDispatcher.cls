/**************************************************************************************
Apex Class Name    : LeadsDispatcher
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/29/2017              Original Version
*******************************************************************************/
public class LeadsDispatcher {

    public static void run() {
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert) {
                Leads.onBeforeInsert(trigger.new);
            }
            if (Trigger.IsUpdate) {
                Leads.onBeforeUpdate(trigger.old, trigger.new);
            }
            if (Trigger.IsDelete) {
                Leads.onBeforeDelete(trigger.oldMap);
            }
        }
        // After trigger logic
        if (Trigger.IsAfter) {

            if (Trigger.IsInsert) {
                Leads.onAfterInsert(Trigger.new);
            }
            if (Trigger.IsUpdate) {
                Leads.onAfterUpdate(trigger.new, trigger.oldMap);
            }
            if (trigger.IsDelete) {
                Leads.onAfterDelete(trigger.oldMap);
            }
            if (trigger.isUndelete) {
                Leads.onAfterUndelete(trigger.oldMap);
            }
        }
    }
}