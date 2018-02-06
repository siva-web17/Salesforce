/**************************************************************************************
Apex Class Name    : CampaignMemberTrigger
Version            : 1.0
Created Date       : Jan 19 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Arkadiusz Celej             19-Jan-2018              Original Version
*******************************************************************************/
trigger CampaignMemberTrigger on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.CampaignMember.Name);
    if(!isTriggerDisabled) {
        CampaignMembersDispatcher.Run();
    }
}