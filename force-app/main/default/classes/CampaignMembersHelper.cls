/**************************************************************************************
Apex Class Name    : CampaignMembersHelper
Version            : 1.0
Created Date       : Jan 19 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej            19-Jan-2018             Original Version
*******************************************************************************/
public class CampaignMembersHelper {

    /**
     * author Arkadiusz Celej
     *
     * @description This method updates Opportunity__c reference on given Campaign Member records.
     * Opportunity Id is taken based on member PersonAccount
     * @param List<CampaignMember> campaignMembers
     */
    public static void synchronizeOpportunityOnCamapignMember(List<CampaignMember> campaignMembers){
        Set<Id> contactIds = new Set<Id>();
        for(CampaignMember cm : campaignMembers){
            contactIds.add(cm.ContactId);
        }
        List<Account> accountsWithOpportunities = AccountsSelector.getAccountsWithOpportunitiesByContactIds(contactIds);
        Map<Id, Opportunity> opportunitiesByContactIds = new Map<Id, Opportunity>();
        for(Account acc : accountsWithOpportunities){
            if(acc.Opportunities.size() > 0 && !opportunitiesByContactIds.containsKey(acc.PersonContactId)){
                opportunitiesByContactIds.put(acc.PersonContactId, acc.Opportunities[0]);
            }
        }

        for(CampaignMember cm : campaignMembers){
            if(opportunitiesByContactIds.containsKey(cm.ContactId)){
                cm.Opportunity__c = opportunitiesByContactIds.get(cm.ContactId).Id;
            }
        }
    }
}