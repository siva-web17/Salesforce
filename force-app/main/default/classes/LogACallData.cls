/**
 * Created by aneesh.bhat on 29-Nov-17.
 */

public with sharing class LogACallData {
    @AuraEnabled
    public Id Id{get;set;}
    @AuraEnabled
    public Date CloseDate{get;set;}
    @AuraEnabled
    public String LikelihoodToBook{get;set;}
    @AuraEnabled
    public String HearAboutUs{get;set;}
    @AuraEnabled
    public String Destinations{get;set;}
    @AuraEnabled
    public String Duration{get;set;}
    @AuraEnabled
    public String WhenYear{get;set;}
    @AuraEnabled
    public String WhenMonth{get;set;}
    @AuraEnabled
    public Boolean IsActive{get;set;}
    @AuraEnabled
    public Decimal NumberOfUnreachedCalls{get;set;}
    public String Program{get;set;}
    public LogACallData(Id id,Date closeDate,String likelihoodToBook,String hearAboutUs,String destinations,String duration,String whenYear,String whenMonth, Boolean isActive, Decimal numberOfUnreachedCalls,String program){
        this.Id = id;
        this.CloseDate = closeDate;
        this.LikelihoodToBook = likelihoodToBook;
        this.HearAboutUs = hearAboutUs;
        this.Destinations = destinations;
        this.Duration = duration;
        this.WhenYear = whenYear;
        this.WhenMonth = whenMonth;
        this.IsActive = isActive;
        this.NumberOfUnreachedCalls = numberOfUnreachedCalls;
        this.Program = program;
    }
}