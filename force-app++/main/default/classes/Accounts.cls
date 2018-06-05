/**************************************************************************************
Apex Class Name    : Accounts
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  07/16/2017              Original Version
*******************************************************************************/
public class Accounts {

    public static void onBeforeInsert(List<SObject> newItems) {
        AccountsHelper.updateNorwegianLanguage(newItems);
        AccountsHelper.updateHasAddress(newItems);
    }

    public static void onBeforeUpdate(List<Account> newItems, Map<Id, sObject> oldItems) {
        AccountsHelper.updateUnSubscribeFields(Trigger.new);
        if(!System.isBatch()) {
            if (!OpportunitiesHelper.isActiveChanged) {
                AccountsHelper.saveAccountInformation(new Map<Id, Account>(newItems), (Map<Id, Account>) oldItems);
            }
        }else if(!PoseidonAccountSyncBatch.SYNC_IN_PROGRESS){
            PoseidonSyncService.setSyncStatus(newItems, PoseidonSyncService.SyncStatusTodo);
        }
        AccountsHelper.updateNorwegianLanguage(newItems);
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(Map<Id, SObject> newItems) {

    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AccountsHelper.setDefaultLetterAndLabelOnOpportunities((List<Account>) newItems.values(), (Map<Id, Account>) oldItems);
        if (!OpportunitiesHelper.isActiveChanged) {
            AccountsHelper.saveFamilyAccountInformation((Map<Id, Account>) newItems, (Map<Id, Account>) oldItems);
        }
    }

    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }

}
