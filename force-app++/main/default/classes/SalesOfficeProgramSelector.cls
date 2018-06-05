/**
 * Created by thejasvi.a on 2/19/2018.
 */

public with sharing class SalesOfficeProgramSelector {

    public static List<SalesOfficeProgram__c> getSalesOfficeRecords(Set<string> recordSharingValues){
        return [select Id,Name,Market__c,Program__c,SaleOfficeCode__c from SalesOfficeProgram__c where name in:recordSharingValues];}
}