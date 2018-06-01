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

            if (finalResponse != null && finalResponse[0].LeadID == sourceLead.id && finalResponse[0].IsRanked) {
                sourceLead.IsDupeProcessed__c = TRUE;
                sourceLead.ReadyForRanking__c = TRUE;
                sourceLead.ranking__c = finalResponse[0].Rank;
            }
            update sourceLead;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),ex.getStackTraceString(), 'DCBusinessFlowHelper', 'notifyForRanking', null);
        }
    }
    public static List<RankingServiceResponse> webServiceCallForRanking(List<Lead> sourceLeads) {

        //Make sure your Salesforce instance URL is added in remote site settings
        //String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        ExternalServiceSettings__mdt serviceSettingRecord=ExternalRouter.getServiceURL('RankingService');
        String restAPIURL = serviceSettingRecord.EndPoint__c;
        List<RankingServiceParams> serviceParamsList = new List<RankingServiceParams>();
        RankingServiceParams serviceParams = null;
        for (Lead sourceLead : sourceLeads) {
            serviceParams = new RankingServiceParams();
            serviceParams.LeadID = sourcelead.id;
            serviceParams.OpportunityID = '';
            serviceParams.RankingType = 'Original';
            serviceParams.RequestType = sourcelead.requesttype__c;
            serviceParams.HadAddressOnCreation = sourceLead.HadAddressonCreation__c;
            serviceParams.LastPQDateTime = sourcelead.requesttype__c == 'PQ' ? sourcelead.createddate : null;
            serviceParams.LastRESDateTime = sourcelead.requesttype__c == 'RES' ? sourcelead.createddate : null;
            serviceParams.IsParent = sourcelead.isparent__c;
            serviceParams.IsExpressCall = sourcelead.IsExpressCall__c;
            serviceParams.HasBooking = false;
            serviceParams.Program = sourceLead.Program__c;
            serviceParams.Market = sourceLead.market__c;
            serviceParams.CreatedDate = sourcelead.createddate;
            serviceParams.CreationMethod = sourceLead.CreationMethod__c;
            serviceParams.Source = sourceLead.SourceCodeAuto__c;
            serviceParams.Address = (sourceLead.street + ',' + sourceLead.region__c + ',' + sourceLead.city + ',' + sourceLead.country + ',' + sourceLead.postalcode).replace('null', '');
            serviceParams.HearAboutUs = sourceLead.hearaboutus__c;
            serviceParams.DeviceType = sourceLead.DeviceType__c;
            serviceParamsList.Add(serviceParams);
        }
        String serviceParamsJSON = JSON.serialize(serviceParamsList);
        System.debug(' Value of Ranking service Params JSON : ' + serviceParamsJSON);
        HttpResponse httpResponse = ExternalRouter.callRankingService(serviceParamsJSON);
        if (httpResponse.getStatusCode() == 200) {
            List<RankingServiceResponse> serviceResponse =
                    (List<RankingServiceResponse>) JSON.deserialize(httpResponse.getBody(), List<RankingServiceResponse>.class);
                    System.debug(' ** response ** : ' + serviceResponse);
            return serviceResponse;
        }else{
            System.debug(' httpResponse ' + httpResponse.getBody());
            throw new CalloutException(httpResponse.getBody());
        }
        return null;
    }
}