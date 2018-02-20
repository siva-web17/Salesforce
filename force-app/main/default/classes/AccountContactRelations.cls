/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class AccountContactRelations {

    public static void sendDetailsToPoseidon(Map<Id, AccountContactRelation> newAccountContactMap,String DMLType,Boolean IsComplicatedBooking)
    {
        system.debug('Inside sendDetailsToPoseidonAfterInsert');
        AccountContactRelationHelper.validateAndSendDetailsToPoseidon(newAccountContactMap,DMLType,IsComplicatedBooking);
    }
}