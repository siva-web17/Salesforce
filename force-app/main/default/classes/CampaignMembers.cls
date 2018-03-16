/**************************************************************************************
Apex Class Name    : CampaignMembers
Version            : 1.0
Created Date       : Jan 19 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej            19-Jan-2018             Original Version
*******************************************************************************/
public class CampaignMembers {

    public static void onBeforeInsert(List<SObject> newItems) {
        CampaignMembersHelper.synchronizeOpportunityOnCamapignMember(newItems);
    }
}