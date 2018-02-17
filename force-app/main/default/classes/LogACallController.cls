/**
 * Created by aneesh.bhat on 04-Sep-17. Controller for the LogACall Lightning component
 */

public with sharing class LogACallController {
    public static Map<String,TaskSetting__mdt> TaskSettingMetadata{get;set;}

    @auraEnabled
    public static String getInitialData(Id recordId){
        try{
            if(recordId.getSobjectType() == Lead.getSObjectType()){
                Lead lead = LeadsSelector.getLeadsOnId(new Set<Id>{recordId}).get(0);
               return JSON.serialize(new LogACallData(lead.Id,lead.CloseDate__c,lead.LikelihoodToBook__c,lead.HearAboutUs__c,lead.Destinations__c,lead.PreferredDuration__c,lead.WhenYear__c,lead.WhenMonth__c, true,0,lead.Program__c));
            }
            else if(recordId.getSobjectType() == Opportunity.getSObjectType()) {
                Opportunity opp = OpportunitiesSelector.getOpportunitiesOnId(new Set<Id>{recordId}).get(0);
                String data = JSON.serialize(new LogACallData(opp.Id,opp.CloseDate,opp.LikelihoodToBook__c,opp.HearAboutUs__c,opp.Destinations__c,opp.PreferredDuration__c,opp.WhenYear__c,opp.WhenMonth__c,opp.IsActive__c,opp.NumberOfUnreachedCalls__c, opp.Program__c));
                System.debug('Data :'+data);
                return data;
            }
            return null;
        }
        catch(Exception e){
            System.debug('Error in getInitialData() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string getSalesActions(){
        try{
            return JSON.serialize(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'SalesAction__c').keySet());
        }
        catch (Exception e){
            System.debug('Error in getSalesActions() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string getSubActions(){
        try{
            return JSON.serialize(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'CallNotReachedType__c').keySet());
        }
        catch (Exception e){
            System.debug('Error in getSubActions() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string getLikelihoodToBookOptions(Id recordId){
        try{
            return JSON.serialize(FieldUtilityClass.getPickListValues(recordId.getSobjectType(),'LikelihoodToBook__c').keySet());
        }
        catch (Exception e){
            System.debug('Error in getLikelihoodToBookOptions() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string getHearAboutUsOptions(Id recordId){
        try{
            return JSON.serialize(FieldUtilityClass.getPickListValues(recordId.getSobjectType(),'HearAboutUs__c').keySet());
        }
        catch (Exception e){
            System.debug('Error in getHearAboutUsOptions() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
   public static List<String> getDestinations(Id recordId) {
        System.debug('Point1');
        Set<String> uniqueGroupedLTDestinationName= new Set<String>();
        List<String> LTDestinations = new List<String>();
        List<String> nonLTDestinations = new List<String>();

        if(recordId.getSobjectType() == Opportunity.getSObjectType() ){
        Opportunity opportunityRecord = OpportunitiesSelector.getOpportunityRecord(recordId);
        boolean isLt = opportunityRecord.program__c == 'LT' ? true : false;
        List<Destination__c> destinationRecord = DestinationsSelector.getdestinationrecords(isLT);
        for(Destination__c destinationRec:destinationRecord){
            if( destinationRec.IsLT__c){
                if(uniqueGroupedLTDestinationName.add(destinationRec.GroupedLTDestinationName__c.touppercase())) {
                    LTDestinations.add(destinationRec.GroupedLTDestinationName__c);
                }
            }
            else if(!destinationRec.IsLt__c) {
                    nonLTDestinations.add(destinationRec.Name);
            }
        }
        if(isLt){
            return LTDestinations;
        }
        else{
            return nonLTDestinations;
        }
        }

        if(recordId.getSobjectType() == Lead.getSObjectType() ){
            Lead leadRecord = LeadsSelector.getLeadRecord(recordId);
            boolean isLt = leadRecord.program__c == 'LT' ? true : false;
            List<Destination__c> destinationRecord = DestinationsSelector.getdestinationrecords(isLT);
            for(Destination__c destinationRec:destinationRecord){
                if( destinationRec.IsLT__c){
                    if(uniqueGroupedLTDestinationName.add(destinationRec.GroupedLTDestinationName__c.touppercase())) {
                        LTDestinations.add(destinationRec.GroupedLTDestinationName__c);
                    }
                }
                else if(!destinationRec.IsLt__c) {
                    nonLTDestinations.add(destinationRec.Name);
                }
            }
            if(isLt){
                return LTDestinations;
            }
            else{
                return nonLTDestinations;
            }
        }
        return null;
    } 
       @AuraEnabled
    public static List<string> getDurations(Id recordId){
        try{
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            if(String.valueOf(recordId).substring(0, 3) == '00Q') {
                Lead objectToUpdate = Database.query('SELECT Program__c FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1');
                Map<String, List<String>> dependentPicklists = FieldUtilityClass.GetDependentOptions(Lead.getSObjectType().getDescribe().getName(), 'Program__c', 'PreferredDuration__c');
                return dependentPicklists.get(objectToUpdate.Program__c);
            }
            else if(String.valueOf(recordId).substring(0, 3) == '006'){
                Opportunity objectToUpdate = Database.query('SELECT Program__c FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1');
                Map<String, List<String>> dependentPicklists = FieldUtilityClass.GetDependentOptions(Opportunity.getSObjectType().getDescribe().getName(), 'Program__c', 'PreferredDuration__c');
                return dependentPicklists.get(objectToUpdate.Program__c);
            }
            return new List<String>();
        }
        catch (Exception e){
            System.debug('Error in getDurations() :'+ e.getMessage());
            return new List<String>();
        }
    }

    @AuraEnabled
    public static string getCloseReasons(Id recordId){
        try{
            return JSON.serialize(FieldUtilityClass.getPickListValues(recordId.getSobjectType(),'CloseMainReason__c').keySet());
        }
        catch (Exception e){
            System.debug('Error in getCloseReasons() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static String getCallResults(String callAction,Id recordId){
        try{
            Map<String,List<String>> dependentPicklists = FieldUtilityClass.getFieldDependencies(Task.getSObjectType().getDescribe().getName(),'SalesAction__c','ResultType__c');

             Integer closeIndex = -1;

            List<String> callResults = dependentPicklists.get(callAction);
            if(recordId.getSobjectType() == Opportunity.getSObjectType() ){
                Opportunity opp = [Select Id,NumberOfUnreachedCalls__c FROM Opportunity WHERE Id = :recordId];
                if ((opp.NumberOfUnreachedCalls__c >= 3) && (callAction.toUpperCase() == Label.CallNotReached.toUpperCase())) {
                    callResults.add(Label.CloseOpp.toUpperCase());
                }
                return JSON.serialize(callResults);
            }
            else if(recordId.getSobjectType() == Lead.getSObjectType()) {
                Map<String,List<String>> dependentPicklists2 = FieldUtilityClass.getFieldDependencies(Task.getSObjectType().getDescribe().getName(),'SalesAction__c','ResultType__c');
                system.debug('dependentPicklists2>>>>'+dependentPicklists2);
                system.debug('dependentPicklists23>>>>'+JSON.serialize(dependentPicklists2.get(callAction)));
                return JSON.serialize(dependentPicklists2.get(callAction));

            }
            return null;

        }
        catch (Exception e){
            System.debug('Error in getCallResults() :'+ e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getProgramsForChange(Id recordId){
        Set<String> programs = null;
        try{
            String program = '';
            if(recordId.getSobjectType() == Opportunity.getSObjectType()){
                Opportunity opportunity = OpportunitiesSelector.getOpportunitiesOnId(new Set<Id>{recordId}).get(0);
                programs = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(),'Program__c').keySet();
                program = opportunity.Program__c;
            }
            else if(recordId.getSobjectType() == Lead.getSObjectType()){
                Lead lead = LeadsSelector.getLeadsOnId(new Set<Id>{recordId}).get(0);
                programs = FieldUtilityClass.getPickListValues(Lead.getSObjectType(),'Program__c').keySet();
                program = lead.Program__c;
            }

            if(programs.contains(program)){
                programs.remove(program);
            }
            if(programs.contains('MULTI')){
                programs.remove('MULTI');
            }
            return new List<String>(programs);
        }
        catch (Exception e){
            System.debug('Error in getProgramsForChange() :'+ e.getMessage());
            return new List<string>();
        }
    }

    @AuraEnabled
    public static Boolean isCustomerReached(Id recordId){
        if(recordId.getSobjectType() == Lead.getSObjectType()){
            return false;
        }
        else if(recordId.getSobjectType() == Opportunity.getSObjectType()) {
            Opportunity opp = OpportunitiesSelector.getOpportunitiesOnId(new Set<Id>{recordId}).get(0);
            return opp.FirstContactDateTime__c != NULL;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static String saveData(
            String callAction,
            String subAction,
            string comments,
            String callResult,
            DateTime actionDateTime,
            string closeReason,
            Id recordId,
            String program,
            Datetime visitDatetime,
            String likelihoodToBook,
            String hearAboutUs,
            String destination,
            String duration,
            String whenYear,
            String whenMonth,
            DateTime bookOn ){
        ApexResponse response = new ApexResponse();
        try
        {
            // Update the values selected in the UI on the Lead or Opportunity
            if(recordId.getSobjectType() == Lead.getSObjectType()){
                Lead lead = LeadsSelector.getLeadsOnId(new Set<Id>{recordId}).get(0);
                lead.status = lead.status=='closed'?'open':lead.status;
                lead.LikelihoodToBook__c = likelihoodToBook;
                lead.HearAboutUs__c = hearAboutUs;
                lead.Destinations__c = destination;
                lead.PreferredDuration__c = duration;
                if(bookOn != NULL){
                    lead.CloseDate__c = bookOn.date();
                }
                lead.WhenYear__c = whenYear;
                lead.WhenMonth__c = whenMonth;
                update lead;
            }
            else if(recordId.getSobjectType() == Opportunity.getSObjectType()){
                Opportunity opp =  OpportunitiesSelector.getOpportunitiesOnId(new Set<Id>{recordId}).get(0);

                // If an Opportunity is closed revive the Opportunity
                     if(opp.StageName == Label.SalesClosed ){
                    opp.TFBypassStageValidation__c = true;
                    opp.StageName = OpportunitiesSelector.getOpportunityStageName(opp);
                    opp.TimeOutDate__c=null;
                 
                   //set the closedate to two months from now if book on date is not changed else set it to the selected bookon date
                    date dateFromBookOn = date.newinstance(bookOn.year(), bookOn.month(), bookOn.day());
                    
                    if(bookOn == NULL||opp.CloseDate == bookOn.date()){
                      
                        opp.CloseDate = date.today().addmonths(2);
                    }
                    else{
                   
                        opp.CloseDate = bookOn.date();
                    }
                    
                    update opp;
                }
                else {
                    if(callResult.toUpperCase() == Label.CloseOpp.toUpperCase()){
                      opp.CloseDate = system.today();
                    }
                    else if(bookOn != NULL){
                        opp.CloseDate = bookOn.date();
                    }
                }
                    opp.LikelihoodToBook__c = likelihoodToBook;
                    opp.HearAboutUs__c = hearAboutUs;
                    opp.Destinations__c = destination;
                    opp.PreferredDuration__c = duration;
                    opp.WhenYear__c = whenYear;
                    opp.WhenMonth__c = whenMonth;
                    opp.TFBypassStageValidation__c = false;
                    update opp;
                }
            // If a call is reached on the Lead, convert the Lead to Opportunity directly
            if(String.valueOf(recordId).substring(0, 3) == '00Q' && LogACallHelper.allReachedItems.contains(callAction.toUpperCase())) {

                Lead leadToConvert = LeadsSelector.getLeadsOnId(new Set<Id>{recordId}).get(0);
                if (leadToConvert.FirstContactDateTime__c == NULL) {
                    leadToConvert.FirstContactDateTime__c = Datetime.now();
                    update leadToConvert;
                }

                if(callResult.toUpperCase() != Label.CloseOpp.toUpperCase()){
                    Database.LeadConvert leadConversion = new database.LeadConvert();
                    leadConversion.setLeadId(recordId);
                    leadConversion.setConvertedStatus(System.Label.LeadStageConverted);
                    leadConversion.setOpportunityName(leadToConvert.FirstName + ' ' + leadToConvert.LastName);
                    Database.LeadConvertResult lcr = Database.convertLead(leadConversion);
                    opportunity objOpp = new opportunity();
                    if(lcr.opportunityId != null){
                        objOpp.id = lcr.opportunityId;
                        objOpp.FirstContactDateTime__c = Datetime.now();
                        update objOpp;
                    }

                    Map<String,String> result = new Map<String,String>();
                    result.put('Id',lcr.opportunityId);
                    result.put('Type','Opportunity');
                    response.Result = result;
                }
            }

            // Create a new Task representing the Action that was just done and fill it with details
            Task task = new Task();
            task.SalesAction__c = callAction;
            task.description = comments;
            task.CallNotReachedType__c= subAction;
            task.ResultType__c = callResult;
            task.ActivityDateTime__c = Datetime.now();
           task.ActivityDate = Datetime.now().Date();
            task.Program__c = program;
            task.FollowUpDate__c = actionDateTime;
            task.CloseMainReason__c = closeReason;
            task.TaskSubtype = LogACallHelper.getTaskSubType(callAction);
            task.RecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.getSObjectType()).get(Label.CallTaskRecordTypeDeveloperName).Id;
            if(recordId.getSobjectType() == Lead.getSObjectType()&& response.Result == null) {
                task.WhoId = recordId;
            }
            else if(recordId.getSobjectType() == Opportunity.getSObjectType()){
                task.WhatId = recordId;
            }
            system.debug('response___'+response.Result);
            if(response.Result!=null && response.Result.containsKey('Id')){
                task.WhatId = response.Result.get('Id');
                LogACallHelper.handleLogAnAction(response.Result.get('Id'),task,visitDatetime);
            }
            else{
                system.debug('Iam here in else');
                LogACallHelper.handleLogAnAction(recordId,task,visitDatetime);
            }
        }
        catch(Exception ex){
            System.debug('Error :'+ ex.getMessage());
            response.ResponseCode = 'FAILURE';
            response.ErrorMessage = ex.getMessage();
            return JSON.serialize(response);
        }
        response.ResponseCode = 'SUCCESS';
        return JSON.serialize(response);
    }
}