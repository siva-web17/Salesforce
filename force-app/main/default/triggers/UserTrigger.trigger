/**************************************************************************************
Apex Class Name    : UserTrigger
Version            : 1.0
Created Date       : January 22 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Arkadiusz Celej             22/01/2018             Original Version
*******************************************************************************/
trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.User.Name);
    if(!isTriggerDisabled) {
        UsersDispatcher.Run();
    }
}