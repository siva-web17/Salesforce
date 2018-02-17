/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class AccountContactRelationDispatcher {
    public static void Run()
    {
        // Before trigger logic
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert)
                Accounts.onBeforeInsert(trigger.new);

            if (Trigger.IsUpdate){
                Accounts.onBeforeUpdate(trigger.old,trigger.new);
            }

            if (Trigger.IsDelete)
                Accounts.onBeforeDelete(trigger.oldMap);
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