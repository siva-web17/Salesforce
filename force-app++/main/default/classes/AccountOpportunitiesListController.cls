/**************************************************************************************
Apex Class Name    : AccountOpportunitiesListController
Version            : 1.0
Created Date       : March 09 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  03/09/2018              Original Version
*******************************************************************************/

public without sharing class AccountOpportunitiesListController{

    public class OpportunityWrapper{

        @AuraEnabled
        public Opportunity Opportunity;

        @AuraEnabled
        public Boolean HasEditAccess;

        @AuraEnabled
        public Boolean HasReadAccess;

        @AuraEnabled
        public Boolean HasDeleteAccess;

        public OpportunityWrapper(
                Opportunity opportunity,
                Boolean hasEditAccess,
                Boolean hasReadAccess,
                Boolean hasDeleteAccess
        ){
            this.Opportunity = opportunity;
            this.HasEditAccess = hasEditAccess;
            this.HasReadAccess = hasReadAccess;
            this.HasDeleteAccess = hasDeleteAccess;
        }
    }

    /**
    * @author Adam Osiecki
    * ver 1.0 09-Mar-2018
    * @description Returns list of OpportunityWrapper containing Opportunity data and its
    * UserRecordsAccesses
    *
    * @param accountId selected Account Id
    *
    * @return List<OpportunityWrapper> accesses for selected Ids, contains opportunity
    * data and booleans for delete, edit and read access
    */

    @AuraEnabled
    public static List<OpportunityWrapper> getOpportunities(Id accountId){

        Set<Id> idSet = new Set<Id>();
        idSet.add(accountId);
        Map<Id, Opportunity> m = getMapOpportunitiesByAccountId(idSet);

        Set<Id> ids = new Set<Id>();
        ids = m.keySet();

        List<UserRecordAccess> userRecordAccesses = UserRecordAccessSelector.getUserRecordAccesses(ids);
        List<OpportunityWrapper> opportunityWrappers = getOpportunityWrappers(m,userRecordAccesses);
        return opportunityWrappers;
    }

    private static List<OpportunityWrapper> getOpportunityWrappers(Map<Id, Opportunity> opportunities,List<UserRecordAccess> userRecordAccesses){

        List<OpportunityWrapper> opportunityWrappers = new List<OpportunityWrapper>();
        for(UserRecordAccess ura : userRecordAccesses){
            Opportunity opp = opportunities.get(ura.RecordId);
            OpportunityWrapper oppWrap = new OpportunityWrapper(
                    opp,
                    ura.HasEditAccess,
                    ura.HasReadAccess,
                    ura.HasDeleteAccess
            );
            opportunityWrappers.add(oppWrap);
        }
        return opportunityWrappers;
    }

    /**
    * @author Adam Osiecki
    * ver 1.0 09-Mar-2018
    * @description Returns map of Opportunities for selected Account
    *
    * @param accountId account Ids to select
    *
    * @return Map<Id,Opportunity>
    */

    private static Map<Id, Opportunity> getMapOpportunitiesByAccountId(Set<Id> accountIds){
        List<Opportunity> opportunities = OpportunitiesSelectorWithoutSharing.getOpportunitiesByAccountId(accountIds);
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunities);
        return opportunityMap;
    }
}