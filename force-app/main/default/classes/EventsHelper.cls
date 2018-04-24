/**
 * Created by aneesh.bhat on 27-Oct-17.
 */

public class EventsHelper {
    public class ContentNoteAndEventLink {
        public id eventid;
        public id leadId;
        public blob camQsAndAnswersAsText;
    }
    public static list<ContentNoteAndEventLink> listOfContentNoteAndEventLink = new list<ContentNoteAndEventLink>();
    public static Map<String, TaskSetting__mdt> taskSettingsMap = MetaDataSelector.getTaskSettingMetada();
    public static map<blob, string> noteIdAndContentNoteContent = new map<blob, string>();
    public static list<ContentNote> listOfContentNote = new list<ContentNote>();
    public static list<ContentDocumentLink> listOfContentDocumentLink = new list<ContentDocumentLink>();
    // Updates the subject on all the events
    public static void updateSubjectOnEvents(List<Event> events) {
        for (Event newEvent : events) {
            UpdateSubjectOnEvent(newEvent);
        }
    }

    // Update the event subject to appropriate value
    public static void updateSubjectOnEvent(Event eventObj) {
        if (taskSettingsMap != null && taskSettingsMap.containsKey(eventObj.Type)) {
            String eventSubject = taskSettingsMap.get(eventObj.Type).TaskSubject__c;
            eventSubject = eventSubject + ' - ' + eventObj.Program__c;
            eventObj.Subject = String.isBlank(eventSubject) ? eventObj.Type : eventSubject;
        }
    }

