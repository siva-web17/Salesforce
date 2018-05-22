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
             Id LeadObjBId=discardedItem.dupcheck__objectB__c;
            if(leadId.getSObjectType() == Lead.getSObjectType()){
               leadIdList.add(leadId);
            }
            if(LeadObjBId.getSObjectType() == Lead.getSObjectType())
            {
                leadIdList.add(LeadObjBId);
            }
        }
         Set<Id> LeadToUpdateSet = new Set<Id>();
         Set<Id> SourceMatchingIds = new Set<Id>();
        List<dupcheck__dc3Duplicate__c> duplicateList = 
        [SELECT Id,dupcheck__MatchObject__c,dupcheck__SourceObject__c FROM 
        dupcheck__dc3Duplicate__c
         WHERE (dupcheck__MatchObject__c IN : leadIdList
          OR dupcheck__SourceObject__c  IN : leadIdList)];
          System.debug('Dupe Pairs we got  :'+duplicateList.size() );
         for(dupcheck__dc3Duplicate__c duplicatepairRecord:duplicateList)
        {
            SourceMatchingIds.add(duplicatepairRecord.dupcheck__MatchObject__c);
            SourceMatchingIds.add(duplicatepairRecord.dupcheck__SourceObject__c);
        }
        System.debug('Total Leads we got '+leadIdList.size());
        for(Id LeadIdrec:leadIdList)
        {

             If(SourceMatchingIds.size()==0 || !SourceMatchingIds.contains(LeadIdrec))
            {
                LeadToUpdateSet.add(LeadIdrec);
            }
            
        }
        system.debug('leads we are updating '+ LeadToUpdateSet.size());
        if(LeadToUpdateSet.size()>0)
        {
            System.enqueueJob(new QueueClass(LeadToUpdateSet));
        }
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
                objLead.IsDupeProcessed__c  = true;
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