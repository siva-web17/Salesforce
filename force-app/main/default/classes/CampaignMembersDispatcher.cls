/**************************************************************************************
Apex Class Name    : CampaignMembersDispatcher
Version            : 1.0
Created Date       : Jan 19 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej            19-Jan-2018             Original Version
*******************************************************************************/
public class CampaignMembersDispatcher {

    public static void Run() {
// Before trigger logic
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert)
                CampaignMembers.onBeforeInsert(trigger.new);

            if (Trigger.IsUpdate) {
                CampaignMembers.onBeforeUpdate(trigger.old, trigger.new);
            }

            if (Trigger.IsDelete)
                CampaignMembers.onBeforeDelete(trigger.oldMap);
        }

// After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert)
                CampaignMembers.onAfterInsert(Trigger.newMap);

            if (Trigger.IsUpdate)
                CampaignMembers.onAfterUpdate(trigger.newMap, trigger.oldMap);

            if (trigger.IsDelete)
                CampaignMembers.onAfterDelete(trigger.oldMap);

            if (trigger.isUndelete)
                CampaignMembers.onAfterUndelete(trigger.oldMap);
        }
    }
}