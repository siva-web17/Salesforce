/**
 * Created by arjun.mohan on 2/19/2018.
 */

public  class SyncToPoseidonController {

    @AuraEnabled
    public static String SyncComplicatedBookingToPoseidon(String AccountId)
    {
        Set<Id> accountSet=new Set<Id>();
        accountSet.add(Id.valueOf(AccountId) );
        Map<Id,Account> accountMap=  AccountsSelector.getAccountDetailsbasedonAccountId(accountSet);
        return AccountsService.syncAccountDetailsToPoseidon(accountMap);

    }

}