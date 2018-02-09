/**
 * Created by harsh.mathur on 12/27/2017.
 */

trigger ApttusConfig2LineItemTrigger on Apttus_Config2__LineItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ApttusConfig2LineItemsDispatcher.run();
}