/**
 * Created by arjun.mohan on 1/23/2018.
 */

public  class QuoteProposalsSelector {

    Public static List<Apttus_Proposal__Proposal__c> getSelectedQuoteByID(List<Id> QuoteIdList)
    {
                List<Apttus_Proposal__Proposal__c> quotes=new List<Apttus_Proposal__Proposal__c>();
        if (QuoteIdList!=null && QuoteIdList.size()>0) {
            quotes= [select Id,Name,Apttus_QPConfig__PriceListId__r.Market__c,Apttus_QPConfig__PriceListId__r.CurrencyIsoCode,Apttus_QPConfig__PriceListId__r.Year__c,Apttus_QPConfig__PriceListId__r.Version__c from Apttus_Proposal__Proposal__c where Id in :QuoteIdList];
        }
        return quotes;
    }
}