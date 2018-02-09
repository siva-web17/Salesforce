/**
 * This apex class provides methods to create test data for Apttus CPQ flow.
 * Created By - Husen Sayyed
 * Created Date - 21st Dec, 2017
 */
@isTest
public class APTS_CPQTestUtility {
    
    /*
     * Create Test Account
     */
    public static Account createAccount(String strName, String strType) {
        Account testAccount = new Account();
        testAccount.Name = strName;
        testAccount.Type = strType;
        
        return testAccount;
        
    }
    
    /*
     * Create Test Contact
     */
    public static Contact createContact(String strLastName, String strAccountId) {
        Contact testContact = new Contact();
        testContact.LastName = strLastName;
        testContact.AccountId = strAccountId;
        
        return testContact;
        
    }
    
    /*
     * Create Test Opportunity
     */
    public static Opportunity createOpportunity(String strName, String strType, Id accountId, String strStageName) {
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = strName;
        testOpportunity.Type = strType;
        testOpportunity.AccountId = accountId;
        testOpportunity.StageName = strStageName;
        testOpportunity.CloseDate = date.Today().addDays(365);
        
        return testOpportunity;
    }
    
    /*
     * Create Price List
     */
    public static Apttus_Config2__PriceList__c createPriceList(String strName, Boolean bIsActive) {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Name = strName;
        priceList.Apttus_Config2__Active__c = bIsActive;
        priceList.Version__c = 'V1';
        priceList.Year__c = '2017';
        
        return priceList;
    }
    
    /*
     * Create  Product
     */
    public static Product2 createProduct(String productName, String productCode, String productFamily, String strConifgurationType, Boolean bCustomizable, Boolean bHasOptions, Boolean bHasAttributes, Boolean bIsActive) {
        Product2 product = new Product2();
        product.Name = productName;
        product.ProductCode = productCode;
        product.Family = productFamily;
        product.Apttus_Config2__ConfigurationType__c = strConifgurationType;
        product.Apttus_Config2__Customizable__c = bCustomizable;
        product.Apttus_Config2__HasOptions__c = bHasOptions;
        product.Apttus_Config2__HasAttributes__c = bHasAttributes;
        product.IsActive = bIsActive;
        product.Apttus_Config2__Uom__c = 'Each';
        product.Apttus_Config2__Version__c = 1.0;
        product.EnableStartDateEndDate__c = true;
        
        return product; 
    }
    
    /**
        Create PricebookEntry 
    **/
    public static PricebookEntry createPricebookEntry(String pricebookId, String productID, Integer iUnitPrice, Boolean bIsActive){                                        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = productID;
        standardPrice.UnitPrice = iUnitPrice;
        standardPrice.IsActive = bIsActive;
        
        return standardPrice;                                        
     } 
    
    /*
     * Create Price List Item
     */
    public static Apttus_Config2__PriceListItem__c createPriceListItem(Id priceListId, Id productId, decimal dListPrice, String strChargeType, String strPriceType, String strPriceMethod, String strPriceUoM, Boolean bIsActive) {
        Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c();
        pli.Apttus_Config2__PriceListId__c = priceListId;
        pli.Apttus_Config2__ProductId__c = productId;
        pli.Apttus_Config2__ListPrice__c = dListPrice;
        pli.Apttus_Config2__ChargeType__c = strChargeType;
        pli.Apttus_Config2__PriceType__c = strPriceType;
        pli.Apttus_Config2__PriceMethod__c = strPriceMethod;
        pli.Apttus_Config2__PriceUom__c = strPriceUoM;
        pli.Apttus_Config2__Active__c = bIsActive;
                
        return pli;
    }
    
    /*
     * Create Proposal
     */
    public static Apttus_Proposal__Proposal__c createProposal( String quoteName, ID accId, ID optyId, String recordTypeName, ID priceList){
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c = quoteName;
        proposal.Apttus_Proposal__Opportunity__c = optyId;
        proposal.Apttus_Proposal__Account__c = accId;
        proposal.RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        proposal.Apttus_QPConfig__PriceListId__c = priceList;
        
        return proposal;
    }
    
