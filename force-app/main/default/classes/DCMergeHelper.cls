/**
 * Created by aditi.sharma on 7/25/2017.
 */
/*
Apex Class Name    : DCMergeHelper
Version            : 1.0
Created Date       : 7/25/2017
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Aditi Sharma                7/25/2017            This class helps in implementing business scenarios on opportunities and task after account merge
* Adam Osiecki                05/04/2017           Added try/catch block in methods: OnManualMerge, taskMergeReasonUpdateonMergeLead,
*                                                  ChangeProgramOrStatusForMasterRecord, changeProgramOnOpportunityForPersonAccountMerge
*
*******************************************************************************/
public without sharing class DCMergeHelper{
    public class CustomException extends Exception {}
    //************************************** DCMergePlugin Codes here ***********************************
    //This function is invoked when there is a manual merge of objects using DC (Lead to Lead or Account to Account)
    public static void OnManualMerge(String objectPrefix, Sobject masterRecord, Set < id > mergedRecordIds)
    {
        try{
            if(objectPrefix == System.Label.AccountPrefix) //001P
            {
                List<Opportunity> opps = OpportunitiesSelector.getOpportunitiesOnAccountId(masterRecord.Id);
                Account masterAccount = AccountsSelector.GetAccountOnId(masterRecord.Id);

                List<Opportunity> freezableOpps = OpportunityStageUpdateOnMergeAccount(masterAccount,opps);
                if(freezableOpps != null && freezableOpps.size()>0){
                    for(Opportunity freezableOpp : freezableOpps){
                        freezableOpp.isactive__c = false;
                        freezableOpp.StageName = label.OppStageClosedLost;
                        freezableOpp.CloseMainReason__c = 'Closed by System';
                        freezableOpp.closedate = system.today();
                    }
                    SObjectUnitOfWork.ExecuteUpdateOpportunities(freezableOpps);
                }
            }else if(objectPrefix == System.Label.LeadPrefix) // "00Q"
            {
                list<Lead> retainedLeadList = new list<Lead>();
                Lead retainedLead = (Lead)masterRecord;

                retainedLeadList.add(retainedLead);
                SObjectUnitOfWork.executeUpdateLeads(retainedLeadList);
            }
        }catch(exception ex){
            ExceptionHandler.errorLog(ex.getMessage(),ex.getStackTraceString(),
                    'DCMergeHelper','OnManualMerge',masterRecord.Id);
        }
    }
    //This function decides what to be done with the opportunities when multiple person accounts are merged
    /*
  Apex method Name    : OpportunityStageUpdateOnMergeAccount
  Version    Method   : 7/25/2017
  ------------------------------------------------------------------------------
  * Developer                   Date                   Description
  * ----------------------------------------------------------------------------
  * Aditi Sharma                7/25/2017            This Method updates the opportunity Stage according to the business scenarios
  *******************************************************************************/
    public static List<Opportunity> OpportunityStageUpdateOnMergeAccount(Account masterAccount,List<Opportunity> mergedOpps)
    {
        List<Opportunity> freezOpportunityList = new List<Opportunity>();
        Boolean isFound = true;
        Set<String> stageNameSet = new Set<String>();

        List<Opportunity> wonOpportuntyList = opportunitiesselector.getlstOfOpportunityByCreatedDateDesc(masterAccount);

        //collect opportunity stages
        for(Opportunity opp : wonOpportuntyList) {
            stageNameSet.add(opp.stageName);

        }
        //Won opportunity
        //please do not add any if block inside this. It has been followed as per the order
        if(stageNameSet.contains(System.Label.OpportunityBookingStage)) {
            for (Opportunity opp : wonOpportuntyList) {
                if (opp.StageName == Label.OpportunityBookingStage && isFound && opp.IsActive__c) {
                    isFound = false;
                    continue;
                }
                freezOpportunityList.add(opp);
            }

        }

        //Followup  opportunity
        else if(stageNameSet.contains(System.Label.LeadStageFollowup)) {
            list<opportunity> opportunityFollowUpList = new list<opportunity>();
            opportunityFollowUpList = opportunitiesselector.getLstOfFollowupOpportunity(mergedOpps);
            for (Opportunity opp : opportunityFollowUpList) {

                if(opportunityFollowUpList.size()>1){
                    if (opp.stageName == System.Label.LeadStageFollowup && opp.FollowupDateTime__c >= system.today() && isFound && opp.IsActive__c) {
                        isFound = false;
                        continue;
                    }
                }
                else{
                    if (opp.stageName == System.Label.LeadStageFollowup && isFound && opp.IsActive__c) {

                        isFound = false;
                        continue;
                    }

                }
                freezOpportunityList.add(opp);

            }
        }
        //TBC

        else if(stageNameSet.contains(System.Label.LeadStageTBC)) {
            mergedOpps = opportunitiesselector.getLstOpportunityOrderByCrtdDateASC(mergedOpps);
            for (Opportunity opp : mergedOpps) {

                if (opp.stageName == System.Label.LeadStageTBC && isFound && opp.IsActive__c) {
                    isFound = false;
                    continue;
                }
                freezOpportunityList.add(opp);

            }
        }
        else if(stageNameSet.contains(System.Label.salesclosed)) {
            mergedOpps = opportunitiesselector.getLstOpportunityOrderByCrtdDateASC(mergedOpps);
            for (Opportunity opp : mergedOpps) {

                if (opp.stageName == System.Label.salesclosed && isFound && opp.IsActive__c) {
                    isFound = false;
                    continue;
                }
                freezOpportunityList.add(opp);

            }
        }
        else {
            //other stagename
            for (Opportunity opp : mergedOpps) {
                if (opp.FollowupDateTime__c >= system.today() && isFound) {
                    isFound = false;
                    continue;
                }
                freezOpportunityList.add(opp);
            }
        }
        return freezOpportunityList;
    }
    public static void taskMergeReasonUpdateonMergeLead(String objectPrefix, Sobject masterRecord, List < sobject > mergedRecordList){
        if (objectPrefix == System.Label.LeadPrefix)  // =="00Q"
        {
            List<Id> mergedIds = new List<Id>();
            Lead retainedLead = (Lead) masterRecord;
            for (sobject sObj : mergedRecordList) {
                mergedIds.add(sObj.Id);
            }
            List<event> mergedEvent = Eventsselector.GetEventsOnWhoIds(mergedIds);
            for (event mergedTask : mergedEvent ) {
                mergedTask.MergeReason__c = System.Label.MergeReasonManual;
            }
            try{
                SObjectUnitOfWork.executeUpdateEvents(mergedEvent);
            }catch(exception ex){
                ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                        'DCMergeHelper', 'taskMergeReasonUpdateonMergeLead', masterRecord.Id);
            }
        }
    }

    public static void ChangeProgramOrStatusForMasterREcord(String objectPrefix, Sobject masterRecord ,list<sobject> mergedRecordList) {
        Set<Id> mergedIds = new Set<Id>();
        for (sobject sObj : mergedRecordList) {
            mergedIds.add(sObj.Id);
        }
        //When Leads are Merged Manually
        if (objectPrefix == System.Label.LeadPrefix)  // =="00Q"
        {
            Lead retainedLead = (Lead) masterRecord;
            retainedLead =
            [select id,program__c,product__c,status,RequestType__c , createddate from lead where id=:retainedLead.id];
            List<lead> latestobjleadList =
            [select id,program__C,product__c,status,RequestType__c, createddate from lead where id in:mergedIds
            order by createddate desc];

            Lead latestobjlead;
            if(latestobjleadList!=null && latestobjleadList.size()>0)
            {
                latestobjlead= latestobjleadList[0];

                for(Lead leadRecord:latestobjleadList)
                {
                    if(leadRecord.RequestType__c != 'CAM' || retainedLead.RequestType__c != 'CAM'
                            )
                    {
                        retainedLead.IsCAMOnly__c=false;
                        break;
                    }

                }
            }
            system.debug('retainedLead Manual merge '+retainedLead);
            retainedLead.ReadyForRanking__c = true;
            retainedLead.isdupeprocessed__c=true;
            retainedLead.IsDupe__c = false;  //Reset the flag to "Fasle" when we do the Automerge.
            retainedLead.recalculateranking__c=true;


            if(retainedLead.createddate > latestobjlead.createddate)
            {
                latestobjlead = retainedLead;
            }
            //If the retained Lead is in closed status change the status to open and get the program from the latest activity
            if(!(retainedLead.status=='open')){
                retainedLead.status='open';
                retainedLead.program__c = latestobjlead.program__c;
            }
            // If the latest activity is RES or the retained program is multi change the program to the latest activity
            else if(latestobjlead.RequestType__c == 'RES' || retainedLead.program__c=='MULTI'){
                retainedLead.program__c=latestobjlead.program__c;
            }
            try{
                DcBusinessFlow.transferEvent(retainedLead,mergedIds,'Merge');
                DcBusinessFlow.transferNotes(retainedLead,mergedIds,'Merge');
                DcBusinessFlow.transferCampaignMember(retainedLead,mergedIds,'Merge');
                update retainedLead;
            }catch(exception ex){
                ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                        'DCMergeHelper', 'ChangeProgramOrStatusForMasterRecord(', masterRecord.Id);
            }
        }

    }
    public static void changeProgramOnOpportunityForPersonAccountMerge(String objectPrefix, Sobject masterRecord ,set<id> mergedRecordList){
        if(masterRecord.getSObjectType() == account.getSObjectType()){
            Account retainedAccount = (account) masterRecord;
            retainedAccount = [Select PersonContactId From Account Where Id = :retainedAccount.id];
            list<opportunity> ActiveOpportunityList = [select id,program__c,stagename,createddate from opportunity where accountid=:retainedAccount.id and isactive__c=true limit 1];
            List<Event> CustomerRequestActivityList = [select id,program__c,type from event where whoid=:retainedAccount.PersonContactId order by createddate desc limit 2];
            if(retainedAccount!=null && ActiveOpportunityList!=null && ActiveOpportunityList.size()>0 && !ActiveOpportunityList.isempty()){
                opportunity ActiveOpportunity = ActiveOpportunityList[0];
                If(!(ActiveOpportunity.stageName == label.OpportunityBookingStage) && CustomerRequestActivityList.size()>0 && CustomerRequestActivityList[0].type == 'RES'){
                    ActiveOpportunity.Program__c = CustomerRequestActivityList[0].program__c;
                }
                If(ActiveOpportunity.Program__c == 'MULTI')
                {
                    if(CustomerRequestActivityList.size()>0 && CustomerRequestActivityList[0].Program__c != 'MULTI'){
                        ActiveOpportunity.Program__c = CustomerRequestActivityList[0].Program__c;
                    }else{
                        ActiveOpportunity.Program__c = CustomerRequestActivityList.size()>1?CustomerRequestActivityList[1].Program__c:ActiveOpportunity.Program__c;
                    }
                }
                ActiveOpportunity.recalculateranking__c=true;
                try{
                    update ActiveOpportunity;
                }catch(exception ex){
                    ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                            'DCMergeHelper', 'changeProgramOnOpportunityForPersonAccountMerge(', masterRecord.Id);
                }
              }
        }
    }
    public static void validationForHasBookingAccountMerge(String objectPrefix, Sobject masterRecord ,list<sobject> mergedRecordList){
        List<Id> mergedIds = new List<Id>();
        integer i=0;
        integer j=0;
        for (sobject sObj : mergedRecordList) {
            mergedIds.add(sObj.Id);
        }
        if(masterRecord.getSObjectType() == account.getSObjectType()){
            boolean hasBooking = false;
            Account retainedAccount = (account) masterRecord;
            retainedAccount = [select id,HasBooking__c from account where id=:retainedAccount.id];
            lIST<Account>  LatestmergedAccount = [select id,HasBooking__c from account where id in:mergedIds];
            FOR(account objAccount: LatestmergedAccount){
                if(objAccount.HasBooking__c){
                    j=j+1;
                }
            }

            i= retainedAccount.HasBooking__c?1:0;

            if(i+j>=2){
                throw new CustomException('Customers with Bookings are not allowed to merge. Please contact Poseidon support to help you with this case');
            }
            else if(j>i)
            {
                throw new CustomException('Please select personal account having a booking as a master record.');
            }
        }
    }



}