public class QuotePreview {

	//Create list of wrapper to grab all sobject records
    @AuraEnabled
    public static List<Apttus_Proposal__Proposal_Line_Item__c> Preview(String rcrdId){
        Id currentrecord;
        List<LineitemProductWrapper> PreviewLst = new List<LineitemProductWrapper>();
        LineitemProductWrapper Preview = new LineitemProductWrapper();
        List<Apttus_Proposal__Proposal_Line_Item__c> fetchLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        try{
       
		fetchLineItems = [select id,name,Apttus_Proposal__Product__c,Product_Code__c ,Apttus_Proposal__Description__c ,Apttus_Proposal__Product__r.ProductCode,
                          Apttus_Proposal__Product__r.name,Apttus_Proposal__Proposal__c,APTS_Product_Code__c,
                          Non_Discounted_Price__c,Apttus_QPConfig__Quantity2__c,
							Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,Discount__c,
							APTS_Discount_Reason__c,Apttus_QPConfig__NetPrice__c,CurrencyIsoCode,
							Apttus_QPConfig__IsOptional__c,(Select Id,Apttus_QPConfig__IncentiveCode__c,Apttus_QPConfig__IncentiveId__r.name FROM Apttus_QPConfig__AdjustmentLineItems__r)
							from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =:rcrdId];
            
 
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());

            //return fetchLineItems;
        }
     	 return fetchLineItems;
    }
     @AuraEnabled
    public static string getCurrentOrgUrl(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    @AuraEnabled
    public static List<string> getConfigIds(string quoteId)
    {
        List<String> IdList=new List<String>();
        Id Quote=Id.valueOf(quoteId);
         List<Apttus_Config2__ProductConfiguration__c> configList=[select Id from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=:Quote Limit 1];
               if(configList.size() > 0)
         { 
             IdList.add(configList[0].Id);
             List<Apttus_Config2__TempObject__c> configReqIdList=[select Id from Apttus_Config2__TempObject__c where Apttus_Config2__ConfigurationId__c=:configList[0].Id limit 1];
         if(configReqIdList.size() > 0)
         {
             
             IdList.add(configReqIdList[0].Id);
         }
        
         }
         
            
        return IdList;
            
    }
        Public class LineitemProductWrapper{
            @AuraEnabled
            public Apttus_Proposal__Proposal_Line_Item__c lineitem {get;set;}
            @AuraEnabled
            public Product2 product {get;set;}
            
            
            
	}

}