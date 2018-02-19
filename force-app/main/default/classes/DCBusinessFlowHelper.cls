/**
 * Created by shravan.boddula on 9/6/2017.
 */

public class DCBusinessFlowHelper {
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
          if(finalResponse[0].LeadID==sourceLead.id && finalResponse[0].IsRanked){
                sourceLead.ranking__c = finalResponse[0].Rank;
                system.debug('ranking>>>>'+sourceLead.ranking__c);
                //SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});               

            }           
             update sourceLead; 
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
       if (!Test.isRunningTest()) {
        String restAPIURL = label.End_Point_URL;
        List<RankingServiceParams> serviceParamsList = new List<RankingServiceParams>();
        RankingServiceParams serviceParams = null;          
        for(Lead sourceLead: sourceLeads){
            serviceParams = new RankingServiceParams();
            serviceParams.LeadID = sourcelead.id;
            serviceParams.OpportunityID = '';
            serviceParams.RankingType = 'Original';
            serviceParams.RequestType = sourcelead.requesttype__c;
            serviceParams.HasAddressonCreation = sourceLead.HadAddressonCreation__c;
            serviceParams.LastPQDateTime = sourcelead.requesttype__c=='PQ'?sourcelead.createddate:null;
            serviceParams.LastRESDateTime = sourcelead.requesttype__c=='RES'?sourcelead.createddate:null;
            serviceParams.IsParent = sourcelead.isparent__c;
            serviceParams.IsExpressCall = sourcelead.IsExpressCall__c;
            serviceParams.HasBooking = false;
            serviceParams.Program = sourceLead.Program__c;
            serviceParams.Market = sourceLead.market__c;
            serviceParams.CreatedDate = sourcelead.createddate;
            serviceParams.CreationMethod = sourceLead.CreationMethod__c;
            serviceParams.Source = sourceLead.SourceCodeAuto__c;
            serviceParams.Address = (sourceLead.street + ','+ sourceLead.region__c+ ',' + sourceLead.city +',' + sourceLead.country +',' + sourceLead.postalcode).replace('null', '');
            serviceParams.HearAboutUs = sourceLead.hearaboutus__c;
            serviceParams.DeviceType = sourceLead.DeviceType__c;        
            serviceParamsList.Add(serviceParams);
        }
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        system.debug('My Json body'+JSON.serialize(serviceParamsList));
        httpRequest.setBody(JSON.serialize(serviceParamsList));
        httpRequest.setEndpoint(restAPIURL + '?SalesForceApplicationId=' + serviceParams.LeadID);
        String response = '';       
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200 ) {
                //response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                List<RankingServiceResponse> serviceResponse =
                        (List<RankingServiceResponse>)JSON.deserialize(httpResponse.getBody(),List<RankingServiceResponse>.class);
                System.debug(' ** response ** : ' + serviceResponse );             
                return serviceResponse;
            } else {
                System.debug(' httpResponse ' + httpResponse.getBody() );
                throw new CalloutException( httpResponse.getBody() );
            }   
}           
        return null;
   
    }
 
}
