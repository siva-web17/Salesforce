public class QuotePreview {
    public static List<Apttus_Proposal__Proposal_Line_Item__c> fetchLineItems;

    //Create list of wrapper to grab all sobject records
    @AuraEnabled
    public static List<LineitemProductWrapper> Preview(String rcrdId){
        Id currentrecord;
        List<LineitemProductWrapper> PreviewList = new List<LineitemProductWrapper>();

        try{

            fetchLineItems = [select id,name,Apttus_Proposal__Product__c,Product_Code__c ,Apttus_Proposal__Description__c ,Apttus_Proposal__Product__r.ProductCode,
                    Apttus_Proposal__Product__r.name,Apttus_Proposal__Proposal__c,APTS_Product_Code__c,Apttus_QPConfig__LineType__c,
                    Non_Discounted_Price__c,Apttus_QPConfig__Quantity2__c,Apttus_Proposal__Quantity__c,Apttus_Proposal__Proposal__r.Program__c,
                    Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,Discount__c,LTDestinationCode__c,LTCourseNumber__c,
                    APTS_Discount_Reason__c,Apttus_QPConfig__NetPrice__c,CurrencyIsoCode,
                    Apttus_QPConfig__IsOptional__c,(Select Id,Apttus_QPConfig__IncentiveCode__c,Apttus_QPConfig__IncentiveId__r.name,Apttus_QPConfig__IncentiveAdjustmentAmount__c FROM Apttus_QPConfig__AdjustmentLineItems__r)
            from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =:rcrdId];
            system.debug(' array size is '+fetchLineItems);
            for(Apttus_Proposal__Proposal_Line_Item__c lineItemrecord : fetchLineItems){
                system.debug(' lineItemrecord'+lineItemrecord);
                if(!(lineItemrecord.APTS_Product_Code__c ==Label.FTEFX_Article_Code && lineItemrecord.Non_Discounted_Price__c == 0)){
                    LineitemProductWrapper wrapobj=new LineitemProductWrapper();
                    wrapobj.lineitem=lineItemrecord;
                    wrapobj.NonDiscountedPrice=0;
                    wrapobj.calculatedPrice = (lineItemrecord.Non_Discounted_Price__c!=null?lineItemrecord.Non_Discounted_Price__c:0.0) * (lineItemrecord.Apttus_QPConfig__Quantity2__c);

                    PreviewList.add(wrapobj);
                }
            }


        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());

            //return fetchLineItems;
        }
        return PreviewList;
    }

    @AuraEnabled
    public static List<LineItemGroupWrapper> getSummaryData(String rcrdId){
        Id currentrecord;
        List<LineItemGroupWrapper> lstOfSummary = new List<LineItemGroupWrapper>();
        try{
            Schema.DescribeFieldResult fieldResult = Apttus_Proposal__Proposal_Line_Item__c.APTS_Discount_Reason__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            String currencyCode='';
            Map<String,String> mapOfPicklistVal = new Map<String,String>();
            for(Schema.PicklistEntry picklistFld:ple){
                mapOfPicklistVal.put(picklistFld.getValue(),picklistFld.getLabel());
            }
            if(fetchLineItems==null || fetchLineItems.isEmpty()){
                fetchLineItems = [select id,name,Apttus_Proposal__Product__c,Product_Code__c ,Apttus_Proposal__Description__c ,Apttus_Proposal__Product__r.ProductCode,
                        Apttus_Proposal__Product__r.name,Apttus_Proposal__Proposal__c,APTS_Product_Code__c,Apttus_QPConfig__LineType__c,
                        Non_Discounted_Price__c,Apttus_QPConfig__Quantity2__c,LTDestinationCode__c,Apttus_Proposal__Proposal__r.Program__c,
                        Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,Discount__c,LTCourseNumber__c,
                        APTS_Discount_Reason__c,Apttus_QPConfig__NetPrice__c,CurrencyIsoCode,
                        Apttus_QPConfig__IsOptional__c,(Select Id,Apttus_QPConfig__IncentiveCode__c,Apttus_QPConfig__IncentiveId__r.name,Apttus_QPConfig__IncentiveAdjustmentAmount__c FROM Apttus_QPConfig__AdjustmentLineItems__r)
                from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =:rcrdId];
            }
            AggregateResult[] groupedResults =[Select Sum(Apttus_QPConfig__NetPrice__c)netPrice,Sum(Non_Discounted_Price__c)orgPrice,APTS_Discount_Reason__c,Sum(Apttus_QPConfig__Quantity2__c)DiscountQuantity,MAX(CurrencyIsoCode)currency
                                                from Apttus_Proposal__Proposal_Line_Item__c WHERE (Apttus_Proposal__Proposal__c =: rcrdId AND (NOT(APTS_Product_Code__c=:Label.FTEFX_Article_Code AND Non_Discounted_Price__c =: 0))) group by APTS_Discount_Reason__c];
            for(AggregateResult ar:groupedResults){
                currencyCode = String.valueOf(ar.get('currency'));
                if(ar.get('APTS_Discount_Reason__c')!=null && String.valueOf(ar.get('APTS_Discount_Reason__c'))!=''){
                    LineItemGroupWrapper lineItemWrp = new LineItemGroupWrapper();
                    lineItemWrp.ProductCode = String.valueOf(ar.get('APTS_Discount_Reason__c'));
                    //lineItemWrp.ProductCode = mapOfPicklistVal.get(String.valueOf(ar.get('APTS_Discount_Reason__c')));
                    System.debug('lineItemWrp.ProductCode== '+lineItemWrp.ProductCode);
                    lineItemWrp.netPrice = (Decimal)ar.get('netPrice')-(Decimal)ar.get('orgPrice');
                    lineItemWrp.DiscountQuantity = (Decimal)ar.get('DiscountQuantity');
                    lineItemWrp.ProductName = mapOfPicklistVal.get(String.valueOf(ar.get('APTS_Discount_Reason__c')));
                    //lineItemWrp.ProductName = String.valueOf(ar.get('APTS_Discount_Reason__c'));
                    System.debug('lineItemWrp.ProductName== '+lineItemWrp.ProductName);
                    lineItemWrp.CurrencyPreview = String.valueOf(ar.get('currency'));
                    lineItemWrp.calculatedPrice = lineItemWrp.netPrice * lineItemWrp.DiscountQuantity;
                    lstOfSummary.add(lineItemWrp);
                }
            }
            System.debug('currencyCode =$$$$== '+currencyCode);
            Map<String,LineItemGroupWrapper> mapOfIncentiveCode = new Map<String,LineItemGroupWrapper>();
            for(Apttus_Proposal__Proposal_Line_Item__c proposal: fetchLineItems){
                for(Apttus_QPConfig__ProposalAdjustmentLineItem__c adj:proposal.Apttus_QPConfig__AdjustmentLineItems__r){
                    if(adj.Apttus_QPConfig__IncentiveCode__c!=null && adj.Apttus_QPConfig__IncentiveCode__c!=''){
                        if(mapOfIncentiveCode.containsKey(adj.Apttus_QPConfig__IncentiveCode__c)){
                            LineItemGroupWrapper lineItem = mapOfIncentiveCode.get(adj.Apttus_QPConfig__IncentiveCode__c);
                            lineItem.netPrice += adj.Apttus_QPConfig__IncentiveAdjustmentAmount__c!=null?adj.Apttus_QPConfig__IncentiveAdjustmentAmount__c:0.0;
                            lineItem.calculatedPrice  = lineItem.netPrice;
                        }else{
                            LineItemGroupWrapper lineItem = new LineItemGroupWrapper();
                            lineItem.netPrice = adj.Apttus_QPConfig__IncentiveAdjustmentAmount__c!=null?adj.Apttus_QPConfig__IncentiveAdjustmentAmount__c:0.0;
                            lineItem.ProductCode = adj.Apttus_QPConfig__IncentiveCode__c;
                            lineItem.ProductName = adj.Apttus_QPConfig__IncentiveId__r.name;
                            lineItem.CurrencyPreview = currencyCode;
                            lineItem.calculatedPrice  = lineItem.netPrice;
                            mapOfIncentiveCode.put(lineItem.ProductCode,lineItem);
                            lstOfSummary.add(lineItem);
                        }
                    }
                }
            }
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());
        }

        return lstOfSummary;
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

    @AuraEnabled
    public static boolean saveTempData(string summaryData, String rcrdId){
        Id currentrecord;
        List<TemporaryQuoteLineItem__c> lstOfQuoteData = new List<TemporaryQuoteLineItem__c>();
        List<LineItemGroupWrapper> lstOfSummaryData = (List<LineItemGroupWrapper>)JSON.deserialize(summaryData,List<LineItemGroupWrapper>.class);
        try{
            lstOfQuoteData = [Select id from TemporaryQuoteLineItem__c where Quote_Proposal__c =: rcrdId];
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());

            lstOfQuoteData = new List<TemporaryQuoteLineItem__c>();
        }
        if(lstOfQuoteData.size()>0){
            delete lstOfQuoteData;
        }

        try{
            system.debug('======>> '+lstOfSummaryData.size());
            TemporaryQuoteLineItem__c QLine;
            for(LineItemGroupWrapper lst: lstOfSummaryData){
                QLine = new TemporaryQuoteLineItem__c();
                QLine.Quote_Proposal__c = (Id) rcrdId;
                QLine.Quantity__c = lst.DiscountQuantity;
                QLine.Discount_Reason__c = lst.ProductCode;
                QLine.Article_Name__c = lst.ProductName;
                QLine.Net_Price__c = lst.netPrice;
                lstOfQuoteData.add(QLine);
            }
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());
            return false;
        }
        try{
            insert lstOfQuoteData;
        }catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'QuotePreview', 'Preview', currentrecord);
            System.debug('Cannot Preview Line Items '+ex.getMessage());
            return false;
        }
        return true;
    }


    Public class LineitemProductWrapper{
        @AuraEnabled
        public Apttus_Proposal__Proposal_Line_Item__c lineitem {get;set;}
        @AuraEnabled
        public Decimal PriceQuantity {get;set;}
        @AuraEnabled
        public Decimal NonDiscountedPrice {get;set;}
        @AuraEnabled
        public Product2 product {get;set;}
        @AuraEnabled
        public Decimal calculatedPrice{get;set;}


    }

    public class LineItemGroupWrapper{
        @AuraEnabled
        public Decimal netPrice{get;set;}
        @AuraEnabled
        public String ProductName{get;set;}
        @AuraEnabled
        public String ProductCode{get;set;}
        @AuraEnabled
        public Decimal DiscountQuantity{get;set;}
        @AuraEnabled
        public Decimal calculatedPrice{get;set;}
        @AuraEnabled
        public String CurrencyPreview{get;set;}

    }


}