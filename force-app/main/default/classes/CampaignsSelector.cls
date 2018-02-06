/**
 * Created by harsh.mathur on 1/5/2018.
 */

public class CampaignsSelector {

    public static Campaign getCampaignOnId(Id campaignId) {
        Campaign campaignToReturn = null;
        List<Campaign> lstCampaigns = new List<Campaign>();
        lstCampaigns = [Select Id, Name, Market__c, IsUP__c, Product__c, DateFrom__c, DateTo__c, MeetingSize__c, Address__c,
                        SendtoEFCOM__c, Description, SalesOffice__c, Program__c, MeetingType__c, Status, MeetingCity__c, EFCOMMarket__c
                        from Campaign
                        where Id = :campaignId];

        if(lstCampaigns.size() > 0){
            campaignToReturn = lstCampaigns[0];
        }
        return campaignToReturn;
    }

    public static List<Campaign> getActiveFutureCampaignRecords() {
        return [Select Program__c, MeetingCity__c, MeetingType__c, DateFrom__c, DateTo__c, IsUP__c, MeetingSize__c
                from Campaign
                where status = 'Active'
                and DateFrom__c >= Today];
    }

    public static List<Campaign> queryCampaignRecords(){
        return [Select Id from Campaign
                where Status = 'Active'
                limit 2];
    }
}