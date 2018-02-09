/**
 * Created by arjun.mohan on 8/18/2017.
 */

public class EventsSelector {
    
    /**Not in use 
    public static List<Event> getActivitiesProcessedForTaskCreation(List<Id> parentIds) {
        List<Event> eventList = new List<Event>();
        if(parentIds != null && parentIds.size() > 0){
            eventList = [Select Id, WhoId, WhatId, Subject, OwnerId, Type, SalesAction__c, Program__c, 
                         EventId__c,FalseBrochureProgramCodes__c, IsExpressCall__c, ProcessedforTaskcreation__c
                         from Event 
                         where ProcessedforTaskcreation__c = false 
                         and (WhoId in : parentIds or whatId in : parentIds)];        
        }
        return eventList;
    }**/

    /**Not in use
    //SF-188 this method used for task to event changes
    public static Event retrieveEvent(Id whoId) {
        return [Select Id, Whoid, WhatId, Program__c, Type, MergeReason__c 
                from Event 
                where WhoId = :whoId 
                order by CreatedDate Desc limit 1];
    }**/
    
    
    public static List<event> getEventsOnWhoIds(List<Id> whoIds) {
        return [Select Id, WhoId, WhatId, Program__c, Type, MergeReason__c 
                from Event 
                where WhoId in :whoIds];
    }
    
    /**Not in use
    //SF-188 capture the event reason
    public static List<Event> retrieveEventsOnLead(List<Id> leadIdList) {
        return [Select Id, WhoId, MergeReason__c 
                from Event 
                Where WhoId in :leadIdList];
    }**/
    
    //this is used on dupecheck to get latest event type
    public static String retrieveLatestEventTypeOnLead(Lead leadRecord) {        
        list <Event> eventRecord = new List<Event>();
        eventRecord = [Select Id, Type 
                       from Event 
                       where WhoId =:leadRecord.id
                       order by CreatedDate DESC 
                       Limit 1];
        
        if(eventRecord != null && !eventRecord.isempty()) {
            return eventRecord[0].Type;
        }
        return '';
    }
}