    public static void createAttachmentForQuestionAnswers(list<event> newItems) {
        set<id> leadIdSet = new set<id>();
        try {
            for (event objEvents : [select id,whoid,CampaignName__c,type from event where id in:newItems and CampaignName__c != null and (type = 'CAM' or type = 'CBR')]) {
                if (objEvents.whoId != null && String.valueOf(objEvents.whoid).substring(0, 3) == '00Q') {
                    leadIdSet.add(objEvents.whoid);
                }
            }
            map<id, lead> leadIdCamQsAns = new map<id, lead>([select id,CampaignQuestionsAnswer__c from lead where id in:leadIdSet]);
            list<attachment> attachmentForQsAnsList = new list<attachment>();
            for (event objEvents : [select id,whoid,CampaignName__c,type from event where id in:newItems and CampaignName__c != null and (type = 'CAM' or type = 'CBR')]) {
                if (String.valueOf(objEvents.whoid).substring(0, 3) == '00Q' 
                && leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c != null
                && leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c != '') {
                    //adding a content note
                    String camQsAndAnswersAsText = getTheParsedJson(leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c);
                    ContentNoteAndEventLink objContentNoteAndEventLink = new ContentNoteAndEventLink();
                    objContentNoteAndEventLink.eventid = objEvents.id;
                    objContentNoteAndEventLink.camQsAndAnswersAsText = blob.valueof(camQsAndAnswersAsText);
                    objContentNoteAndEventLink.leadId = objEvents.whoid;
                    listOfContentNoteAndEventLink.add(objContentNoteAndEventLink);
                    ContentNote cn = new ContentNote();
                    cn.Title = objEvents.CampaignName__c;
                    system.debug('CamQsAns>>' + (leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c));
                    cn.Content = Blob.valueOf(camQsAndAnswersAsText);
                    listOfContentNote.add(cn);
                }
            }
            insert listOfContentNote;
            for (contentnote objcontentnote : listOfContentNote) {
                noteIdAndContentNoteContent.put(objcontentnote.content, objcontentnote.id);
            }
            for (ContentNoteAndEventLink ContentNoteAndEventLinkobj : listOfContentNoteAndEventLink) {
                ContentDocumentLink link2 = new ContentDocumentLink();
                link2.ContentDocumentId = noteIdAndContentNoteContent.get(ContentNoteAndEventLinkobj.camQsAndAnswersAsText);
                link2.LinkedEntityId = ContentNoteAndEventLinkobj.eventid;
                link2.ShareType = 'V';
                link2.Visibility = 'AllUsers';
                listOfContentDocumentLink.add(link2);
                ContentDocumentLink link3 = new ContentDocumentLink();
                link3.ContentDocumentId = noteIdAndContentNoteContent.get(ContentNoteAndEventLinkobj.camQsAndAnswersAsText);
                link3.LinkedEntityId = ContentNoteAndEventLinkobj.leadId;
                link3.ShareType = 'V';
                link3.Visibility = 'AllUsers';
                listOfContentDocumentLink.add(link3);
                system.debug('Contentdocid' + link2.id);
                system.debug('Contentdocid' + link2.id);

            }
            insert listOfContentDocumentLink;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'EventsHelper', 'createAttachmentForQuestionAnswers', null);
        }
    }
    public static string getTheParsedJson(string JsonBody) { 
        CampaignQAndA objCampaignQAndA = (CampaignQAndA) JSON.deserialize(jsonBody, CampaignQAndA.class);
        String campaignQAndAString = '';
        for (QuestionAndAnswer qAndA : objCampaignQAndA.CampaignQuestionAnswer) {
            if (qAndA.ExtraQuestion != NULL) {
                for (QuestionAndAnswer qAndANested : qAndA.ExtraQuestion) {
                    if (qAndANested.Question != NULL)
                        campaignQAndAString = campaignQAndAString + '<b>Question : </b>' + qAndANested.Question + '\n<b>Answer : </b>' + qAndANested.Answer + '\n';
                }
            }
            if (qAndA.Question != NULL)
                campaignQAndAString = campaignQAndAString + '<b>Question : </b>' + qAndA.Question + '\n<b>Answer : </b>' + qAndA.Answer + '\n';
        }
        return prepareContent(campaignQAndAString);
    }
    public static String prepareContent(String input) {
        String returnStr = input;
        if (input.contains('\n')) {
            system.debug('Linebreakishere');
            returnStr = '<p>' + input.replaceAll('\n', '</p><p>') + '</p>';
        }
        return returnStr;
    }
    public static void AddLeadOrContactAsCampaignMember(list<event>newItems) {
        list<CampaignMember> CamMemberList = new list<CampaignMember>();
        set<string> campaignUniqueId = new set<string>();
        for (event objEvents : [select id,whoid,InfoMeetingID__c,type from event where id in:newItems and type = 'IM' and InfoMeetingID__c != null]) {
            campaignUniqueId.add(string.valueof(objEvents.InfoMeetingID__c));
        }
        list<campaign> campaignList = [select id,CampaignID__c from campaign where CampaignID__c in:campaignUniqueId];
        map<string, string> mapOfCampaignSFIdandUniqueId = new map<string, string>();
        for (campaign objcampaign : campaignList) {
            mapOfCampaignSFIdandUniqueId.put(objcampaign.CampaignID__c, objcampaign.id);
        }

        for (event objEvents : [select id,whoid,InfoMeetingID__c,type from event where id in:newItems and type = 'IM' and InfoMeetingID__c != null]) {
            if (objEvents.whoId == null) {
                continue;
            }
            id objId = objEvents.whoid;
            String sObjName = objId.getSObjectType().getDescribe().getName();
            system.debug('My object name is' + sObjName);
            CampaignMember objCamMember = new CampaignMember();
            objCamMember.campaignid = mapOfCampaignSFIdandUniqueId.get(string.valueof(objEvents.InfoMeetingID__c));
            if (sObjName == 'Lead') {
                objCamMember.leadId = objEvents.whoid;
            }
            CamMemberList.add(objCamMember);
        }
        Database.SaveResult[] srList = Database.insert(CamMemberList, false);

    }
    public static void afterLeadToAccountMergeSetWhatIdToActiveOpportunity(List<Event> newEvents, Map<Id, Event> oldEvents){
        //set What id only for Customer Request events
        Id customerRequestId = RecordTypesSelector.getActiveRecTypesByDevName(Event.SObjectType).get(Label.CustomerRequestEventRecordTypeDeveloperName).Id;
        Set<Id> newContactIds = new Set<Id>();
        Set<Id> oldLeadIds = new Set<Id>();
        List<Event> validEvents = new List<Event>();
        for(Event newEvent : newEvents){
            Event oldEvent = oldEvents.get(newEvent.Id);
            if(newEvent.RecordTypeId == customerRequestId && newEvent.WhoId.getSobjectType() == Contact.SObjectType && oldEvent.WhoId.getSobjectType() == Lead.SObjectType && newEvent.WhatId == NULL){
                validEvents.add(newEvent);
                newContactIds.add(newEvent.WhoId);
                oldLeadIds.add(oldEvent.WhoId);
            }
        }
        if(validEvents.size() > 0) {
            Map<Id, Account> accountsByContactIds = new Map<Id, Account>();
            for(Account acc : AccountsSelector.getAccountsWithOpportunitiesByContactIds(newContactIds)){
                accountsByContactIds.put(acc.PersonContactId, acc);
            }
            Map<Id, Lead> leadsByIds = new Map<Id, Lead>(LeadsSelector.getLeadsByIdsALLROWS(oldLeadIds));
            Map<Id, OpportunitiesHelper.OpportunityDataWrapper> opportunityDataWrappersByAccountIds = new Map<Id, OpportunitiesHelper.OpportunityDataWrapper>();
            for(Event validEvent : validEvents){
                if(accountsByContactIds.containsKey(validEvent.WhoId)){
                    Account acc = accountsByContactIds.get(validEvent.WhoId);
                    if(acc.Opportunities.size() > 0) {
                        validEvent.WhatId = acc.Opportunities[0].Id;
                    }else{
                        OpportunitiesHelper.OpportunityDataWrapper wrapper;
                        if(!opportunityDataWrappersByAccountIds.containsKey(acc.Id)){
                            wrapper = new OpportunitiesHelper.OpportunityDataWrapper();
                            wrapper.account = acc;
                            wrapper.events = new List<Event>{validEvent};
                            wrapper.lead = leadsByIds.get(oldEvents.get(validEvent.Id).WhoId);
                            opportunityDataWrappersByAccountIds.put(acc.Id, wrapper);
                        }else{
                            wrapper = opportunityDataWrappersByAccountIds.get(acc.Id);
                            wrapper.events.add(validEvent);
                        }
                    }
                }
            }
            if(opportunityDataWrappersByAccountIds.values().size() > 0){
                System.enqueueJob(new OpportunitiesHelper.CreateActiveOpportunitiesQueueable(opportunityDataWrappersByAccountIds.values()));
            }
        }
    }

    public static void afterEventsTransferFromAccountToActiveOpportunity(List<Event> newEvents, Map<Id, Event> oldEvents){
        system.debug('Afterupdate>>>'+newEvents);
        Id customerRequestId = RecordTypesSelector.getActiveRecTypesByDevName(Event.SObjectType).get(Label.CustomerRequestEventRecordTypeDeveloperName).Id;
       
        list<opportunity> opportunitiesToBeUpdated = new list<opportunity>();
        Set<Id> validOpportunitiesId = new Set<Id>();
        for(Event newEvent : newEvents){
            Event oldEvent = oldEvents.get(newEvent.Id);
            if(newEvent.RecordTypeId == customerRequestId && newEvent.whatid!=null 
            && newEvent.whatid.getSobjectType() == opportunity.SObjectType 
            && ((oldEvent.whatid != null && oldEvent.whatid.getSobjectType()!= opportunity.SObjectType) || oldEvent.whatid == null) ){
                validOpportunitiesId.add(newEvent.whatid); 
            }
        }
        if(validOpportunitiesId.size() > 0) {
            Map<Id, opportunity> OpportunityWithEventsByCreatedDate = opportunitiesselector.getLatestEventForOpportunityOrderByCreatedDate(validOpportunitiesId);
            map<id,string> OpportunityWithPreviousStage = opportunitiesselector.getOpportunityStageNameForList(validOpportunitiesId);
          
           Map<id,opportunity> opportunityToBeRevivedMap= reviveSalesClosedOpportunities(OpportunityWithPreviousStage);
         
            opportunitiesToBeUpdated.addall(changeProgramForOpportunityOnNewActivity(OpportunityWithEventsByCreatedDate,opportunityToBeRevivedMap));
            
            update opportunitiesToBeUpdated;
            LogACallHelper.getOpportunitiesWithOpenSystemCallTask(OpportunityWithPreviousStage.keyset(),system.now(),'');
        }
    }
    public static Map<id,opportunity> reviveSalesClosedOpportunities(Map<id,string> OpportunitiesWithStageToBeRevivedMap){
        Map<id,opportunity> opportunityToBeRevivedMap = new Map<id,opportunity>();
        for(id objOppID :OpportunitiesWithStageToBeRevivedMap.keyset()){
            opportunity oppToBeRevived = new opportunity();
             oppToBeRevived.id = objOppID;
             oppToBeRevived.LastAutomationUpdateDateTime__c = system.now();
             oppToBeRevived.stagename = OpportunitiesWithStageToBeRevivedMap.get(objOppID);
             oppToBeRevived.CloseDate = system.today();
             oppToBeRevived.TimeOutDate__c=null;
             oppToBeRevived.RecalculateRanking__c=true;
             opportunityToBeRevivedMap.put(objOppID,oppToBeRevived);
        }
        return opportunityToBeRevivedMap;
    }
    public Static List<Opportunity> changeProgramForOpportunityOnNewActivity(map<Id,Opportunity> opportunityWithLatestEventsMap,map<Id,Opportunity> opportunityToBeRevivedMap){
        List<Opportunity> updatetedOppList=new List<Opportunity>();
        for(Opportunity objOpp:opportunityWithLatestEventsMap.values()){
            objOpp=(opportunityToBeRevivedMap.containsKey(objOpp.id))?opportunityToBeRevivedMap.get(objOpp.id):objOpp;
           
             if((opportunityWithLatestEventsMap.get(objOpp.id).events[0].type==label.Reservation 
             || objOpp.Program__c==Label.MULTI) ){                         
                  objOpp.Program__c = opportunityWithLatestEventsMap.get(objOpp.id).events[0].Program__c;
                  objOpp.RecalculateRanking__c=true;
             }
             updatetedOppList.add(objOpp);
        }
      
       return updatetedOppList; 
    }
}