/**
 * Created by thejasvi.a on 2/21/2018.
 */

public with sharing class SourcesSelector {
    public static List<Source__c> getSourceRecords(Set<string> sourceAutoCodeValues){
        List<Source__c> sourceList = new List<Source__c>();
        if(sourceAutoCodeValues!=null) {
            sourceList=[select Id, Code__c,Name from Source__c where Code__c in:sourceAutoCodeValues];
        }
        return sourceList;
    }

    public static Map<Id,Source__c>  getSourceMapRecordforLead (Map<Id,List<Lead>> leadMap) {
        Map<Id, Source__c> sourceMap = new Map<Id, Source__c>();
        if (leadMap != null) {
            sourceMap = new Map<Id, Source__c>([select Id, Name, Code__c from Source__c where Id in :leadMap.keySet()]);
        }
        return sourceMap;
    }

    public static Map<Id,Source__c>  getSourceMapRecordforOpportunity (Map<Id,List<Opportunity>> opportunityMap) { 
        Map<Id, Source__c> sourceMap = new Map<Id, Source__c>();
        if (opportunityMap != null) {
            sourceMap = new Map<Id, Source__c>([select Id, Name, Code__c from Source__c where Id in :opportunityMap.keySet()]);
        }
        return sourceMap;
    }

}