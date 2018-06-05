/**
 * Created by aneesh.bhat on 1/17/2018.
 */

public with sharing class RankingServiceParams {
    public String LeadID{get;set;}
    public String OpportunityID{get;set;}
    public String RankingType{get;set;}
    public String RequestType {get;set;}
    public boolean HadAddressOnCreation{get;set;}
    public DateTime LastPQDateTime{get;set;}
    public DateTime LastRESDateTime{get;set;}
    public Boolean IsParent{get;set;}
    public Boolean IsExpressCall{get;set;}
    public Boolean HasBooking{get;set;}
    public String Program{get;set;}
    public String Market{get;set;}
    public DateTime CreatedDate{get;set;}
    public String CreationMethod{get;set;}
    public String Source{get;set;}
    public String Address{get;set;}
    public String HearAboutUs{get;set;}
    public String DeviceType{get;set;}
    public String ETag{get;set;}
    public String UserSelectedSourceCode{get;set;}
}