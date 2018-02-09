/**
 * Created by aneesh.bhat on 1/17/2018.
 */

public with sharing class RankingServiceParams {
    public String FirstActivityCampaign{get;set;}
    public Boolean HasSeenPromotion{get;set;}
    public Boolean HasAddressOnCreation{get;set;}
    public Integer ActiveDuration{get;set;}
    public Boolean IsLocallyCreated{get;set;}
    public String LikelihoodToBook{get;set;}
    public String Prio_HeardAboutUsName{get;set;}
    public Integer TotalTimeSpentOnTheweb{get;set;}
    public Boolean IsRepeatCustomer{get;set;}
    public Boolean HasSibling{get;set;}
    public Integer NumberOfTotalActivities{get;set;}
    public Boolean HasChangedProgram{get;set;}
    public Boolean HasPQ{get;set;}
    public Boolean HasReservation{get;set;}
    public Boolean Prio_DurationCode{get;set;}
    public Boolean Prio_PreferredDestinationCountry{get;set;}
    public Boolean Prio_WhenChoiceType{get;set;}
    public Boolean Prio_ALL{get;set;}
    public Boolean IsPostalCodeValidForRanking{get;set;}
    public Boolean GoPageVisitedPre{get;set;}
    public Boolean GoPageVisitedPost{get;set;}
    public String IntrestClusterGroup{get;set;}
    public Boolean IsParent{get;set;}
    public Boolean IsExpressCall{get;set;}
    public String SearchType{get;set;}
    public String FirstActivityType{get;set;}
    public String MarketCode{get;set;}
    public String InterestStatusCode{get;set;}
    public String InterestProduct{get;set;}
    public Decimal AddressLat{get;set;}
    public Decimal AddressLong{get;set;}
    public Boolean HasBeenTBC{get;set;}
    public Boolean HasBeenSell{get;set;}
    public Boolean OnlyNTBC{get;set;}
    public String DeviceType{get;set;}
    public Boolean GotAddress{get;set;}
    public Decimal OriginalProbability{get;set;}
    public String SalesForceApplicationId{get;set;}
    public Integer TotalBRCount{get;set;}
    public Integer TotalCAMCount{get;set;}
    public Integer TotalCBRCount{get;set;}
    public Integer TotalCUCount{get;set;}
    public Integer TotalIMCount{get;set;}
    public Integer TotalPQCount{get;set;}
    public Integer TotalRESCount{get;set;}
    public Integer TotalCalledUsCount{get;set;}
    public Integer TotalCALLREACHCount{get;set;}
    public Integer TotalVisitCount{get;set;}
    public Integer TotalEmailCount{get;set;}
    public String InterestCreationMonth{get;set;}
    public String SourcecodeCatagory{get;set;}
    public Boolean FirstCallReached{get;set;}
    public string InterestDurationInHours{get;set;}
    public String CallReachHourGroup{get;set;}
    public String PostalCode{get;set;}
    public String State{get;set;}
    public String City{get;set;}
    public String Region{get;set;}
    public Boolean IsByConversion{get;set;}
    public integer InterestDuration{get;set;}
    public DateTime InterestCreatedDate{get;set;}
    public DateTime FirstBookingDate{get;set;}
    public Integer ReachedOnCall{get;set;}
    public Decimal TimeSpent{get;set;}

}