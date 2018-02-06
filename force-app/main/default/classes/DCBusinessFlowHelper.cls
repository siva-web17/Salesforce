/**
 * Created by shravan.boddula on 9/6/2017.
 */

public with sharing class DCBusinessFlowHelper {
    //notify ranking
    public static void notifyForRanking(Lead sourceLead) {
        try {
            if (sourceLead.IsDupe__c == false) {
                sourceLead.ReadyForRanking__c = true;
            }
            List<Lead> sourceLeads = new List<Lead>();
            sourceLeads.Add(sourceLead);
           List<RankingServiceResponse> finalResponse = webServiceCallForRanking(sourceLeads);
          system.debug('Finalresponse@@@'+finalResponse);
          if(finalResponse[0].SalesForceApplicationId==sourceLead.id){
                sourceLead.ranking__c = finalResponse[0].ScaleDownRanking;
                system.debug('ranking>>>>'+sourceLead.ranking__c);
                //SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});
                update sourceLead;
            }
            
        } catch (Exception ex) {
            system.debug('Exception after notifying for ranking'+ex);
            ExceptionHandler.errorLog(ex.getMessage(),

                    ex.getStackTraceString(), 'DCBusinessFlowHelper', 'notifyForRanking', '');
        }
    }
    public static List<RankingServiceResponse> webServiceCallForRanking(List<Lead> sourceLeads){
    system.debug('sourceLead>>>>'+sourceLeads);
        //Make sure your Salesforce instance URL is added in remote site settings
        //String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = 'http://poseidonqa.eflangtech.com/RankingSFWebAPI/api/rank/post';
        List<RankingServiceParams> serviceParamsList = new List<RankingServiceParams>();
        RankingServiceParams serviceParams = null;
        for(Lead sourceLead: sourceLeads){
            serviceParams = new RankingServiceParams();
            
        
        
       serviceParams.FirstActivityCampaign = null;
        serviceParams.HasSeenPromotion = false;
        serviceParams.HasAddressOnCreation = sourceLead.HadAddressonCreation__c;
        //serviceParams.ActiveDuratsourcelead='2';
        serviceParams.IsLocallyCreated = True;
        serviceParams.LikelihoodToBook = sourcelead.Likelihoodtobook__c;
        serviceParams.Prio_HeardAboutUsName = sourceLead.hearaboutus__c;
        serviceParams.TotalTimeSpentOnTheweb = 0;
        serviceParams.IsRepeatCustomer = false;
        serviceParams.HasSibling = false;       
        serviceParams.NumberOfTotalActivities = 1;
        serviceParams.HasChangedProgram = false;        
        serviceParams.HasPQ = [select id from event where type='PQ' and whoid=:sourceLead.id].size()>0?true:false;
        serviceParams.HasReservation = [select id from event where type='PQ' and whoid=:sourceLead.id].size()>0?true:false;
        serviceParams.Prio_DurationCode = sourceLead.duration__c!=null?true:false;
        serviceParams.Prio_PreferredDestinationCountry = sourcelead.Destinations__c!=null?true:false;
        serviceParams.Prio_WhenChoiceType = false;
        serviceParams.Prio_ALL = false;
        serviceParams.IsPostalCodeValidForRanking = false;
        serviceParams.GoPageVisitedPre = false;
        serviceParams.GoPageVisitedPost = false;
        serviceParams.IntrestClusterGroup = 'N';
        serviceParams.IsParent = sourcelead.isparent__c;
        serviceParams.IsExpressCall = sourcelead.IsExpressCall__c;
        serviceParams.TotalBRCount = [select id from event where type='BR' and whoid=:sourceLead.id].size();
        serviceParams.TotalCAMCount = [select id from event where type='CAM' and whoid=:sourceLead.id].size();
        serviceParams.TotalCBRCount = 0;
        serviceParams.TotalCUCount = 0;
        serviceParams.TotalIMCount = [select id from event where type='IM' and whoid=:sourceLead.id].size();
        serviceParams.TotalPQCount = [select id from event where type='PQ' and whoid=:sourceLead.id].size();
        serviceParams.TotalRESCount = [select id from event where type='RES' and whoid=:sourceLead.id].size();
        serviceParams.TotalCalledUsCount = 0;
        serviceParams.TotalCALLREACHCount = 1;
        serviceParams.TotalVisitCount = 0;
        serviceParams.TotalEmailCount = 0;
        serviceParams.InterestCreationMonth = sourceLead.CreationMethod__c;
        serviceParams.SourcecodeCatagory = sourcelead.SourceCodeGroup__c;
        serviceParams.FirstCallReached = true;
        serviceParams.InterestDurationInHours = '0';
        serviceParams.CallReachHourGroup = 'A';
        serviceParams.PostalCode = sourcelead.PostalCode;
        serviceParams.State = sourceLead.state;
        serviceParams.City = sourceLead.city;
        serviceParams.Region = sourceLead.Region__c;
        serviceParams.IsByConversion = false;
        serviceParams.InterestDuration = sourcelead.duration__c;
        serviceParams.InterestCreatedDate = sourcelead.createddate;
        serviceParams.FirstBookingDate = null;
        serviceParams.ReachedOnCall = 1;
        serviceParams.TimeSpent = 0;
        serviceParams.SearchType = '';
        serviceParams.FirstActivityType = sourcelead.requesttype__c;
        serviceParams.MarketCode = sourceLead.market__c;
        serviceParams.InterestStatusCode = sourceLead.status;
        serviceParams.InterestProduct = sourceLead.product__c;     
        serviceParams.HasBeenTBC  = true;
        serviceParams.HasBeenSell = true;
        serviceParams.OnlyNTBC = false;
        serviceParams.DeviceType = sourcelead.devicetype__c;
        serviceParams.GotAddress = false;
        serviceParams.OriginalProbability = 0.035650909;
        serviceParams.SalesForceApplicationId = sourcelead.id;
        serviceParamsList.Add(serviceParams);
        } 


        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        system.debug('My Json body'+JSON.serialize(serviceParamsList));
        httpRequest.setBody(JSON.serialize(serviceParamsList));
        httpRequest.setEndpoint(restAPIURL + '?SFEntityId=' + serviceParams.SalesForceApplicationId);
        String response = '';
       
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200 ) {
                //response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                List<RankingServiceResponse> serviceResponse =
                        (List<RankingServiceResponse>)JSON.deserialize(httpResponse.getBody(),List<RankingServiceResponse>.class);
                System.debug(' ** response ** : ' + serviceResponse );
                /* sourceLead.ranking__c = serviceResponse[0].ScaleDownRanking;
               system.debug('My lead ranking is'+sourceLead.ranking__c);
                 update sourceLead;*/
                 // system.debug('My lead ranking is'+sourceLead.ranking__c +'Leadid>>'sourceLeads);
                return serviceResponse;
            } else {
                System.debug(' httpResponse ' + httpResponse.getBody() );
                throw new CalloutException( httpResponse.getBody() );
            }

     
        return null;
    }

}