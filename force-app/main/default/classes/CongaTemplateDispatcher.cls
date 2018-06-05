/**
 * Created by thejasvi.a on 9/20/2017.
**/

public without sharing class CongaTemplateDispatcher {
    public static void run() {
        //Before trigger logic
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert) {
                CongaTemplate.onBeforeInsert(trigger.new);
            }
            if (Trigger.IsUpdate) {
                CongaTemplate.onBeforeUpdate(trigger.old, trigger.new);
            }
            if (Trigger.IsDelete) {
                CongaTemplate.onBeforeDelete(trigger.oldMap);
            }
        }

        // After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert) {
                CongaTemplate.onAfterInsert(Trigger.new);
            }
            if (Trigger.IsUpdate) {
                CongaTemplate.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }
            if (trigger.IsDelete) {
                CongaTemplate.onAfterDelete(trigger.oldMap);
            }
            if (trigger.isUndelete) {
                CongaTemplate.onAfterUndelete(trigger.oldMap);
            }
        }
    }
}