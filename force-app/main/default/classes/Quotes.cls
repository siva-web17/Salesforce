/**
 * Created by thejasvi.a on 3/16/2018.
 */

public with sharing class Quotes {

    public static void onBeforeInsert(List<Quote__c> newItems) {
    }

    public static void onBeforeUpdate(List<Quote__c> oldQuoteList,List<Quote__c> newQuoteList) {
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(List<Quote__c>newItems) {
        QuotesHelper.closeSPQTasksOnOpportunity(newItems);
    }

    public static void onAfterUpdate(List<Quote__c> oldQuoteList,List<Quote__c> newQuoteList) {
    }

    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }

}