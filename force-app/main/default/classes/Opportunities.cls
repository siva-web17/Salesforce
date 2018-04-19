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
        OpportunitiesHelper.populateSalesOfficeProgram((List<Opportunity>) oppItems);
        OpportunitiesHelper.populateSourceBasedonSorceCodeAuto((List<Opportunity>) oppItems);
        OpportunitiesHelper.populateSourceCodeAutoAndPartnerFromSource((List<Opportunity>) oppItems);
    }

    public static void onBeforeUpdate(Map<Id, Sobject> newItems, Map<Id, Sobject> oldItems) {
        OpportunitiesHelper.setDefaultLetterAndLabel((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
        OpportunitiesHelper.passOpportunityListToPopulateSalesOfficeProgram((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
        OpportunitiesHelper.setDateOfDeactivation((Map<Id, Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(Map<Id, SObject> newItems) {
        OpportunitiesHelper.createShareOnInsert((List<Opportunity>) newItems.values());
    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        OpportunitiesHelper.createShareOnUpdateTypes((List<Opportunity>) newItems.values(), (List<Opportunity>) oldItems.values());
        OpportunitiesHelper.handleOwnerChange((List<Opportunity>) newItems.values(), (Map<Id, Opportunity>) oldItems);
        OpportunitiesHelper.handleProgramChange((List<Opportunity>) newItems.values(), (Map<Id, Opportunity>) oldItems);
        //OpportunitiesHelper.updateMarketCodeOnAccount((List<Opportunity>)newItems.values(),(List<Opportunity>)oldItems.values());
    }

    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}