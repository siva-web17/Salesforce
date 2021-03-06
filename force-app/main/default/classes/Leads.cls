/**************************************************************************************
Apex Class Name    : Leads
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/29/2017              Original Version
 * Manos S                   12/19/2017              Code review version
 * Arkadiusz Celej           12/21/2017              Refactor
*******************************************************************************/
public class Leads {
     
    public static void onBeforeInsert(List<SObject> newItems) {
        LeadsHelper.updateHadAddressFilledOnCreation(newItems);
        LeadsHelper.populateSalesOfficeProgram(newItems);
        LeadsHelper.populateSourceBasedonSourceCodeAuto(newItems);
        Leadshelper.populateSourceCodeAutoAndPartnerFromSource(newItems); 
    }

    public static void onBeforeUpdate(List<Lead> oldLeadList,List<Lead> newLeadList){
        List<Lead> leadListforSalesOfficeUpdate = new List<Lead>();
        for(integer i=0;i< newLeadList.size();i++) {
            if(newLeadList[i].RecordSharingKey__c!= oldLeadList[i].RecordSharingKey__c)
            {
                leadListforSalesOfficeUpdate.add(newLeadList[i]);
            }
        }
        LeadsHelper.populateSalesOfficeProgram(leadListforSalesOfficeUpdate);
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(List<Lead>newItems) {
        LeadsHelper.createSystemCallTasksForLeadsEnteredManually(newItems);
       // LeadsHelper.createShareRecordsOnInsert(newItems);
    }

    public static void onAfterUpdate(List<SObject> newItems, Map<Id, SObject> oldItems) {
        LeadsHelper.handleProgramChange((List<Lead>)newItems, (Map<Id, Lead>)oldItems);
        LeadsHelper.processRanking((List<Lead>)newItems);
        LeadsHelper.handleOwnerChange((List<Lead>)newItems, (Map<Id, Lead>)oldItems);
      //  LeadsHelper.createShareOnUpdateTypes((List<Lead>)newItems, (List<Lead>)oldItems.values());
        CampaignMembersHelper.addOppToIMOnLeadConvert((List<Lead>)newItems);
        
    }
    
    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}