/**
 * Created by aditi.sharma on 9/5/2017.
 */

public class DCBusinessFlow {
    public static Lead sourceLead ;
    public static Lead duplicateLead = new Lead();
    public static Account duplicateAccount = new Account();
    public static Boolean isLeadDupe = false;
    public static Boolean isAccountDupe = false;
    PUBLIC STATIC Boolean noDupe = FALSE;
    public static String latestCustomerRequsetType = 'BR';  
    public static String sourceCustomerRequstType = '';
    public static string numberOfDuplicate ;
    public static void dcSearchResults(String methodName, Id sourceId, Map <String, Object> searchResults) {
        try {
            system.debug('search result ' + searchResults);
            List<Lead> sourceLeadList = new List<Lead>();
            sourceLeadList = LeadsSelector.getLeadsOnId(new Set<id>{sourceId});

            if(!sourceLeadList.isEmpty()){
                sourceLead = new Lead();
                sourceLead=sourceLeadList[0];
            }
            //load custom setting
            DCMergeRuleEngine.loadMergeConfigRuleData();
            Map<Id, Lead> duplicateMap = new Map<Id, Lead>();
            if (sourceLead != null && !sourceLead.IsDupeProcessed__c) {
                sourceLead.IsDupeProcessed__c = true;
                sourceLead.DuplicateRecordSets__c = string.valueof(searchResults.values());
                Id duplicateAccountId;
                duplicateMap = duplicateRecords(searchResults);
              list<object> allDuplicateRecords = new list<object>();
               
                for (string objectType : searchResults.keySet()) {                
                    system.debug('before if>>>>'+searchResults.get(objectType));
                    list<object> emptyObj=new list<object>();
                    emptyObj.clear();
                     if(searchResults.get(objectType) != emptyObj){
                    allDuplicateRecords.add((List<Object>) searchResults.get(objectType));            
                   }
                                                   
               }
               for (string objectType : searchResults.keySet()) {
                    List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
                    system.debug('Lead list size'+duplicateObjects.size());
                    if (duplicateObjects.size() == 1 && allDuplicateRecords.size()==1) {
                         sourceLead.IsDupe__c = true ;
                         noDupe = false;
                        //Lead - Leads are duplicates
                        if (objectType == System.Label.LeadPrefix) {
                            isLeadDupe = true;
                            numberOfDuplicate = '1';
                            dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                            duplicateLead = (Lead) result.objectData;
                            if (duplicateMap.containsKey(duplicateLead.id)) {
                                duplicateLead = duplicateMap.get(duplicateLead.id);
                            }
                        }
                        //Account - accounts are duplicates
                        else if (objectType == System.Label.AccountPrefix) {
                            isAccountDupe = true;
                            numberOfDuplicate = '1';
                            dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                            Account duplicateAccount = (Account) result.objectData;
                            duplicateAccountId = duplicateAccount.Id;
                        }
                    } else if (duplicateObjects.size() > 1 || allDuplicateRecords.size()>1) {
                        sourceLead.IsDupe__c = true ;
                        numberOfDuplicate='Multiple';
                        noDupe = false;
                        break;
                    }
                    else if(duplicateObjects.size()==0){
                        noDupe = true;
                        numberOfDuplicate = '0';
                    }
                }
                duplicateAccount = duplicateAccountId != null?
                        AccountsSelector.getAccountOnId(duplicateAccountId):null;
                system.debug('Number of duplicates'+numberOfDuplicate);
                if (isAccountDupe || isLeadDupe) {
                    decision();
                }
                
                else if(noDupe){
                    DCBusinessFlowHelper.notifyForRanking(sourceLead);
                }
                else {
                    SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});
                }
            }
        }catch (Exception ex) {
            system.debug('---------ecx-------- ***'+ex.getMessage());
            system.debug('-------------err------- ***'+ex.getStackTraceString());
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessFlow', 'dcSearchResults', null);}

    }

    public static void decision() {
        string decisionFound = '';
        system.debug('I am here in decision ****');
        String finalDecision = '';
        Lead finalLead = new Lead();
        //sourceCustomerRequstType = latestActivityType(sourceLead);
        sourceCustomerRequstType = EventsSelector.retrieveLatestEventTypeOnLead(sourceLead);
        latestCustomerRequsetType = EventsSelector.retrieveLatestEventTypeOnLead(duplicateLead);
        //automerge
        if(isLeadDupe) {
                system.debug('Duplicate with Lead');
                finalDecision = DCMergeRuleEngine.findAutoMergeRule(duplicateLead,sourceLead, null);
                system.debug('final decision'+finalDecision);
                //merge fields
                if((finalDecision!=null &&  finalDecision=='Merge')) {
                        system.debug('I found the decision');
                    finalLead = DCObjectMerge.leadToLeadFieldMerge(duplicateLead,sourceLead);
                    finalLead.status = finalLead.status=='closed'?'open':finalLead.status;
                    finalLead.isdupe__c = false;
                    finalLead.readyforranking__c=false;
                    finalLead.RecalculateRanking__c = true;
                    finalLead.IsCAMOnly__c=!(duplicateLead.RequestType__c != 'CAM' || sourceLead.RequestType__c != 'CAM' );
                    Set<Id> duplicateLeadIdSet=new Set<Id>();
                    duplicateLeadIdSet.add(sourceLead.Id);
                    transferEvent(duplicateLead,duplicateLeadIdSet,finalDecision);
                    transferNotes(duplicateLead,duplicateLeadIdSet,finalDecision);
                    transferCampaignMember(duplicateLead,duplicateLeadIdSet,finalDecision);
                      update finalLead;
                    Set<Id> idsToDelete=New Set<Id>();
                    idsToDelete.add(duplicateLead.Id);
                    idsToDelete.add(sourceLead.Id);
                    deleteAutoMergedRecordsFromDCJOBs(idsToDelete);
                    SObjectUnitOfWork.deleteLead(sourceLead);
                  
                }
                else{
                    SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});
                }
        }
        else {
            system.debug('Duplicate with account');
            //account merge
            //1.step - merge the account with lead
            finalDecision = DCMergeRuleEngine.findAutoMergeRule(sourceLead,null,duplicateAccount);
            system.debug('--------finalDecision-------'+finalDecision);
            if((finalDecision!=null &&  finalDecision=='Merge')) {
                sourceLead.isAccountMerge__c = true;
                sourceLead.RecalculateRanking__c = true;
                update sourceLead;
                duplicateAccount = DCObjectMerge.leadtoAccountFieldMerge(duplicateAccount,sourceLead);
                convertsourcelead();
                //3. update the fields
               // duplicateAccount.RecalculateRanking__c = true;
                Set<Id> idsToDelete=New Set<Id>();
                idsToDelete.add(sourceLead.Id);
                idsToDelete.add(duplicateAccount.Id);
                deleteAutoMergedRecordsFromDCJOBs(idsToDelete);
                update duplicateAccount;
               
            }
            else{
                SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});

            }
            //4.step transfer opportunity
           // DCBusinessFlowHelper.notifyForRanking(sourceLead);
        }
    }

    //convert the lead to account
    public static void convertsourcelead() {
        //query the opportunity
        List<Opportunity> opportuntyList = OpportunitiesSelector.dupeCheckOpportunities(duplicateAccount);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(sourceLead.id);
        lc.setAccountId(duplicateAccount.id);
        lc.setConvertedStatus(System.Label.LeadStageConverted);
        system.debug('*********** opportunity list'+opportuntyList);
        if(opportuntyList != null && !opportuntyList.isEmpty()) {            
                lc.setOpportunityId(opportuntyList[0].id);
                Opportunity opportunityRecord = opportuntyList[0];
                List<Event> eventType = [SELECT Id,Type From Event Where WhatId = :opportuntyList[0].id
                ORDER BY CreatedDate DESC Limit 1];
                if(eventType != null && !eventType.isEmpty()) {
                    latestCustomerRequsetType = eventType[0].Type;
                }
              //  DCObjectMerge.modifyOpportuntiy(sourceLead, opportunityRecord);

        }             
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        list<opportunity> inactiveOpportunity = new list<opportunity>();
          inactiveOpportunity = [select id,Ranking__c from opportunity where accountid=:lcr.getAccountId() and isactive__c=false order by createddate desc limit 1];
         if(inactiveOpportunity!=null && !inactiveOpportunity.isempty()){
            opportunity newlyCreatedActiveOpportunity = new opportunity();
            newlyCreatedActiveOpportunity.id = lcr.getOpportunityId();
            newlyCreatedActiveOpportunity.Ranking__c = inactiveOpportunity[0].Ranking__c!=null?inactiveOpportunity[0].Ranking__c:null;
            update newlyCreatedActiveOpportunity;
        }
    }

    //transfer the event from duplicate lead to source lead
    public static void transferEvent(Lead sourceLead, Set<Id> duplicateLeadIdSet,String decisionName) {
        List<Event> eventList = new List<Event>();        
        for(Event eventRecord : [Select id,WhoId,Type From Event Where WhoId in:duplicateLeadIdSet
                ORDER BY CreatedDate DESC]) {
            eventRecord.whoId = sourceLead.id;
            eventRecord.MergeReason__c = decisionName;
            eventList.add(eventRecord);
        }
        SObjectUnitOfWork.executeUpdateEvents(eventList);
        
    }
  public static void transferNotes(Lead sourceLead, Set<Id> duplicateLeadIdSet,String decisionName){
      list<contentDocumentLink> contentDocumentLink = new list<contentDocumentLink>();
      for(contentDocumentLink objContentDocLink : [select id,ContentDocumentId ,LinkedEntityId from contentDocumentLink where LinkedEntityId in:duplicateLeadIdSet]){
        contentDocumentLink  contentDocumentLinkTransferObject = new contentDocumentLink ();
        contentDocumentLinkTransferObject.ContentDocumentId = objContentDocLink.ContentDocumentId;
        contentDocumentLinkTransferObject .LinkedEntityId = sourceLead.id;
        contentDocumentLinkTransferObject.ShareType='V';
        contentDocumentLink.add(contentDocumentLinkTransferObject);
      }
      insert contentDocumentLink;
    
    }
      public static void transferCampaignMember(Lead sourceLead, Set<Id> duplicateLeadIdSet,String decisionName){
      List<campaignMember> campaignMemberList = new List<CampaignMember>();
        for(campaignMember objcampaignMember : [select Leadid,id,status,campaignid from campaignmember where leadid in:duplicateLeadIdSet]){
            campaignMember campaignMemberForTransfer = new campaignMember();
            campaignMemberForTransfer.campaignId = objcampaignMember.campaignid;
            campaignMemberForTransfer.status = objcampaignMember.status;
            campaignMemberForTransfer.leadid = sourceLead.id;
            campaignMemberList.add(campaignMemberForTransfer);
        }
         insert campaignMemberList;
    }

    //this method is used to avoid soql query inside for loop
    public static Map<Id, Lead> duplicateRecords(Map <string, Object> searchResults) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        List<Id> leadIdList = new List<Id>();
        for (string objectType : searchResults.keySet()) {
            List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
            if (duplicateObjects.size() == 1 && objectType == System.Label.LeadPrefix) {
                dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                Lead duplicateLead = (Lead) result.objectData;
                if (duplicateLead != null) {
                    leadIdList.add(duplicateLead.id);
                }
            }
        }
        leadMap = LeadsSelector.leadRecordMap(leadIdList);
        return leadMap;
    }

    private static void deleteAutoMergedRecordsFromDCJOBs(Set<Id> recordIds)
    {
        List<dupcheck__dcQueue__c> queueList = new List<dupcheck__dcQueue__c>();
        for (Id d : recordIds) {
            queueList.add(new dupcheck__dcQueue__c(dupcheck__Type__c  = 'record-delete', dupcheck__Record__c = d, dupcheck__RecordId__c = d, dupcheck__Priority__c = 99));
        }
        insert queueList;
    }
}