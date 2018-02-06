/**************************************************************************************
Apex Class Name    : AccountTrigger
Version            : 1.0
Created Date       : Jan 04 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Arkadiusz Celej             04-Jan-2018              Original Version
*******************************************************************************/
trigger AccountTrigger on Account(before insert,before update,before delete,after update,after insert,after delete,after undelete)
{
    Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.Account.Name);
    if(!isTriggerDisabled) {
        AccountsDispatcher.Run();
    }
}