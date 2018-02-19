/**************************************************************************************
Apex Class Name    : AdjustmentLineItemTrigger
Version            : 1.0
Created Date       : September 14 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Arjun.Mohan                 09/14/2017              Original Version
*******************************************************************************/
trigger AdjustmentLineItemTrigger on Apttus_Config2__AdjustmentLineItem__c (before insert,before update,after update,after insert,after delete ,before delete,after undelete ){
    AdjustmentLineItemDispatcher.run();
}