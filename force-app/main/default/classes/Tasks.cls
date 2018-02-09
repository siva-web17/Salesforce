/**************************************************************************************
Apex Class Name    : Tasks
Version            : 1.0
Created Date       : Jul 06 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Aneesh B                    07/06/2017              Original Version
*******************************************************************************/

public class Tasks {
    public static void onBeforeInsert(List<SObject> newItems)
    {
    }

    public static void onBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(Map<Id, SObject> newItems) {
        TasksHelper.updateParents(newItems, null);
        TasksHelper.setDefaultLetterAndLabelOnOpportunities((Map<Id, Task>)newItems);
    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        TasksHelper.updateParents(newItems, oldItems);
    }
    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}