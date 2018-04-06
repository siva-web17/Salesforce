/**
 * Created by arjun.mohan on 2/9/2018.
 */

public class ExternalRouter {

    @future(callout=true)
    public static void callUpdateAccountDetailsService(String accountDetails) {
        updateAccountDetails(accountDetails);
    }


    public static void updateAccountDetails(String accountDetails) {
        try {
            String url = getServiceURL('SyncUpdatedAccountDetails');
            HttpResponse response = InvokeService(url, accountDetails);
            AccountsHelper.SyncAccountDetailsWrapper accountDetailsWrapper = (AccountsHelper.SyncAccountDetailsWrapper)JSON.deserialize(accountDetails, AccountsHelper.SyncAccountDetailsWrapper.class);
            CalloutResult result = (CalloutResult)JSON.deserialize(response.getBody(), CalloutResult.class);
            List<Account> accountsToUpdate = new List<Account>();
            for(Id accId : accountDetailsWrapper.getAccountIds()){
                accountsToUpdate.add(new Account(Id = accId));
            }
            PoseidonSyncService.setSyncStatus(accountsToUpdate, result.isSuccess ? PoseidonSyncService.SyncStatusSuccess : PoseidonSyncService.SyncStatusFail);
            update accountsToUpdate;
        }catch (Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'ExternalRouter', 'updateAccountDetails', null);
        }
    }

    public static HttpResponse callRankingService(String accountDetails)
    {        
        String jsonS = accountDetails;
        String url=getServiceURL('RankingService');
        HttpResponse objHttpResponse= InvokeService(url,jsonS);
        return objHttpResponse;          
    }


    public static HttpResponse InvokeService(String url,String body)
    {
        String retValue='';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        //http://poseidonqa.eflangtech.com/PoseidonCustomerSync/api/Customer/SaveAccount
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(2 * 60 * 1000);
        system.debug('Accept ' + req);
        req.setBody(body);
        system.debug('body' + body);
        //req.setBody(body);
        HttpResponse res = h.send(req);
        system.debug(' url '+url);
        system.debug(' response is '+res);
       if(res.getStatusCode()!=200)
        {
            Id UserId=Id.Valueof(UserInfo.getUserId());
            ExceptionHandler.errorLog(String.ValueOf(res),url+'   --- \n'+ body,
                    'ExternalRouter', 'InvokeService', UserId);
            retValue = res.getStatus();
        }
        return res;
    }
    //Test
    @future(callout=true)
    public static void callUpdateAccountFamilyDetailsService(String accountPersonalDetails) {
        String jsonS = accountPersonalDetails;
        String url = getServiceURL('SyncUpdatedAccountFamilyDetails');
        InvokeService(url, jsonS);
    }

    @future(callout=true)
    public static void callNewAccountFamilyDetailsService(String accountPersonalDetails) {

        String jsonS = accountPersonalDetails;
        String url = getServiceURL('SyncNewAccountDetails');
        InvokeService(url, jsonS);
    }

    @future(callout=true)
    public static void callNewSyncToPoseidonService(String accountPersonalDetails) {

        String jsonS = accountPersonalDetails;
        String url = getServiceURL('SyncToPoseidon');
        InvokeService(url, jsonS);
    }

    //SyncNewAccountDetails

    public static Organization getOrganizationDetails() {
        return [SELECT Id, Name, IsSandbox, InstanceName, OrganizationType FROM Organization limit 1];
    }

    public Static String getSandBoxNamefromUsername() {
        return UserInfo.getUserName().substringAfterLast('.');
    }

   public Static ExternalServiceSettings__mdt getServiceSetting(String serviceName,String environment,Boolean IsSandBox)
    {
        if (!IsSandBox && String.isEmpty(environment)) {
            environment='LIVE';
        }
        ExternalServiceSettings__mdt serviceSettingRecord=null;
        List<ExternalServiceSettings__mdt>  serviceList=[select EndPoint__c,Environment__c,ServiceName__c,TargetSystem__c from ExternalServiceSettings__mdt where Environment__c=:environment and ServiceName__c=:serviceName and IsSandbox__c=:IsSandBox and IsActive__c=true];
        if (serviceList.size()<=0) {
            serviceList=[select EndPoint__c,Environment__c,ServiceName__c,TargetSystem__c from ExternalServiceSettings__mdt where IsDefault__c=true and IsActive__c=true and ServiceName__c=:serviceName];
        }
        if (serviceList.size() > 0) {
            serviceSettingRecord = serviceList[0];
        }
        return serviceSettingRecord;

    }
    public static String getServiceURL(String serviceName) {
        Organization orgRecord = getOrganizationDetails();
        ExternalServiceSettings__mdt serviceRecord = getServiceSetting(serviceName, getSandBoxNamefromUsername().toUpperCase(), orgRecord.IsSandbox);
        return serviceRecord.EndPoint__c;
    }

    public class CalloutResult{
        public Boolean isSuccess;
        public String message;
    }
}