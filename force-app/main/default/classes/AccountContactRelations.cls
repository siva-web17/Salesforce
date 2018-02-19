/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class AccountContactRelations {

    public static void sendDetailsToPoseidonAfterInsert(Map<Id, AccountContactRelation> newAccountContactMap,String DMLType)
    {
        system.debug('Inside sendDetailsToPoseidonAfterInsert');
        AccountContactRelationHelper.validateAndSendDetailsToPoseidon(newAccountContactMap,DMLType);
    }
}