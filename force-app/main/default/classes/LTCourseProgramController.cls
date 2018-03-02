/**
* Created by saiharish.r on 12/1/2017.
*/

public class LTCourseProgramController {

    public static String configRequestId { get; set; }
    public static String lineItemId{ get; set; }
    public static String cartFlow{ get; set; }
    public static String backCartUrl{ get; set; }
    public static String configId2 { get; set; }
    public static String quoteId { get; set; }
    public List<LTCourseProgram__c> availableLTCourseDates { get; set; }
    public Map<Id,LTCourseProgram__c> LtProgramMap{get;set;}
    public String SelectedLTCourseId{get;set;}
    public LTCourseProgramController()
    {
        configId2 = ApexPages.currentPage().getParameters().get('id');
        configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        lineItemId = ApexPages.currentPage().getParameters().get('lineItemId');
        cartFlow = ApexPages.currentPage().getParameters().get('flow');
        quoteId=ApexPages.currentPage().getParameters().get('retId');
        backCartUrl = Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId;
        getLTCourseValues();
    }

    public List<LTCourseProgram__c> getLTCourseValues()
    {
        try {
            availableLTCourseDates = new List<LTCourseProgram__c>();
            LtProgramMap = new Map<Id, LTCourseProgram__c>();
            List<Id> quoteIdList = new List<Id>();
            quoteIdList.add(Id.valueOf(quoteId));
            List<Apttus_Proposal__Proposal__c> currentQuote = QuoteProposalsSelector.getSelectedQuoteByID(quoteIdList);
            if (currentQuote != null && currentQuote.size() > 0) {
                LtProgramMap = LTCourseProgramsSelector.getLTCoursePrograms(currentQuote[0].Apttus_QPConfig__PriceListId__r.Market__c, currentQuote[0].Apttus_QPConfig__PriceListId__r.Year__c, currentQuote[0].Apttus_QPConfig__PriceListId__r.Version__c, currentQuote[0].Apttus_QPConfig__PriceListId__r.CurrencyIsoCode);
                availableLTCourseDates = LtProgramMap.values();
            }
        }
        catch(Exception ex){
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'LTCourseProgramController', 'getLTCourseValues', null);
        }

