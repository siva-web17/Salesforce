/**
 * Created by harsh.mathur on 1/5/2018.
 */

public class CampaignMembersSelector {

    public static Map<Id, Integer> getCampaignMemberCount(List<Campaign> campaignRecords){
        List<Campaign> newCampaigns = new List<Campaign>();
        newCampaigns = [Select Id,(select Id from CampaignMembers where status = 'Invited' or status ='Sent')
                        from Campaign
                        where Id in :campaignRecords];

        Map<Id, Integer> invitedCount = new Map<Id,Integer>();

        for(campaign campaignMembers:  newCampaigns) {
            invitedCount.put(campaignMembers.Id, campaignMembers.CampaignMembers.size());
        }
        return invitedCount;
    }

    public static List<CampaignMember> getCampaignMemberList(List<Campaign> campaignRecords){
        return [Select Id, CampaignId, ContactId, Status
                from CampaignMember
                where CampaignId in :campaignRecords];
    }
}