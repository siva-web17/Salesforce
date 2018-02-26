/**
 * Created by Arkadiusz Celej on 31.01.2018.
 * @description Controller class for DatesQuantityConfigurator And DatesQuantityConfigurator related Lightning Components
 */

public class DatesQuantityConfiguratorController {
    public Id cartId {get;set;}
    public String backCartUrl{ get; set; }
    public DatesQuantityConfiguratorController(){
        this.cartId = ApexPages.CurrentPage().getparameters().get('id');
        String configId2 = ApexPages.currentPage().getParameters().get('id');
        String configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        String cartStatus = ApexPages.currentPage().getParameters().get('cartStatus');
        String cartFlow = ApexPages.currentPage().getParameters().get('flow');
        backCartUrl = Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId;
        if(cartStatus != NULL){
            backCartUrl = backCartUrl +'&cartStatus=' + cartStatus;
        }
        if(cartFlow != NULL){
            backCartUrl = backCartUrl + '&flow=' +cartFlow;
        }
    }

    @AuraEnabled
    public static Map<Decimal, List<Apttus_Config2__LineItem__c>> getCartLineItems(Id cartId){
        try {
            String query = 'SELECT ';
            for (Schema.FieldSetMember f : SObjectType.Apttus_Config2__LineItem__c.FieldSets.EditStartEndDateFieldSet.getFields()) {
                query += f.getFieldPath() + ', ';
            }

            query += 'Id, Product_Subtype__c, Name, Beginner__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__LineType__c, APTS_EnableStartDateEndDate__c, Program__c, ';
            query += 'Apttus_Config2__Uom__c, Apttus_Config2__EndDate__c, APTS_QunatityModifiable__c, Apttus_Config2__StartDate__c, Apttus_Config2__Quantity__c, ';
            query += 'DestinationCode__c, Apttus_Config2__ProductId__r.APTS_Destination_Location__c, Apttus_Config2__OptionId__r.APTS_AY_Course_Type__c,Apttus_Config2__OptionId__r.Available_Programs__c,Apttus_Config2__LineNumber__c, Apttus_Config2__OptionId__c, ';
            query += 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Market__c ';
            query += 'from Apttus_Config2__LineItem__c ';
            query += 'where Apttus_Config2__ConfigurationId__c = :cartId ' ;
            query += ' and APTS_EnableStartDateEndDate__c = TRUE ORDER BY Apttus_Config2__LineNumber__c, APTTUS_CONFIG2__ITEMSEQUENCE__C' ;

            List<Apttus_Config2__LineItem__c> lineItems = Database.query(query);
            return mapLineItems(lineItems);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void saveLineItems(String cartId, List<Apttus_Config2__LineItem__c> lineItems){
        try {
            updateItemsBeforeSave(lineItems);
            update lineItems;
            resetSeasonSuplements(cartId, mapLineItems(lineItems));
        }catch (Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

    private static void updateItemsBeforeSave(List<Apttus_Config2__LineItem__c> lineItems){
        for(Apttus_Config2__LineItem__c item : lineItems){
            item.Apttus_Config2__PricingStatus__c = 'Pending';
        }
    }

    private static void resetSeasonSuplements(String cartId, Map<Decimal, List<Apttus_Config2__LineItem__c>> itemsByLineNumber){
        for(Decimal lineNumber: itemsByLineNumber.keySet()){
            for(Apttus_Config2__LineItem__c lineItem : itemsByLineNumber.get(lineNumber)) {
                if (lineItem.APTS_Product_Type__c == 'Course') {
                    SeasonSupplementsHelper.createOptionLineItem(cartId, lineItem, itemsByLineNumber);
                }
            }
        }
    }

    @AuraEnabled
    public static Integer repriceCart(String cartId){
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO priceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        priceRequestDO.cartId = cartId;
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(priceRequestDO);
        return result.PendingLineNumbers.size();
    }

    @AuraEnabled
    public static List<Start_Dates__c> getAvailableStartDates(Apttus_Config2__LineItem__c item) {
        System.debug('ITEM '+item);
        Boolean isAdmin = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name == 'System Administrator';
        return StartDateHelper.getAvailableStartDates(item.Product_Code__c, item.DestinationCode__c, item.Beginner__c, isAdmin, item.Program__c);
    }

    @AuraEnabled
    public static List<StartDateSettings__mdt> getAvailableStartDateSettings(Apttus_Config2__LineItem__c item) {
        return StartDatesSelector.getStartDateSettings(item.DestinationCode__c,item.Program__c);
    }

    private static Map<Decimal, List<Apttus_Config2__LineItem__c>> mapLineItems(List<Apttus_Config2__LineItem__c> lineItems){
        Map<Decimal, List<Apttus_Config2__LineItem__c>> mappedItems = new Map<Decimal, List<Apttus_Config2__LineItem__c>>();
        for(Apttus_Config2__LineItem__c lineItem : lineItems){
            if(!mappedItems.containsKey(lineItem.Apttus_Config2__LineNumber__c)){
                mappedItems.put(lineItem.Apttus_Config2__LineNumber__c, new List<Apttus_Config2__LineItem__c>());
            }
            mappedItems.get(lineItem.Apttus_Config2__LineNumber__c).add(lineItem);
        }
        return mappedItems;
    }

    public class AuraException extends Exception{}
}