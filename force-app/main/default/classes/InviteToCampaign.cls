public with sharing class InviteToCampaign {

    @AuraEnabled
    public static Map<String,String> getMeetingTypes() {
        return FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'MeetingType__c');
    }

    @AuraEnabled
    public static Map<String,String> getMeetingCity(Id recordId) {
        Map<String, Map<String,String>> meetingCity = FieldUtilityClass.getFieldDependenciesMap(Campaign.getSObjectType().getDescribe().getName(), 'Market__c', 'MeetingCity__c');
        Opportunity opp = OpportunitiesSelector.getOpportunityrecord(recordId);
        return meetingCity.get(opp.Market__c);
    }

    @AuraEnabled
    public static Map<String,String> getProgram(Id recordId) { 
        Map<String, Map<String,String>> marketProgram = FieldUtilityClass.getFieldDependenciesMap(Campaign.getSObjectType().getDescribe().getName(), 'Market__c', 'Program__c');
        Opportunity opp = OpportunitiesSelector.getOpportunityRecord(recordId);
        return marketProgram.get(opp.Market__c);
    }

    @AuraEnabled
    public static Map<String,String> getSalesOffice(Id recordId) {
        Map<String, Map<String,String>> salesOffice = FieldUtilityClass.getFieldDependenciesMap(Campaign.getSObjectType().getDescribe().getName(), 'Market__c', 'SalesOffice__c');
        Opportunity opp = OpportunitiesSelector.getOpportunityRecord(recordId);
        return salesOffice.get(opp.Market__c);
    }

    @AuraEnabled
    public static List<Campaign> getCampaigns() {
        List<campaign> campaignRecords = CampaignsSelector.getActiveFutureCampaignRecords();
        return campaignRecords;
    }

    @AuraEnabled
    public static list<CampaignWrapper> getCampaignsWithFilter(String recordId, string salesOffice, string program, string meetingType, string meetingCity, datetime dateFrom, datetime dateTo) {
        String market = '';
        List<string> lstOfProgram = new List<string>();
        if(recordId != null && recordId != ''){
            Opportunity opp =  OpportunitiesSelector.getOpportunityRecord(recordId);
            market = opp.Market__c;
        }
        
        list<string> lstOfSalesOffice = new List<string>();
        if (salesoffice != null && salesoffice != '') {
            lstOfSalesOffice = (list<string>) JSON.deserialize(salesoffice, list<string>.class);
        }
        
        if (program != null && program != '') {
            lstOfProgram = (list<string>) JSON.deserialize(program, list<string>.class);
        }

        list<string> lstOfMeetingType = new List<string>();
        if (meetingType != null && meetingType != '') {
            lstOfMeetingType = (list<string>) JSON.deserialize(meetingType, list<string>.class);
        }

        list<string> lstOfMeetingCity = new List<string>();
        if (meetingCity != null && meetingCity != '') {
            lstOfMeetingCity = (list<string>) JSON.deserialize(meetingCity, list<string>.class);
        }

        string query = 'Select Id, SalesOffice__c, Program__c, MeetingType__c, MeetingCity__c, DateFrom__c, DateTo__c, IsUP__c, MeetingSize__c, Name from Campaign WHERE ';
        string statusValue = 'Active';

        if(market != ''){
            query += 'Market__c = :market' + ' AND ' ;
        }

        if (statusValue != null) {
            query += 'Status = :statusValue' + ' AND ' ;
        }
        
        if (lstOfSalesOffice.size() > 0) {
            query += 'SalesOffice__c in :lstOfsalesoffice' + ' AND ' ;
        }

        if (lstOfProgram.size() > 0) {
            query += 'Program__c in :lstOfprogram' + ' AND ' ;
        }

        if (lstOfMeetingType.size() > 0) {
            query += 'MeetingType__c in :lstOfmeetingType' + ' AND ';
        }

        if (lstOfMeetingCity.size() > 0) {
            query += 'MeetingCity__c in :lstOfmeetingCity' + ' AND ';
        }

        if (datefrom != null) {
            query += 'DateFrom__c >= :datefrom' + ' AND ';
        }

        if (dateto != null) {
            query += 'DateTo__c <= :dateto';
        }

        if (query.endsWith('AND ')) {
            query = query.substring(0, query.lastIndexOf(' AND '));

        }
        if (query.endsWith('WHERE ')) {
            query = query.substring(0, query.lastIndexOf(' WHERE '));
        }
        
        System.debug('Query :'+query);        
        System.debug('Sales Offices :'+lstOfSalesOffice);
        System.debug('Programs :'+lstOfProgram);
        System.debug('Meeting Types :'+lstOfMeetingType);
        System.debug('Meeting Cities :'+lstOfMeetingCity);
        List<campaign> campaignRecords = new List<campaign>();
        campaignRecords = Database.query(query);
        CampaignWrapper wrapperClassInitialise = new CampaignWrapper();
        list<CampaignWrapper> lstOfWrappers = new list<CampaignWrapper>();
        
        Map<Id, Integer> invitedMembersCount=new Map<Id, Integer> ();
        invitedMembersCount = CampaignMembersSelector.getCampaignMemberCount(campaignRecords);

        if ((campaignRecords.size() > 0) ) {
            for (campaign objCampaign :campaignRecords) {
                CampaignWrapper initializeWrapperClass = new CampaignWrapper();
                initializeWrapperClass.objWrapperCampaign = objCampaign;
                integer value = invitedMembersCount.get(objCampaign.id);
                initializeWrapperClass.InvitedCount = value;
                lstOfWrappers.add(initializeWrapperClass);
            }
        }
        return lstOfWrappers;
    }
    
    @AuraEnabled
    public static list<CampaignWrapper> getInitialCampaignData(String recordId,  datetime datefrom) {
        String market = '';
        List<string> lstOfProgram = new List<string>();
        if(recordId != null && recordId != ''){
            Opportunity opp = OpportunitiesSelector.getOpportunityRecord(recordId);
            market = opp.Market__c;
            lstOfProgram.add(opp.Program__c);
        }       

        string query = 'Select Id, Name, SalesOffice__c, Program__c, MeetingType__c, MeetingCity__c, DateFrom__c, DateTo__c, IsUP__c, MeetingSize__c from Campaign where ';
        string statusValue = 'Active';

        if(market != ''){
            query += 'Market__c = :market' + ' AND ' ;
        }

        if (statusValue != null) {
            query += 'Status = :statusValue' + ' AND ' ;
        }
        
         if (lstOfProgram.size() > 0) {
            query += 'Program__c in :lstOfprogram' + ' AND ' ;
        }
                
        if (datefrom != null) {
            query += 'DateFrom__c >= :datefrom' + ' AND ';
        }

        if (query.endsWith('AND ')) {
            query = query.substring(0, query.lastIndexOf(' AND '));

        }
        if (query.endsWith('WHERE ')) {
            query = query.substring(0, query.lastIndexOf(' WHERE '));
        }
       
        List<Campaign> campaignRecords = new List<campaign>();
        campaignRecords = Database.query(query);
        CampaignWrapper wrapperClassInitialise = new CampaignWrapper();
        list<CampaignWrapper> lstOfWrappers = new list<CampaignWrapper>();
        
       Map<Id, Integer> invitedMembersCount=new Map<Id, Integer> ();
        invitedMembersCount = CampaignMembersSelector.getCampaignMemberCount(campaignRecords);

        if ((campaignRecords.size()>0 ) ) {
            for (campaign objCampaign :campaignRecords) {
                CampaignWrapper initializeWrapperClass = new CampaignWrapper();
                initializeWrapperClass.objWrapperCampaign = objCampaign;
                integer value = invitedMembersCount.get(objCampaign.id);
                initializeWrapperClass.InvitedCount = value;
                lstOfWrappers.add(initializeWrapperClass);
            }
        }            
        return lstOfWrappers;
    }

    public class CampaignWrapper {
        @AuraEnabled
        public boolean isChecked = false;
        @AuraEnabled
        public Campaign objWrapperCampaign = new Campaign();
         @AuraEnabled
        public Integer invitedCount;
    }

    @AuraEnabled
    public static void AddCampaigns(string incomingCampaignList, Id OpportunityId) {
        try {
            System.Debug('Input Params : incomingCampaignList:'+incomingCampaignList+'  OppId:'+OpportunityId);
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            list<campaign> lstOfSelectedCampaign = (list<campaign>) JSON.deserialize(incomingCampaignList, list<campaign>.class);
            Id recordId = Id.valueOf(OpportunityId);
            System.debug('RecordId:'+recordId);
            Opportunity opportunityRecord = OpportunitiesSelector.getOpportunityRecord(recordId);
            System.debug('Opp Record:'+opportunityRecord);
            //Account accountRecord = AccountSelector.getAccountonOpportunity(opportunityRecord);
            //System.debug('Account Record:'+accountRecord);
            for (Campaign campaignRecord : lstOfSelectedCampaign) {
                if (opportunityRecord.Account.PersonContactId != null) {
                    System.debug('Entered If personal Id: ' + opportunityRecord.Account.PersonContactId);
                    CampaignMember member = new CampaignMember();
                    member.ContactId = opportunityRecord.Account.PersonContactId;
                    member.CampaignId = campaignRecord.Id;
                    member.status = 'Invited';
                    campaignMemberList.add(member);
                }
            }
            insert campaignMemberList;
        }
        catch (Exception ex) {
            String errMessage = ex.getMessage();
            String trace = ex.getStackTraceString();
            String className = 'InviteCampaign';
            String methodName = 'AddCampaigns';
            Id id = '';
            ExceptionHandler.errorLog(errMessage, trace, className, methodName, id);
        }
    }

    @AuraEnabled
    public static String getMarket(Id OpportunityId) {
        Id recordId = Id.valueOf(OpportunityId);
        Opportunity opportunityRecord = OpportunitiesSelector.getOpportunityRecord(recordId);
        string market = opportunityRecord.Market__c;
        return JSON.serialize(market);
    }
}