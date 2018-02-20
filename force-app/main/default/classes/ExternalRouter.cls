/**
 * Created by arjun.mohan on 2/9/2018.
 */

public  class ExternalRouter {

    @future (callout=true)
    public static void callUpdateAccountDetailsService(String accountDetails)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Account', accountDetails);
        gen.writeEndObject();
        String jsonS = gen.getAsString();
        String url=getServiceURL('SyncUpdatedAccountDetails');
        InvokeService(url,jsonS);
    }


    public static string InvokeService(String url,String body)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader( 'Content-Type', 'application/json' );
        req.setHeader( 'Accept', 'application/json' );
        req.setBody(body);
        HttpResponse res = h.send(req);
        system.debug(' url '+url);
        system.debug(' response is '+res);
        return '';
    }
    //Test
    @future (callout=true)
    public static void callUpdateAccountFamilyDetailsService(String accountPersonalDetails)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('SfFamilyInfo', accountPersonalDetails);
        gen.writeEndObject();
        String jsonS = gen.getAsString();
        String url=getServiceURL('SyncUpdatedAccountFamilyDetails');
        InvokeService(url,jsonS);
    }

    public static Organization getOrganizationDetails()
    {
        return [SELECT Id, Name, IsSandbox, InstanceName, OrganizationType FROM Organization limit 1];
    }

    public Static String getSandBoxNamefromUsername()
    {
       return UserInfo.getUserName().substringAfterLast('.');
    }

    public Static ExternalServiceSettings__mdt getServiceSetting(String serviceName,String environment,Boolean IsSandBox)
    {
        ExternalServiceSettings__mdt serviceSettingRecord=null;
        List<ExternalServiceSettings__mdt>  serviceList=[select EndPoint__c,Environment__c,ServiceName__c,TargetSystem__c from ExternalServiceSettings__mdt where Environment__c=:environment and ServiceName__c=:serviceName and IsSandbox__c=:IsSandBox and IsActive__c=true];
        if (serviceList.size()<=0) {
            serviceList=[select EndPoint__c,Environment__c,ServiceName__c,TargetSystem__c from ExternalServiceSettings__mdt where IsDefault__c=true and IsActive__c=true];
        }
        if (serviceList.size()>0) {
            serviceSettingRecord=serviceList[0];
        }
        return serviceSettingRecord;

    }
    public static String getServiceURL(String serviceName)
    {
        Organization orgRecord=  getOrganizationDetails();
         ExternalServiceSettings__mdt serviceRecord=  getServiceSetting(serviceName,getSandBoxNamefromUsername().toUpperCase(),orgRecord.IsSandbox);
        return serviceRecord.EndPoint__c;
    }

    //public static
}