/**
 * Created by arjun.mohan on 3/8/2018. new change
 */

public class CreatePriceQuoteController {

    public Opportunity oppObj { get; set; }
    public Task taskObj { get; set; }
    public String PQParamJson { get; set; }
    public String RecordId { get; set; }
    public String returnvalue { get; set; }
    public String displayMessage { get; set; }
    public String PriceQuoteURL { get; set; }

    public CreatePriceQuoteController(ApexPages.StandardController controller) {

        this.displayMessage = System.label.CreateBookinDisplayMessage;
        if (controller.getRecord().getSObjectType() == Opportunity.getSObjectType()) {
            this.oppObj = (Opportunity) controller.getRecord();
            RecordId = String.ValueOf(this.oppObj.Id);
        } else if (controller.getRecord().getSObjectType() == Task.getSObjectType()) {
            taskObj = (Task) controller.getRecord();
            RecordId = String.ValueOf(this.taskObj.Id);
        } else {
            RecordId = null;
        }
        this.PriceQuoteURL = ExternalRouter.getServiceURL('OpenPriceQuote');
        this.returnvalue = openPoseidonToCreateQuote();
        if (!String.isEmpty(this.returnvalue)) {
            this.displayMessage = this.returnvalue;
        }
    }

    public String openPoseidonToCreateQuote() {

        try {
            Id OppId = Id.valueOf(this.RecordId);
            Set<Id> recordIdSet = new Set<Id>();
            recordIdSet.add(OppId);
            Set<Id> accountSet = new Set<Id>();

            Map<String, String> createPQFieldvalues = new Map<String, String>();
            Map<Id, Opportunity> opportunityMap = NULL;
            if (!String.isEmpty(this.RecordId) && Id.valueOf(this.RecordId).getSobjectType() == Opportunity.getSObjectType()) {
                OppId = Id.valueOf(this.RecordId);
                opportunityMap = OpportunitiesSelector.getActiveOpportunitiesforPQ(recordIdSet);
            } else if (!String.isEmpty(this.RecordId) && Id.valueOf(this.RecordId).getSobjectType() == Task.getSObjectType()) {
                recordIdSet.add(Id.valueOf(this.RecordId));
                List<Task> objTaskList = TasksSelector.getSPQTasksByTaskId(recordIdSet, system.label.SPQTask);
                if (objTaskList != null && objTaskList.size() > 0) {
                    recordIdSet.clear();
                    OppId = objTaskList[0].WhatId;
                    recordIdSet.add(OppId);
                    opportunityMap = OpportunitiesSelector.getActiveOpportunitiesforPQ(recordIdSet);
                } else {
                    this.returnvalue = 'Price Quotes can Be created for Non Completed Tasks and Active Opportunities only!!';
                }
            } else {
                this.returnvalue = 'Invalid Record to create Price Quote!!';
            }

            System.debug('opportunityMap ' + opportunityMap);
            if (opportunityMap != null && opportunityMap.containsKey(Id.valueOf(OppId)) && String.isEmpty(this.returnvalue)) {

                for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.CreatePriceQuote.getFields()) {
                    if (!String.isEmpty(String.ValueOf(opportunityMap.get(Id.valueOf(OppId)).get(f.getFieldPath())))) {
                        createPQFieldvalues.put(f.getFieldPath(),
                                String.ValueOf(opportunityMap.get(Id.valueOf(OppId)).get(f.getFieldPath())));
                    } else if (f.getFieldPath() != 'Email2__c' && f.getFieldPath() != 'Gender__c') {
                       
                        this.returnvalue = (!String.isEmpty(this.returnvalue)) ? this.returnvalue : ' ' + Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe().getLabel() + ' ,';
                    }
                }
                System.debug('this.returnvalue ' + this.returnvalue);
                if (String.isEmpty(this.returnvalue)) {
                    accountSet.add(opportunityMap.get(Id.valueOf(OppId)).accountId);
                    map<Id, Account> accountMap = AccountsSelector.getAccountDetailsbasedonAccountId(accountSet);
                    Map<String, String> accountFieldsMap = AccountfieldsForPriceQuote(accountMap.get(opportunityMap.get(Id.valueOf(OppId)).accountId));
                    createPQFieldvalues.putAll(accountFieldsMap);
                    Map<Id, Lead> oppLeadMap = LeadsSelector.getLeadByConvertedOpportunityId(recordIdSet);
                    System.debug('this.oppLeadMap ' + oppLeadMap);
                    if (oppLeadMap.containsKey(Id.valueOf(OppId))) {
                        Map<String, String> leadFieldvalues = LeadfieldsForPriceQuote(oppLeadMap.get(Id.valueOf(OppId)));
                        createPQFieldvalues.putAll(leadFieldvalues);
                    }
                    createPQFieldvalues.put('Environment', (ExternalRouter.getOrganizationDetails().IsSandbox) ? 'QA' : 'LIVE');
                    String JSONValue = JSON.serialize(createPQFieldvalues);
                    this.PQParamJson = JSONValue;
                    System.debug('Before Opening Pos JOSN is ' + this.PQParamJson);
                    return '';
                } else {
                    return returnvalue.substringBeforeLast(',');
                }
            } else {
                System.debug('In Last Else Loop ' + this.returnvalue);
                return this.returnvalue;
            }
        } catch (Exception ex) {
            Id recID = Id.valueOf(this.RecordId);
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'CreatePriceQuoteController', 'openPoseidonToCreateQuote', null);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static Map<String, String> AccountfieldsForPriceQuote(Account accountRecord) {
        Map<String, String> accountFieldvalues = new Map<String, String>();
        accountFieldvalues.put('ParentEmail__c', String.ValueOf(accountRecord.get('ParentEmail__c')));
        accountFieldvalues.put('firstname', String.ValueOf(accountRecord.get('firstname')));
        accountFieldvalues.put('lastname', String.ValueOf(accountRecord.get('lastname')));
        return accountFieldvalues;
    }

    public static Map<String, String> LeadfieldsForPriceQuote(Lead leadRecord) {
        Map<String, String> leadFieldvalues = new Map<String, String>();
        leadFieldvalues.put('FormSubmissionId__c', String.ValueOf(leadRecord.get('FormSubmissionId__c')));
        return leadFieldvalues;
    }

}