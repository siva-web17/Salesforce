/**************************************************************************************
Apex Class Name    : DCSearchPlugin
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/29/2017              Original Version
 * Osiecki Adam              05/11/2018              Refactoring 
*******************************************************************************/
global class DCSearchPlugin implements dupcheck.dc3Plugin.InterfaceSearch
{
    global static void processResults(String methodName, Id sourceId, Map <string,Object> searchResults)
    {
        if (!(methodName=='ON_SEARCH;' || methodName=='ON_LAYOUT;' ||
                methodName=='ON_INSERT;' || methodName=='ON_CONVERT;'|| methodName=='ON_UPDATE;')) {
            DCBusinessFlow.dcSearchResults(methodName,sourceId,searchResults);
        }
        else if((methodName == 'ON_INSERT;' || methodName=='ON_LAYOUT;') && sourceId.getSObjectType()==Lead.getSObjectType()){

            Set<Id> sourceIdSet = new Set<Id>{sourceId};
            List<Lead> leads = LeadsSelector.getLeadsOnId(sourceIdSet);
            if(leads.size() > 0 && !leads[0].IsDupeProcessed__c){
                leads[0].IsDupeProcessed__c = true;
                update leads;
            }
        }
    }
}