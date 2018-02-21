/**
 * Created by aneesh.bhat on 27-Oct-17.
 */


public class EventsHelper {
public class ContentNoteAndEventLink{
      public id eventid;
      public id leadId;
      public blob camQsAndAnswersAsText;
       }
 public static list<ContentNoteAndEventLink> listOfContentNoteAndEventLink = new list<ContentNoteAndEventLink>();
    public static Map<String, TaskSetting__mdt> taskSettingsMap = MetaDataSelector.getTaskSettingMetada();
    public static map<blob,string> noteIdAndContentNoteContent = new map<blob,string>();
    public static list<ContentNote> listOfContentNote = new list<ContentNote>();
    public static list<ContentDocumentLink> listOfContentDocumentLink = new list<ContentDocumentLink>();
    // Updates the subject on all the events
    public static void updateSubjectOnEvents(List<Event> events){
        for ( Event newEvent : events ) {
            UpdateSubjectOnEvent(newEvent);
        }
    }

    // Update the event subject to appropriate value
    public static void updateSubjectOnEvent(Event eventObj){
        if(taskSettingsMap !=null && taskSettingsMap.containsKey(eventObj.Type)){
            String eventSubject = taskSettingsMap.get(eventObj.Type).TaskSubject__c;
            eventSubject = eventSubject +' - '+ eventObj.Program__c;
            eventObj.Subject = String.isBlank(eventSubject)? eventObj.Type : eventSubject;
        }
    }
        
    public static void createAttachmentForQuestionAnswers(list<event>newItems){
   set<id> leadIdSet = new set<id>();     
     for(event objEvents:[select id,whoid,CampaignName__c,type from event where id in:newItems and CampaignName__c!=null and (type='CAM' or type = 'CBR')]){   
         if(String.valueOf(objEvents.whoid).substring(0, 3) == '00Q'){
            leadIdSet.add(objEvents.whoid);
         }
      }
      map<id,lead> leadIdCamQsAns = new map<id,lead>([select id,CampaignQuestionsAnswer__c from lead where id in:leadIdSet]);
      list<attachment> attachmentForQsAnsList = new list<attachment>();     
     for(event objEvents:[select id,whoid,CampaignName__c,type from event where id in:newItems and CampaignName__c!=null and (type='CAM' or type = 'CBR')]){   
         if(String.valueOf(objEvents.whoid).substring(0, 3) == '00Q' && leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c!=null){              
                //adding a content note
                String camQsAndAnswersAsText =getTheParsedJson(leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c);
                ContentNoteAndEventLink objContentNoteAndEventLink = new ContentNoteAndEventLink();
                objContentNoteAndEventLink.eventid=objEvents.id;
                objContentNoteAndEventLink.camQsAndAnswersAsText =blob.valueof(camQsAndAnswersAsText);
                objContentNoteAndEventLink.leadId =  objEvents.whoid;
                listOfContentNoteAndEventLink.add(objContentNoteAndEventLink);                
                ContentNote cn = new ContentNote();
                cn.Title = objEvents.CampaignName__c;
                system.debug('CamQsAns>>'+(leadIdCamQsAns.get(objEvents.whoid).CampaignQuestionsAnswer__c));               
                cn.Content = Blob.valueOf(camQsAndAnswersAsText);
                listOfContentNote.add(cn);
               }
      }
      insert listOfContentNote;
        for(contentnote objcontentnote:listOfContentNote){
          noteIdAndContentNoteContent.put(objcontentnote.content,objcontentnote.id);
        }
        for(ContentNoteAndEventLink  ContentNoteAndEventLinkobj:listOfContentNoteAndEventLink){
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
                system.debug('Contentdocid'+link2.id);
                system.debug('Contentdocid'+link2.id);
                
                }
                insert listOfContentDocumentLink;
                   }
    public static string getTheParsedJson(string JsonBody){
        CampaignQAndA campaignQAndA = (CampaignQAndA)JSON.deserialize(jsonBody, CampaignQAndA.class);
        String campaignQAndAString = '';
        for(QuestionAndAnswer qAndA : campaignQAndA.CampaignQuestionAnswer){
            if(qAndA.ExtraQuestion != NULL){
                for(QuestionAndAnswer qAndANested : qAndA.ExtraQuestion){
                    if(qAndANested.Question != NULL)
                		campaignQAndAString = campaignQAndAString + '<b>Question : </b>'+ qAndANested.Question +'\n<b>Answer : </b>' + qAndANested.Answer + '\n'; 
            	}
        	}
            if(qAndA.Question != NULL)
            	campaignQAndAString = campaignQAndAString + '<b>Question : </b>'+ qAndA.Question +'\n<b>Answer : </b>' + qAndA.Answer + '\n';    
    	}
        return prepareContent(campaignQAndAString);
    }
    public static String prepareContent(String input)
    {
    String returnStr = input;
    if (input.contains('\n'))
    {
    system.debug('Linebreakishere');
        returnStr = '<p>' + input.replaceAll('\n','</p><p>') + '</p>';
    }
    return returnStr;
   }
    public static void AddLeadOrContactAsCampaignMember(list<event>newItems){ 
   list<CampaignMember> CamMemberList= new list<CampaignMember>();
        set<string> campaignUniqueId = new set<string>();
        for(event objEvents:[select id,whoid,InfoMeetingID__c,type from event where id in:newItems and type='IM' and InfoMeetingID__c!=null]){
            campaignUniqueId.add(string.valueof(objEvents.InfoMeetingID__c));
        }
        list<campaign> campaignList = [select id ,CampaignID__c from campaign where CampaignID__c in:campaignUniqueId];
        map<string,string> mapOfCampaignSFIdandUniqueId = new map<string,string>();
        for(campaign objcampaign:campaignList){
            mapOfCampaignSFIdandUniqueId.put(objcampaign.CampaignID__c,objcampaign.id);
        }


     for(event objEvents:[select id,whoid,InfoMeetingID__c,type from event where id in:newItems and type='IM' and InfoMeetingID__c!=null]){
        id objId =objEvents.whoid;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        system.debug('My object name is'+sObjName);
        CampaignMember objCamMember= new CampaignMember();
         objCamMember.campaignid = mapOfCampaignSFIdandUniqueId.get(string.valueof(objEvents.InfoMeetingID__c));
        if(sObjName=='Lead'){
          objCamMember.leadId= objEvents.whoid;
         }
         CamMemberList.add(objCamMember);
      }
      Database.SaveResult[] srList = Database.insert(CamMemberList, false);

      }
}