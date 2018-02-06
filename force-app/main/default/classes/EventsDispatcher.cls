/**
 * Created by thejasvi.a on 10/13/2017.
 */

public class EventsDispatcher {
    public static void run() {        
        // Before trigger logic
        try {
            if (Trigger.IsBefore) {
                if (Trigger.IsInsert) {
                    Events.onBeforeInsert(trigger.new);
                }

                if (Trigger.IsUpdate) {
                    Events.onBeforeUpdate(trigger.old, trigger.new);
                }
                if (Trigger.IsDelete) {
                    Events.onBeforeDelete(trigger.oldMap);
                }
            }
        } catch (Exception e){}

        // After trigger logic
        if (Trigger.IsAfter) {

            if (Trigger.IsInsert) {
                Events.onAfterInsert(Trigger.new);
            }

            if (Trigger.IsUpdate) {
                Events.onAfterUpdate(Trigger.new);
            }

            if (trigger.IsDelete) {
                Events.onAfterDelete(trigger.oldMap);
            }

            if (trigger.isUndelete) {
                Events.onAfterUndelete(trigger.newMap);
            }
        }
    }
}