        return availableLTCourseDates;

    }
    public pageReference refresh= ApexPages.currentPage();
    public string callfunc{get;set;}
    public PageReference submit() {
        try {

            System.debug('I have called controller method' + lineItemId);
            //p=  new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
            //LineItemsSelector.getLineItemsForselectedConfigId();
            List<Id> LineItemIdList = new List<Id>();
            lineItemId = ApexPages.currentPage().getParameters().get('lineItemId');
            configId2 = ApexPages.currentPage().getParameters().get('id');
            configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
            LineItemIdList.add(Id.valueOf(lineItemId));
            if (LtProgramMap.containsKey(Id.valueOf(SelectedLTCourseId))) {
                LTCourseProgram__c selectedLTCourse = LtProgramMap.get(Id.valueOf(SelectedLTCourseId));
                list<Apttus_Config2__LineItem__c> currentLineItems = LTCourseProgramHelper.getLineItems(configId2);
                System.debug('Before Calling API' + currentLineItems);
            Apttus_CPQApi.CPQ.AddOptionsResponseDO createdLineItem = LTCourseProgramHelper.addSelectedLTCourseProgramLineItemToCart(Id.ValueOf(configId2),
                        currentLineItems,
                        selectedLTCourse.Apttus_Config2_ProductId__c,
                        selectedLTCourse.APTS_Start_Date__c,
                        selectedLTCourse.APTS_End_Date__c,
                        Double.valueOf(selectedLTCourse.APTS_LT_Course_Price__c));

                Map<Id,Apttus_Config2__ProductAttributeValue__c> PavMap= APTS_EFPricingCallbackHelper.getLTCoursePriceFromPAV(LineItemIdList);
                System.debug('Before Update' +PavMap);
                for (Apttus_Config2__ProductAttributeValue__c pavLoopRecord:PavMap.values()) {
                    for (Schema.FieldSetMember f : SObjectType.LTCourseProgram__c.FieldSets.LTCourseProgramFieldSet.getFields()) {
                        pavLoopRecord.put(f.getFieldPath(), selectedLTCourse.get(f.getFieldPath()));
                    }
                    //pavLoopRecord.LTDestinationCode__c=selectedLTCourse.get(f.getFieldPath());
                }
                update PavMap.values();
                //Apttus_Config2.CustomClass.ValidationResult  v = Apttus_Config2__CPQWebService.validateCart(Id cartId);
                if (configId2 != null) {
                    refresh =new PageReference(Site.getPathPrefix()+'/apex/Apttus_Config2__Cart'+ '?id=' + lineItemId + '&callerPage=SelectConfigProducts&configRequestId=' + configRequestId);

                    //refresh = new PageReference(Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId);
                    //refresh = new PageReference(Site.getPathPrefix() + '/apex/Cart?cartStatus=New&id=' + configId2 + '&configRequestId=' + configRequestId);
                    //Cart?cartStatus=New&oldConfigId=a2N6E0000003BT6UAM&configRequestId=a346E000000109WQAQ&id=a2N6E0000003C1QUAU&flow=NGDefault&launchState=cart#/configure/10002
                    //system.debug('==configId2==' + configId2 + '==flowName==' + flowName);
                    refresh.setRedirect(false);
                    system.debug('==pr==' + refresh);
                    //return pr;
                }
                if (createdLineItem != null && createdLineItem.addedOptionLineItems.size() > 0) {
                    Apttus_Config2__ProductAttributeValue__c PAVRecord = new Apttus_Config2__ProductAttributeValue__c();
                    PAVRecord.Apttus_Config2__LineItemId__c = createdLineItem.addedOptionLineItems[0].Id;
                    List<Apttus_Config2__ProductAttributeValue__c> PAVList=new List<Apttus_Config2__ProductAttributeValue__c>();
                    //List<Id> LineItemIdList=new List<Id>();
                    LineItemIdList.Clear();
                    for (Schema.FieldSetMember f : SObjectType.LTCourseProgram__c.FieldSets.LTCourseProgramFieldSet.getFields()) {
                        PAVRecord.put(f.getFieldPath(), selectedLTCourse.get(f.getFieldPath()));
                    }
                    Insert PAVRecord;
                    //PAVList.add(PAVRecord);
                    System.debug('PAVList' +PAVList);
                    for (Apttus_Config2__LineItem__c LineItem:currentLineItems) {
                        //Apttus_Config2__ProductAttributeValue__c ObjectPAVToUpdate= new Apttus_Config2__ProductAttributeValue__c();
                        //System.debug('ObjectPAVToUpdate LineItem.Apttus_Config2__AttributeValueId__c' +LineItem.Apttus_Config2__AttributeValueId__c);
                        //ObjectPAVToUpdate.Id=LineItem.Apttus_Config2__AttributeValueId__c;
                        //ObjectPAVToUpdate.LTDestinationCode__c=selectedLTCourse.LTDestinationCode__c;
                        LineItemIdList.add(LineItem.Id);
                        //if (!PAVId.contains(ObjectPAVToUpdate.Id)) {
                            //PAVList.add(ObjectPAVToUpdate);
                        //}
                        System.debug('ObjectPAVToUpdate Next' +LineItemIdList);
                    }
                   /* Map<Id,Apttus_Config2__ProductAttributeValue__c> PavMap= APTS_EFPricingCallbackHelper.getLTCoursePriceFromPAV(LineItemIdList);
                    System.debug('Before Update' +PavMap);
                    for (Apttus_Config2__ProductAttributeValue__c pavLoopRecord:PavMap.values()) {
                        for (Schema.FieldSetMember f : SObjectType.LTCourseProgram__c.FieldSets.LTCourseProgramFieldSet.getFields()) {
                            pavLoopRecord.put(f.getFieldPath(), selectedLTCourse.get(f.getFieldPath()));
                        }
                        //pavLoopRecord.LTDestinationCode__c=selectedLTCourse.get(f.getFieldPath());
                    }
                    update PavMap.values();
                    System.debug('After Update' +PavMap.values());*/
                }
                System.debug('Repriceing cart here');
                //After adding Line item we ar repricing the cart
                Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
                objUpdatePriceRequestDO.CartId = configId2;
                //Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
                //Navigating back to cart page after selecting the course
                if (configId2 != null) {
                    //refresh = new PageReference(Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId);
                    //refresh = new PageReference(Site.getPathPrefix() + '/apex/Cart?cartStatus=New&id=' + configId2 + '&configRequestId=' + configRequestId);
                    //Cart?cartStatus=New&oldConfigId=a2N6E0000003BT6UAM&configRequestId=a346E000000109WQAQ&id=a2N6E0000003C1QUAU&flow=NGDefault&launchState=cart#/configure/10002
                    //system.debug('==configId2==' + configId2 + '==flowName==' + flowName);
                    //refresh.setRedirect(false);
                    system.debug('==pr==' + refresh);
                    //return pr;
                }

            }
        }
        catch(Exception ex){
        ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
        'LTCourseProgramController', 'submit', null);
    }
        return refresh;


    }






}