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
        Set<Id> setLeadIds = new Set<Id>();
        List<Event> lstEvents = new List<Event>();
        Map<Id, Lead> mapLeads = new Map<Id, Lead>();
        Map<Id, Id> mapEventIdLeadId = new Map<Id, Id>();
        Map<Event, ContentNote> mapEventContentNote = new Map<Event, ContentNote>();        
        
        try {        	
        	for(Event eventRecord : newItems){
        		if(eventRecord.CampaignName__c != null && eventRecord.WhoId != null 
        		   && String.valueOf(eventRecord.WhoId).subString(0, 3) == '00Q'
        		   && eventRecord.CampaignName__c != null && eventRecord.CampaignName__c != ''
        		   && (eventRecord.Type == 'CAM' || eventRecord.Type == 'CBR') ){
        			lstEvents.add(eventRecord);
        			setLeadIds.add(eventRecord.WhoId);   
        			mapEventIdLeadId.put(eventRecord.Id, eventRecord.WhoId);     			
        		}
        	}
        	if(lstEvents.size() <= 0){
        		return;
        	}
                
            mapLeads = new map<Id, Lead>([Select Id, CampaignQuestionsAnswer__c 
            							  from Lead 
            							  where Id in :setLeadIds]);			        
           
            for (event eventRecord : lstEvents) {
            	if(mapLeads.containskey(eventRecord.WhoId) 
            	   && mapLeads.get(eventRecord.WhoId).CampaignQuestionsAnswer__c != null 
            	   && mapLeads.get(eventRecord.WhoId).CampaignQuestionsAnswer__c != ''){
            		String camQsAndAnswersAsText = getTheParsedJson(mapLeads.get(eventRecord.WhoId).CampaignQuestionsAnswer__c);
	                ContentNote cn = new ContentNote();
	                cn.Title = eventRecord.CampaignName__c;	                
	                cn.Content = Blob.valueOf(camQsAndAnswersAsText);
	                mapEventContentNote.put(eventRecord, cn);
            	}
            }
            
            if(mapEventContentNote.size() > 0){
            	insert mapEventContentNote.values();
            }
            
            for (Event eventRecord : mapEventContentNote.keySet()) {
            	ContentDocumentLink cdLinkEvent = new ContentDocumentLink();
                cdLinkEvent.ContentDocumentId = mapEventContentNote.get(eventRecord).Id;
                cdLinkEvent.LinkedEntityId = eventRecord.Id;
                cdLinkEvent.ShareType = 'V';
                cdLinkEvent.Visibility = 'AllUsers';
                listOfContentDocumentLink.add(cdLinkEvent); 
                
                ContentDocumentLink cdLinkLead = new ContentDocumentLink();
                cdLinkLead.ContentDocumentId = mapEventContentNote.get(eventRecord).Id;
                cdLinkLead.LinkedEntityId = eventRecord.WhoId;
                cdLinkLead.ShareType = 'V';
                cdLinkLead.Visibility = 'AllUsers';
                listOfContentDocumentLink.add(cdLinkLead);
            }
            
            if(listOfContentDocumentLink.size() > 0){
            	insert listOfContentDocumentLink;
            }
        } 
        catch (Exception ex) {
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
        List<Event> validEvents = new List<Event>();
        for(Event newEvent : newEvents){
            Event oldEvent = oldEvents.get(newEvent.Id);
            if(newEvent.RecordTypeId == customerRequestId && newEvent.WhoId.getSobjectType() == Contact.SObjectType && oldEvent.WhoId.getSobjectType() == Lead.SObjectType && newEvent.WhatId == NULL){
                newContactIds.add(newEvent.WhoId);
                validEvents.add(newEvent);
            }
        }
        if(validEvents.size() > 0) {
            Map<Id, Account> accountsByContactIds = new Map<Id, Account>();
            for(Account acc : AccountsSelector.getAccountsWithOpportunitiesByContactIds(newContactIds)){
                accountsByContactIds.put(acc.PersonContactId, acc);
            }
            for(Event validEvent : validEvents){
                if(accountsByContactIds.containsKey(validEvent.WhoId) && accountsByContactIds.get(validEvent.WhoId).Opportunities.size() > 0){
                    validEvent.WhatId = accountsByContactIds.get(validEvent.WhoId).Opportunities[0].Id;
                }
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