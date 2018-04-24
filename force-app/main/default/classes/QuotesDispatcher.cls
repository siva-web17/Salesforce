/**
 * Created by thejasvi.a on 3/16/2018.
 */

public with sharing class QuotesDispatcher {

    public static void run() {
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert) {
                Quotes.onBeforeInsert(trigger.new);
            }
            if (Trigger.IsUpdate) {
                Quotes.onBeforeUpdate(trigger.old, trigger.new);
            }
            if (Trigger.IsDelete) {
                Quotes.onBeforeDelete(trigger.oldMap);
            } 
        }
        // After trigger logic
        if (Trigger.IsAfter) {

            if (Trigger.IsInsert) {
                Quotes.onAfterInsert(Trigger.new);
            }
            if (Trigger.IsUpdate) {
                Quotes.onAfterUpdate(trigger.old, trigger.new);
            }
            if (trigger.IsDelete) {
                Quotes.onAfterDelete(trigger.oldMap);
            }
            if (trigger.isUndelete) {
                Quotes.onAfterUndelete(trigger.oldMap);
            }
        }
    }

}