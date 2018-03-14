public without sharing class AccountOpportunutuesListController{

    @AuraEnabled
    public static List<Contact> getContacts(){
        List<Contact> contacts =[SELECT Id, Name, Phone, Email FROM Contact];
        //Add isAccessible() check
        return contacts;
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunities(){
        List<Opportunity> opps =[SELECT Name, Program__c, StageName, Ranking__c FROM Opportunity];
        //Add isAccessible() check
        return opps;
    }

    @AuraEnabled
    public static void Hello(){

        System.debug('Hello World');
    }
}