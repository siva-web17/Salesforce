/**
 * Created by thejasvi.a on 10/13/2017.
 */

public class Events {
    public static void onBeforeInsert(List<Event> newItems) {
        EventsHelper.UpdateSubjectOnEvents(newItems);
    }

    public static void onBeforeUpdate(List<Event> newItems, Map<Id, SObject> oldItems) {
        EventsHelper.afterLeadToAccountMergeSetWhatIdToActiveOpportunity(newItems, (Map<Id, Event>)oldItems);
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(List<Event>newItems) {
        eventshelper.createAttachmentForQuestionAnswers(newItems);
        eventshelper.AddLeadOrContactAsCampaignMember(newItems);
        List<Id> Ids = new List<Id>();
        Ids = TasksHelper.filterEventsRelatedToOppotunity(newItems);
        List<Opportunity> opportunityRecord = OpportunitiesSelector.getAllEventsAndTasksforOpportunity(Ids);
        if(opportunityRecord.size()>0){
            TasksHelper.convertActivitiesToTask(opportunityRecord);
        }
        
    }

    public static void onAfterUpdate(List<Event>newItems, Map<Id, SObject> oldItems) {
        eventsHelper.afterEventsTransferFromAccountToActiveOpportunity(newItems, (Map<Id, Event>)oldItems);
        List<Id> Ids = new List<Id>();
        Ids = TasksHelper.filterEventsRelatedToOppotunity(newItems);
        List<Opportunity> opportunityRecord = OpportunitiesSelector.getAllEventsAndTasksforOpportunity(Ids);
        if(opportunityRecord.size()>0){
            TasksHelper.convertActivitiesToTask(opportunityRecord);
        }        
    }
    
    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}