/**************************************************************************************
Apex Class Name    : AccountsHelper
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  07/16/2017              Original Version
*******************************************************************************/
public class AccountsHelper{

    /**
     * @author Arkadiusz Celej
     *
     * @description This method should track if changes made on Accounts should set/reset letter and label values for
     * corresponding opportunities
     *
     * @param newAccounts list of changed accounts
     * @param oldAccountsByIds map of original accounts
     */
    public static void setDefaultLetterAndLabelOnOpportunities(List<Account> newAccounts, Map<Id, Account> oldAccountsByIds){
        List<Id> accountsToResetTemplates = new List<Id>();
        Map<Id, Account> newAccountsById = new Map<Id, Account>(newAccounts);
        for(Account newAccount : newAccounts){
            Account oldAccount = oldAccountsByIds.get(newAccount.Id);
            if(newAccount.Language__c != oldAccount.Language__c || newAccount.PersonBirthdate != oldAccount.PersonBirthdate){
                accountsToResetTemplates.add(newAccount.Id);
            }
        }
        if(accountsToResetTemplates.size() > 0){
            List<Opportunity> opportunitiesWithSBRTasks = new List<Opportunity>();
            Map<Id, Date> accountBirthdatesByOppIds = new Map<Id, Date>();
            for(Opportunity o : OpportunitiesSelector.getOpportunitiesWithSBRTaskByAccountIds(accountsToResetTemplates)){
                if(o.Tasks.size() > 0){
                    opportunitiesWithSBRTasks.add(o);
                    accountBirthdatesByOppIds.put(o.Id, newAccountsById.get(o.AccountId).PersonBirthdate);
                }
            }
            if(opportunitiesWithSBRTasks.size() > 0) {
                List<Opportunity> changedOpportunities = OpportunitiesHelper.setTemplatesForOpportunities(opportunitiesWithSBRTasks, accountBirthdatesByOppIds);
                if(changedOpportunities.size() > 0){
                    update changedOpportunities;
                }
            }
        }
    }
}