/**************************************************************************************
Apex Class Name    : QuoteTrigger
Version            : 1.0
Created Date       : March 16 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Thejasvi A                  03/16/2018              Original Version
*******************************************************************************/
trigger QuoteTrigger on Quote__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.Quote__c.Name);
    if(!isTriggerDisabled){
        QuotesDispatcher.run();
    }
}