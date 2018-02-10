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
          if(finalResponse!=null && finalResponse[0].SalesForceApplicationId==sourceLead.id){
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
       if (!Test.isRunningTest()) {

        String restAPIURL = label.End_Point_URL;
        List<RankingServiceParams> serviceParamsList = new List<RankingServiceParams>();
        RankingServiceParams serviceParams = null;
        map<string,string> allActivityMap = getTheActivityCount(sourceLeads).get(sourceLeads[0].id);
        system.debug('MapOfActivities<<<<<'+allActivityMap);
        system.debug('MapOfActivities>>>>>'+integer.valueof(allActivityMap.get('PQ')));
        system.debug('MapOfActivities>>>>>1'+integer.valueof(allActivityMap.get('RES')));
        system.debug('MapOfActivities>>>>>2'+integer.valueof(allActivityMap.get('CAM')));
        system.debug('MapOfActivities>>>>>3'+integer.valueof(allActivityMap.get('IM')));
        system.debug('MapOfActivities>>>>>4'+integer.valueof(allActivityMap.get('Called Us')));
        system.debug('MapOfActivities>>>>>5'+integer.valueof(allActivityMap.get('Call Reached')));
        system.debug('MapOfActivities>>>>>6'+integer.valueof(allActivityMap.get('Emailed Us')));
        system.debug('MapOfActivities>>>>>7'+integer.valueof(allActivityMap.get('Visited us')));
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
        serviceParams.HasPQ = integer.valueof(allActivityMap.get('PQ'))>0?true:false;
        serviceParams.HasReservation = integer.valueof(allActivityMap.get('RES'))>0?true:false;
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
        serviceParams.TotalBRCount = integer.valueof(allActivityMap.get('BR'));
        serviceParams.TotalCAMCount = integer.valueof(allActivityMap.get('CAM'));
        serviceParams.TotalCBRCount = 0;
        serviceParams.TotalCUCount = 0;
        serviceParams.TotalIMCount = integer.valueof(allActivityMap.get('IM'));
        serviceParams.TotalPQCount = integer.valueof(allActivityMap.get('PQ'));
        serviceParams.TotalRESCount = integer.valueof(allActivityMap.get('RES'));
        serviceParams.TotalCalledUsCount = integer.valueof(allActivityMap.get('Called Us'));
        serviceParams.TotalCALLREACHCount = integer.valueof(allActivityMap.get('Call Reached'));
        serviceParams.TotalVisitCount = integer.valueof(allActivityMap.get('Visited us'));
        serviceParams.TotalEmailCount = integer.valueof(allActivityMap.get('Emailed Us'));
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
        serviceParams.InterestDuration = null;
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
        serviceParams.ActiveDuration = 0;
        serviceParams.OriginalProbability = 0.0;
        serviceParams.SalesForceApplicationId = sourcelead.id;
        serviceParams.AddressLat = 0.0;
            serviceParams.AddressLong= 0.0;
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

     }
        return null;
    }
    
    public static map<id,map<string,string>> getTheActivityCount(list<lead> leadItemList){
        list<Event> allEventActivityForLead = [select id,WhoId,type from event where whoid in:leadItemList];
        list<task> allTaskActivityForLead = [select id,SalesAction__c from task where whoid in:leadItemList];
       // map<string,string> AllActivityForThatLead = new map<string,string>();
        map<id,map<string,string>> mapOfLeadAndMapOfActivities = new map<id,map<string,string>>();

       for(lead objLead:leadItemList) {
           integer camCount=0;
           integer brCount=0;
           integer resCount=0;
           integer pqCount=0;
           integer imCount=0;
           integer TotalCalledUsCount=0;
           integer TotalCALLREACHCount=0;
           integer TotalVisitCount=0;
           integer TotalEmailCount = 0;
           Map<String, String> AllActivityForThatLead = new Map<String, String>();
           for (event objEvent: allEventActivityForLead) {
               if (objEvent.whoid == objLead.id) {
                   if (objEvent.type == 'RES') {
                       resCount = resCount + 1;
                   } else if (objEvent.type == 'BR') {
                       brCount = brCount + 1;
                   } else if (objEvent.type == 'PQ') {
                       pqCount = pqCount + 1;
                   } else if (objEvent.type == 'CAM') {
                       camCount = camCount + 1;
                   } else if (objEvent.type == 'IM') {
                       imCount = imCount + 1;
                   }
               }
               if (allTaskActivityForLead != null) {
                   for (task objTask:allTaskActivityForLead) {
                       if (objTask.SalesAction__c == 'Called Us') {
                           TotalCalledUsCount = TotalCalledUsCount + 1;
                       } else if (objTask.SalesAction__c == 'Call Reached') {
                           TotalCALLREACHCount = TotalCALLREACHCount + 1;
                       } else if (objTask.SalesAction__c == 'Visited us') {
                           TotalVisitCount = TotalVisitCount + 1;
                       } else if (objTask.SalesAction__c == 'Emailed Us') {
                           TotalEmailCount = TotalEmailCount + 1;
                       }

                   }
               }
                AllActivityForThatLead.put('RES' , string.valueof(resCount));
               AllActivityForThatLead.put('BR' , string.valueof(brCount));
               AllActivityForThatLead.put('PQ' , string.valueof(pqCount));
               AllActivityForThatLead.put('CAM' , string.valueof(camCount));
               AllActivityForThatLead.put('IM' , string.valueof(imCount));
               AllActivityForThatLead.put('Called Us' , string.valueof(TotalCalledUsCount));
               AllActivityForThatLead.put('Call Reached' , string.valueof(TotalCALLREACHCount));
               AllActivityForThatLead.put('Visited us' , string.valueof(TotalVisitCount));
               AllActivityForThatLead.put('Emailed Us' , string.valueof(TotalEmailCount));

               mapOfLeadAndMapOfActivities.put(objLead.id, AllActivityForThatLead);
           }

       }

        return mapOfLeadAndMapOfActivities;
    }

}