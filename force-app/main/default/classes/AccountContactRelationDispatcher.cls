/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class AccountContactRelationDispatcher {
    public static void Run()
    {
        // Before trigger logic
        if (Trigger.isAfter )
        {
           Boolean IsComplicatedBooking=false;
            system.debug('Inside AccountContactRelationDispatcher');
            if (Trigger.IsInsert)
            {
                system.debug('Inside AccountContactRelationDispatcher IsInsert');
                AccountContactRelations.sendDetailsToPoseidon((Map<Id, AccountContactRelation>)Trigger.newMap,Label.DMLTypeInsert,IsComplicatedBooking);
            }

            if (Trigger.IsUpdate){
                system.debug('Inside AccountContactRelationDispatcher IsUpdate');
                AccountContactRelations.sendDetailsToPoseidon((Map<Id, AccountContactRelation>)Trigger.newMap,Label.DMLTypeUpdate,IsComplicatedBooking);
            }

            if (Trigger.IsDelete)
            {
                system.debug('Inside AccountContactRelationDispatcher IsDelete');
                AccountContactRelations.sendDetailsToPoseidon((Map<Id, AccountContactRelation>)Trigger.oldMap,Label.DMLTypeDelete,IsComplicatedBooking);
            }

        }

        // After trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert)
                Accounts.onAfterInsert(Trigger.newMap);

            if (Trigger.IsUpdate)
                Accounts.onAfterUpdate(trigger.newMap, trigger.oldMap);

            if (trigger.IsDelete)
                Accounts.onAfterDelete(trigger.oldMap);

            if (trigger.isUndelete)
                Accounts.onAfterUndelete(trigger.oldMap);
        }
    }
}