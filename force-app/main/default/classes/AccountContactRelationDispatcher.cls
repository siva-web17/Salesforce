/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class AccountContactRelationDispatcher {
    public static void Run()
    {
        // Before trigger logic
        if (Trigger.isAfter )
        {
            system.debug('Inside AccountContactRelationDispatcher');
            if (Trigger.IsInsert)
            {
                system.debug('Inside AccountContactRelationDispatcher IsInsert');
                AccountContactRelations.sendDetailsToPoseidonAfterInsert((Map<Id, AccountContactRelation>)Trigger.newMap,Label.DMLTypeInsert);
            }

            if (Trigger.IsUpdate){
                system.debug('Inside AccountContactRelationDispatcher IsUpdate');
                AccountContactRelations.sendDetailsToPoseidonAfterInsert((Map<Id, AccountContactRelation>)Trigger.newMap,Label.DMLTypeUpdate);
            }

            if (Trigger.IsDelete)
            {
                system.debug('Inside AccountContactRelationDispatcher IsUpdate');
                AccountContactRelations.sendDetailsToPoseidonAfterInsert((Map<Id, AccountContactRelation>)Trigger.oldMap,Label.DMLTypeDelete);
            }

        }

      
    }
}