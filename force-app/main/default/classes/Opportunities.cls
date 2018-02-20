/**************************************************************************************
Apex Class Name    : Opportunities
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/29/2017              Original Version
*******************************************************************************/
public class Opportunities {
    
 
    public static void onBeforeInsert(List<Opportunity> oppItems) {
        OpportunitiesHelper.populateSalesOfficeProgram((List<Opportunity>)oppItems);
    }
 
    public static void onBeforeUpdate(Map<Id,Sobject> newItems, Map<Id, Sobject> oldItems) {
        map<Id, opportunity> newOpportunityMap = (Map<Id, Opportunity>)newItems;
        map<Id, opportunity> oldOpportunityMap = (Map<Id, Opportunity>)oldItems;
        List<Opportunity> oppListforSalesOfficeUpdate = new List<Opportunity>();
        OpportunitiesHelper.setDefaultLetterAndLabel((Map<Id, Opportunity>)newItems, (Map<Id, Opportunity>)oldItems);

        for( Opportunity objOpportunity : newOpportunityMap.values()) {
            if( oldOpportunityMap.get(objOpportunity.Id).RecordSharingKey__c != newOpportunityMap.get(objOpportunity.Id).RecordSharingKey__c)
            {
                oppListforSalesOfficeUpdate.add(objOpportunity);
            }
        }
        OpportunitiesHelper.populateSalesOfficeProgram(oppListforSalesOfficeUpdate);

    }
 
    public static void onBeforeDelete(Map<Id, SObject> oldItems) {}
 
    public static void onAfterInsert(Map<Id, SObject> newItems) {
        OpportunitiesHelper.createShareOnInsert((List<Opportunity>)newItems.values());
    }
 
    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        OpportunitiesHelper.createShareOnUpdateTypes((List<Opportunity>)newItems.values(),(List<Opportunity>)oldItems.values());
        OpportunitiesHelper.handleOwnerChange((List<Opportunity>)newItems.values(), (Map<Id, Opportunity>)oldItems);
        OpportunitiesHelper.handleProgramChange((List<Opportunity>)newItems.values(), (Map<Id, Opportunity>)oldItems);
       //OpportunitiesHelper.updateMarketCodeOnAccount((List<Opportunity>)newItems.values(),(List<Opportunity>)oldItems.values());
    }
 
    public static void onAfterDelete(Map<Id, SObject> oldItems) {}
 
    public static void onAfterUndelete(Map<Id, SObject> oldItems) {}
}