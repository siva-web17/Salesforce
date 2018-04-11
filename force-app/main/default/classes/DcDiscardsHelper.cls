/**************************************************************************************
Apex Class Name    : DcDiscardsHelper
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
 * Adam Osiecki              05/04/2018              Added try/catch block in method:
 *                                                   WebServiceCallForRankingAfterFalseDupe
*******************************************************************************/
public class DcDiscardsHelper {
    public static void notifyRankingAfterInsert(List<dupcheck__dcDiscard__c > dcDiscardList) {
        //This trigger will invoke once we click "Discard" button in the DC Tool and hit for ranking once we discard the record.
        system.debug('I am in dcdiscardhelper'+dcDiscardList);
        set<Id> leadIdList = new set<Id>();
        for (dupcheck__dcDiscard__c discardedItem : dcDiscardList) {
             Id leadId = discardedItem.dupcheck__objectA__c;
            if(leadId.getSObjectType() == Lead.getSObjectType()){
               leadIdList.add(leadId);
            }
        }
         List<Lead> leadUpdateList = new List<Lead>();
        leadUpdateList = LeadsSelector.getLeadsOnId(leadIdList);
        for (Lead lead : leadUpdateList) {
            lead.IsDupe__c = false;           
        }
       System.enqueueJob(new QueueClass(leadIdList));
    }
	
    @future (callout=true)
    Public Static void WebServiceCallForRankingAfterFalseDupe(set <id> leadIdList){
     List<Lead> leadUpdateList = new List<Lead>();
     Map<string,integer> leadIdAndRankMap = new Map<String,integer>();
        leadUpdateList = LeadsSelector.getLeadsOnId(leadIdList);
        List<RankingServiceResponse> finalResponse = DCBusinessFlowHelper.webServiceCallForRanking(leadUpdateList);
        for(RankingServiceResponse objRankingServiceResponse:finalResponse){
            leadIdAndRankMap.put(objRankingServiceResponse.LeadID,objRankingServiceResponse.Rank);
        }
        for(lead objLead:leadUpdateList){
            if(leadIdAndRankMap.containskey(objLead.id) && leadIdAndRankMap.get(objLead.id)!=null){
                objLead.ranking__c = leadIdAndRankMap.get(objLead.id);
                objLead.IsDupe__c  = false;
                objLead.readyforranking__c = true;
            }
        }
        try{
            update leadUpdateList;
        }catch(exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'DcDiscardsHelper', 'WebServiceCallForRankingAfterFalseDupe', '');
        }
    }
}