    /*
     * Create Configuration
     */
    public static Apttus_Config2__ProductConfiguration__c createConfiguration(String configName, Id accountId, Id priceListId, Id proposalId) {
        Apttus_Config2__ProductConfiguration__c prodConfigRecord = new Apttus_Config2__ProductConfiguration__c(
            Name = configName,
            Apttus_Config2__AccountId__c = accountId,
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_QPConfig__Proposald__c = proposalId,
            Apttus_Config2__VersionNumber__c = 1
        );
        
        return prodConfigRecord;
    }
    
    /*
     * Create Configuration
     */
    public static Apttus_Config2__ProductConfiguration__c getConfiguration() {        
        return [select Id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c limit 1];
    }
    
    /*
     * Create Classification Hierarchy
     */
    public static Apttus_Config2__ClassificationHierarchy__c createClassificationHierarchy(String strCategoryId, String strLabel) {
        
        Apttus_Config2__ClassificationHierarchy__c classificationHierarchy = new Apttus_Config2__ClassificationHierarchy__c();
        classificationHierarchy.Apttus_Config2__HierarchyId__c = strCategoryId;
        classificationHierarchy.Apttus_Config2__Label__c = strLabel;
        
        return classificationHierarchy;
    }
    
    /*
     * Create Category
     */
    public static Apttus_Config2__ClassificationName__c createCategory(String strName, String strHierarchyLabel, String strType, String strGuidePage, Boolean bIsActive) {
        Apttus_Config2__ClassificationName__c category = new Apttus_Config2__ClassificationName__c();
        category.Name = strName;
        category.Apttus_Config2__HierarchyLabel__c = strHierarchyLabel;
        category.Apttus_Config2__Type__c = strType;
        category.Apttus_Config2__GuidePage__c = strGuidePage;
        category.Apttus_Config2__Active__c = bIsActive;
        return category;
    }

    /*
     * Create Product Option Component
     */
    public static Apttus_Config2__ProductOptionComponent__c createProductOptionComponent(Integer iSequence) {
        Apttus_Config2__ProductOptionComponent__c productOptionComponent = new Apttus_Config2__ProductOptionComponent__c();
        productOptionComponent.Apttus_Config2__Sequence__c = iSequence;
        return productOptionComponent;
    }
    
    /*
     * Create Summary Group
     */
    public static Apttus_Config2__SummaryGroup__c createSummaryGroup(String strConfigId, Integer itemSequence, Integer lineNumber) {
    
        Apttus_Config2__SummaryGroup__c summaryGroup = new Apttus_Config2__SummaryGroup__c ();
        summaryGroup.Apttus_Config2__ConfigurationId__c = strConfigId;
        summaryGroup.Apttus_Config2__ItemSequence__c = itemSequence;
        summaryGroup.Apttus_Config2__LineNumber__c = lineNumber;
        return summaryGroup ;   
    }
    
    /*
     *  Create Line Item 
     */
    public static void createLineItem(Id cartId, Id productId, Integer iQty){
        
        Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        selProdDO.ProductID = productId;
        selProdDO.Quantity = iQty;
        
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requestBundle = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requestBundle.CartId = cartId;
        requestBundle.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>{selProdDO};
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requestBundle);
    }
    
    /*
     * Create Proposal line Item                                        
     */
    public static void createProposalLineItem(Id cartId){        
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO finalRequest = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        finalRequest.CartId = cartId;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO finalResponse = Apttus_CPQApi.CPQWebService.finalizeCart(finalRequest);
    }
    
    /*
     * Create Product Attribute Value
     */
    public static Apttus_Config2__ProductAttributeValue__c createAttributeValue(Id lineItemId) {
        
        Apttus_Config2__ProductAttributeValue__c pav= new Apttus_Config2__ProductAttributeValue__c();
        pav.Apttus_Config2__LineItemId__c = lineItemId;        
        
        return pav;
    }
    
    /*
     * Create Product Attribute Group
     */
    public static Apttus_Config2__ProductAttributeGroup__c createProductAttributeGroup(String strName, String businessObject, String strDescription, Boolean bTwoColumnDisplay) {
        Apttus_Config2__ProductAttributeGroup__c productAttributeGroup = new Apttus_Config2__ProductAttributeGroup__c();
        productAttributeGroup.Name = strName;
        productAttributeGroup.Apttus_Config2__BusinessObject__c = businessObject;
        productAttributeGroup.Apttus_Config2__Description__c = strDescription;
        productAttributeGroup.Apttus_Config2__TwoColumnAttributeDisplay__c = bTwoColumnDisplay;
        
        return productAttributeGroup;
    }
    
    /*
     * Create Product Attribute
     */
    public static Apttus_Config2__ProductAttribute__c createProductAttribute(String strAttributeGroupId, String strField, Boolean bIsHidden, Boolean bIsReadOnly, String strProductAttributeValueField, Integer iSequence) {
        Apttus_Config2__ProductAttribute__c pa = new Apttus_Config2__ProductAttribute__c();
        pa.Apttus_Config2__AttributeGroupId__c = strAttributeGroupId;
        pa.Apttus_Config2__Field__c = strField;
        pa.Apttus_Config2__IsHidden__c = bIsHidden;
        pa.Apttus_Config2__IsReadOnly__c = bIsReadOnly;
        pa.Apttus_Config2__ProductAttributeValueField__c = strProductAttributeValueField;
        pa.Apttus_Config2__Sequence__c = iSequence;
        
        return pa;
    }
    
    /* 
     * Create Proposal Product Attribute value                                        
     */
    public static Apttus_QPConfig__ProposalProductAttributeValue__c createProposalProductAttributeValue(String strProposalLineItemId){
        
        Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttributeValue = new Apttus_QPConfig__ProposalProductAttributeValue__c ();
        ProposalProductAttributeValue.Apttus_QPConfig__LineItemId__c = strProposalLineItemId;
               
        return ProposalProductAttributeValue;
    }   
    
    /*
     * Create Price Dimension
     */
    public static Apttus_Config2__PriceDimension__c createPriceDimension(String dimensionName, String contextType, String businessObject,
                                                                        String field, Id productAttributeId) {
        Apttus_Config2__PriceDimension__c priceDimension = new Apttus_Config2__PriceDimension__c();
        priceDimension.Name = dimensionName;
        priceDimension.Apttus_Config2__ContextType__c = contextType;
        priceDimension.Apttus_Config2__BusinessObject__c = businessObject;
        priceDimension.Apttus_Config2__Datasource__c = field;
        priceDimension.Apttus_Config2__AttributeId__c = productAttributeId;
        
        return priceDimension;
    }
    
    /*
     * Create Price Matrix
     */
    public static Apttus_Config2__PriceMatrix__c createPriceMatrix(Id priceListItemId, Id dimension1Id, Id dimension2Id, Id dimension3Id, String strDimension1ValueType, String strDimension2ValueType, String strDimension3ValueType) {
        Apttus_Config2__PriceMatrix__c pm = new Apttus_Config2__PriceMatrix__c();
        pm.Apttus_Config2__Sequence__c = 1;
        pm.Apttus_Config2__PriceListItemId__c = priceListItemId;
        pm.Apttus_Config2__Dimension1Id__c = dimension1Id;
        pm.Apttus_Config2__Dimension1ValueType__c = strDimension1ValueType;
        pm.Apttus_Config2__Dimension2Id__c = dimension2Id;
        pm.Apttus_Config2__Dimension2ValueType__c = strDimension2ValueType;
        pm.Apttus_Config2__Dimension3Id__c = dimension3Id;
        pm.Apttus_Config2__Dimension3ValueType__c = strDimension3ValueType;
        
        return pm;
    }
    
    /*
     * Create Price Matrix Entry
     */
    public static Apttus_Config2__PriceMatrixEntry__c createPriceMatrixEntry(String strPriceMatrixId, Integer iSequence, String strDimension1Value, String strDimension2Value, String strDimension3Value, decimal dPriceOverride, decimal dUnitPrice, decimal dAdjustmentAmount, String strAdjustmentType) {
        Apttus_Config2__PriceMatrixEntry__c pme = new Apttus_Config2__PriceMatrixEntry__c();
        pme.Apttus_Config2__PriceMatrixId__c = strPriceMatrixId;
        pme.Apttus_Config2__Sequence__c = iSequence;
        pme.Apttus_Config2__Dimension1Value__c = strDimension1Value;
        pme.Apttus_Config2__Dimension2Value__c = strDimension2Value;
        pme.Apttus_Config2__Dimension3Value__c = strDimension3Value;
        pme.Apttus_Config2__PriceOverride__c = dPriceOverride;
        pme.Apttus_Config2__UsageRate__c = dUnitPrice;
        pme.Apttus_Config2__AdjustmentAmount__c = dAdjustmentAmount;
        pme.Apttus_Config2__AdjustmentType__c = strAdjustmentType;
        
        return pme;
    }
    
    /*
     * Create Usage Price Tier
     */
    public static Apttus_Config2__UsagePriceTier__c createUsagePriceTier(String strLineItemId, String strPriceMatrixId, integer iSequence, String strDimension1Value, String strDimension2Value, String strDimension3Value, decimal dStartValue, decimal dEndValue, decimal dUnitPrice, decimal dPriceOverride, decimal dAdjustmentAmount, String strAdjustmentType) {
        Apttus_Config2__UsagePriceTier__c upt = new Apttus_Config2__UsagePriceTier__c();
        upt.Apttus_Config2__LineItemId__c = strLineItemId;
        upt.Apttus_Config2__PriceMatrixId__c = strPriceMatrixId;
        upt.Apttus_Config2__Dimension1Value__c = strDimension1Value;
        upt.Apttus_Config2__Dimension2Value__c = strDimension2Value;
        upt.Apttus_Config2__Dimension3Value__c = strDimension3Value;
        upt.Apttus_Config2__TierStartValue__c = dStartValue;
        upt.Apttus_Config2__TierEndValue__c = dEndValue;
        upt.Apttus_Config2__UsageRate__c = dUnitPrice;
        upt.Apttus_Config2__PriceOverride__c = dPriceOverride;
        upt.Apttus_Config2__AdjustmentAmount__c = dAdjustmentAmount;
        upt.Apttus_Config2__AdjustmentType__c = strAdjustmentType;
        upt.Apttus_Config2__Sequence__c = iSequence;
        
        return upt;
    }
    
    /*
     * Create Proposal Usage Price Tier
     */
    public static Apttus_QPConfig__ProposalUsagePriceTier__c createProposalUsagePriceTier(String strProposalLineItemId, String strPriceMatrixId, integer iSequence, String strDimension1Value, String strDimension2Value, String strDimension3Value, decimal dStartValue, decimal dEndValue, decimal dUnitPrice, decimal dPriceOverride, decimal dAdjustmentAmount, String strAdjustmentType) {
        Apttus_QPConfig__ProposalUsagePriceTier__c pupt = new Apttus_QPConfig__ProposalUsagePriceTier__c();
        pupt.Apttus_QPConfig__LineItemId__c = strProposalLineItemId;
        pupt.Apttus_QPConfig__PriceMatrixId__c = strPriceMatrixId;
        pupt.Apttus_QPConfig__Dimension1Value__c = strDimension1Value;
        pupt.Apttus_QPConfig__Dimension2Value__c = strDimension2Value;
        pupt.Apttus_QPConfig__Dimension3Value__c = strDimension3Value;
        pupt.Apttus_QPConfig__TierStartValue__c = dStartValue;
        pupt.Apttus_QPConfig__TierEndValue__c = dEndValue;
        pupt.Apttus_QPConfig__UsageRate__c = dUnitPrice;
        pupt.Apttus_QPConfig__PriceOverride__c = dPriceOverride;
        pupt.Apttus_QPConfig__AdjustmentAmount__c = dAdjustmentAmount;
        pupt.Apttus_QPConfig__AdjustmentType__c = strAdjustmentType;
        pupt.Apttus_QPConfig__Sequence__c = iSequence;
        
        return pupt;
    }
}