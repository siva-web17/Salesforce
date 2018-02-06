@isTest
public class APTS_EFPricingCallback_Test{

    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    private static final String PRICE_TYPE_RECURRING = 'Recurring';
    private static final String CHARGE_TYPE_OVERAGE = 'Overage';
    private static final String CHARGE_TYPE_INCLUDED_UNITS = 'Included Units';
    private static final String CHARGE_TYPE_COMMIT = 'Commit';
    private static final String CHARGE_TYPE_INCLUDED = 'Included';
    private static final String LINE_STATUS_CANCELLED = 'Cancelled';
    
    @testSetup static void testDataSetup() {
        Test.startTest();
        
        //add pricing call back entry in custom setting
        Apttus_Config2__ConfigCustomClasses__c testConfigCustomClasses = new Apttus_Config2__ConfigCustomClasses__c();
        testConfigCustomClasses.Apttus_Config2__PricingCallbackClass__c = 'APTS_EFPricingCallback';
        testConfigCustomClasses.Name = 'System Properties1';
        insert testConfigCustomClasses;
            
        //add custom setting for config line item custom fields in PCB
        List<Apttus_Config2__ConfigLineItemCustomFields__c> testConfigLineItemCustomFieldsList = new List<Apttus_Config2__ConfigLineItemCustomFields__c>();
        Apttus_Config2__ConfigLineItemCustomFields__c testConfigLineItemCustomFields = new Apttus_Config2__ConfigLineItemCustomFields__c();
        testConfigLineItemCustomFields.Apttus_Config2__CustomFieldNames__c = 'Apttus_Config2__PriceListId__r.Brackets_Threshold__c,Apttus_Config2__OptionId__r.Apts_CoursePricing__c,Apttus_Config2__ConfigurationId__r.APTS_Total_Course_Weeks__c,DestinationCode__c,APTS_Language__c,Apttus_Config2__OptionId__r.ProductCode';
        testConfigLineItemCustomFields.Apttus_Config2__CustomFieldNames2__c = 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.ComparativeQuote__c,Apttus_Config2__OptionId__r.Apts_TI_Pricing__c,Apttus_Config2__PriceListId__r.Apts_BracketsThresholdTI__c,Apttus_Config2__OptionId__r.ProductSubtype__c,Product_Code__c';
        testConfigLineItemCustomFields.Name = 'System Properties2';
        testConfigLineItemCustomFieldsList.add(testConfigLineItemCustomFields);
        insert testConfigLineItemCustomFieldsList;
        
        //get system admin profile
        Profile SystemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        System.debug('***TEST CLASS : SystemAdminProfile===>'+SystemAdminProfile);
    
        //insert User
        User testUser = APTS_TestDataUtility.createUser(SystemAdminProfile.ID);
        System.debug('***TEST CLASS : testUser===>'+testUser);
    
        System.runAs(testUser) {

            //Get Standard Price Book Id    
            Id stdPriceBookId = Test.getStandardPricebookId();
            system.debug('*******stdPricebookId====>' + stdPriceBookId);

            //create price list
            Apttus_Config2__PriceList__c priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', 'CNB', 'ILSU', 'USD');
            //insert priceList;
            system.assert(priceList.Name == 'APTPS TST PriceList 1');
            System.debug('***TEST CLASS : priceList===>'+priceList);

            //Create Product
            list<Product2> productsList = new list<Product2>();
            Product2 product1 = APTS_TestDataUtility.createProduct('Auckland 1', 'NZ-AUC', 'Bundle', true, true, true, 'Destination', false, ''); 
            productsList.add(product1);         
            System.debug('***TEST CLASS : PRODUCT 1===>'+product1);
            
            Product2 product2 = APTS_TestDataUtility.createProduct('Intensive Course', 'NZ-AUC', 'Option', true, false, false, 'Course', true, ''); 
            productsList.add(product2);
            System.debug('***TEST CLASS : PRODUCT 2===>'+product2);
            
            Product2 product3 = APTS_TestDataUtility.createProduct('Auckland 2', 'NZ-AUK', 'Bundle', true, true, true, 'Destination', false, ''); 
            productsList.add(product3);
            System.debug('***TEST CLASS : PRODUCT 3===>'+product3);
            
            Product2 product4 = APTS_TestDataUtility.createProduct('Basic Course', 'NZ-AUK', 'Option', true, false, false, 'Course', true, ''); 
            productsList.add(product4);
            System.debug('***TEST CLASS : PRODUCT 4===>'+product4);

            Product2 product5 = APTS_TestDataUtility.createProduct('Auckland 3', 'NZ-AUZ', 'Bundle', true, true, true, 'Destination', false, ''); 
            productsList.add(product5);
            System.debug('***TEST CLASS : PRODUCT 5===>'+product5);
            
            Product2 product6 = APTS_TestDataUtility.createProduct('Junior Course', 'NZ-AUZ', 'Option', true, false, false, 'Course', true, ''); 
            productsList.add(product6);
            System.debug('***TEST CLASS : PRODUCT 6===>'+product6);

            Product2 product7 = APTS_TestDataUtility.createProduct('Travel Insurance', 'NZ-TRI', 'Option', true, false, false, 'Insurance',  false, ''); 
            product7.Apts_TI_Pricing__c = TRUE;
            //product7.Apts_CoursePricing__c = true;
            productsList.add(product7);
            System.debug('***TEST CLASS : PRODUCT 7===>'+product7);

            Product2 product8 = APTS_TestDataUtility.createProduct('Course Literature English', 'COL', 'Option', true, false, false, 'Other',  false, ''); 
            product8.Apts_TI_Pricing__c = TRUE;
            productsList.add(product8);
            System.debug('***TEST CLASS : PRODUCT 8===>'+product8);

            Product2 product9 = APTS_TestDataUtility.createProduct('Course Literature Non English', 'COLN', 'Option', true, false, false, 'Other',  false, '');
            product9.Apts_TI_Pricing__c = TRUE;
            productsList.add(product9);
            System.debug('***TEST CLASS : PRODUCT 9===>'+product9);

            insert productsList;

            System.debug('***TEST CLASS : PRODUCTLIST===>'+productsList);

            //create price dimension
            list<Apttus_Config2__PriceDimension__c> priceDimensionList = new list<Apttus_Config2__PriceDimension__c>();
            Apttus_Config2__PriceDimension__c priceDimension1 = APTS_TestDataUtility.createPriceDimension('Quantity', 'Standard', 'Line Item', 'Apttus_Config2__LineItem__c', 'Apttus_Config2__Quantity__c');
            priceDimensionList.add(priceDimension1);

            Apttus_Config2__PriceDimension__c priceDimension2 = APTS_TestDataUtility.createPriceDimension('Destination Code', 'Standard', 'Line Item', 'Apttus_Config2__LineItem__c', 'DestinationCode__c');
            priceDimensionList.add(priceDimension2);
            insert priceDimensionList;

            //create price list items
            list<Apttus_Config2__PriceListItem__c> priceListItemsList = new list<Apttus_Config2__PriceListItem__c>();
            Apttus_Config2__PriceListItem__c priceListItem1 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product1.Id, 'Standard Price');
            priceListItemsList.add(priceListItem1);
            System.debug('***TEST CLASS : priceListItem1===>'+priceListItem1);
            
            Apttus_Config2__PriceListItem__c priceListItem2 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product2.Id, 'Standard Price');
            priceListItemsList.add(priceListItem2);
            System.debug('***TEST CLASS : priceListItem2===>'+priceListItem2);
            
            Apttus_Config2__PriceListItem__c priceListItem3 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product3.Id, 'Standard Price');
            priceListItemsList.add(priceListItem3);
            System.debug('***TEST CLASS : priceListItem3===>'+priceListItem3);
            
            Apttus_Config2__PriceListItem__c priceListItem4 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product4.Id, 'Standard Price');
            priceListItemsList.add(priceListItem4);
            System.debug('***TEST CLASS : priceListItem4===>'+priceListItem4);

            Apttus_Config2__PriceListItem__c priceListItem5 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product5.Id, 'Standard Price');
            priceListItemsList.add(priceListItem5);
            System.debug('***TEST CLASS : priceListItem5===>'+priceListItem5);
            
            Apttus_Config2__PriceListItem__c priceListItem6 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, product6.Id, 'Standard Price');
            priceListItemsList.add(priceListItem6);
            System.debug('***TEST CLASS : priceListItem6===>'+priceListItem6);

            Apttus_Config2__PriceListItem__c priceListItem7 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 200, product7.Id, 'Standard Price');
            priceListItemsList.add(priceListItem7);
            System.debug('***TEST CLASS : priceListItem6===>'+priceListItem7);

            Apttus_Config2__PriceListItem__c priceListItem8 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, product8.Id, 'Standard Price');
            priceListItemsList.add(priceListItem8);
            System.debug('***TEST CLASS : priceListItem6===>'+priceListItem8);

            Apttus_Config2__PriceListItem__c priceListItem9 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, product9.Id, 'Standard Price');
            priceListItemsList.add(priceListItem9);
            System.debug('***TEST CLASS : priceListItem6===>'+priceListItem9);

            insert priceListItemsList;
            System.debug('***TEST CLASS : priceListItemsList===>'+priceListItemsList);

            //create price matrix entrt
            list<Apttus_Config2__PriceMatrix__c> prixeMatrixList = new list<Apttus_Config2__PriceMatrix__c>();
            Apttus_Config2__PriceMatrix__c priceMatrix1 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem1.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix1);

            Apttus_Config2__PriceMatrix__c priceMatrix2 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem2.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix2);

            Apttus_Config2__PriceMatrix__c priceMatrix3 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem3.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix3);

            Apttus_Config2__PriceMatrix__c priceMatrix4 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem4.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix4);

            Apttus_Config2__PriceMatrix__c priceMatrix5 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem5.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix5);

            Apttus_Config2__PriceMatrix__c priceMatrix6 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem6.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix6);

            Apttus_Config2__PriceMatrix__c priceMatrix7 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem7.Id, Apttus_Config2__Sequence__c = 1,Apttus_Config2__MatrixType__c = 'Dimension', Apttus_Config2__Dimension1Id__c = priceDimension1.Id, Apttus_Config2__Dimension1ValueType__c = 'Cumulative Range', Apttus_Config2__Dimension2Id__c = priceDimension2.Id, Apttus_Config2__Dimension2ValueType__c = 'Discrete');
            prixeMatrixList.add(priceMatrix7);

            insert prixeMatrixList;

            list<Apttus_Config2__PriceMatrixEntry__c> prixeMatrixEntryList = new list<Apttus_Config2__PriceMatrixEntry__c>();
            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry11 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 495.00, Apttus_Config2__AdjustmentAmount__c = 495.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUC');
            prixeMatrixEntryList.add(priceMatrixEntry11);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry12 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 295.00, Apttus_Config2__AdjustmentAmount__c = 295.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUC');
            prixeMatrixEntryList.add(priceMatrixEntry12);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry21 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix2.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 595.00, Apttus_Config2__AdjustmentAmount__c = 595.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUC');
            prixeMatrixEntryList.add(priceMatrixEntry21);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry22 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix2.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 395.00, Apttus_Config2__AdjustmentAmount__c = 395.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUC');
            prixeMatrixEntryList.add(priceMatrixEntry22);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry31 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix3.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 295.00, Apttus_Config2__AdjustmentAmount__c = 295.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry31);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry32 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix3.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 195.00, Apttus_Config2__AdjustmentAmount__c = 195.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry32);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry41 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix4.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 295.00, Apttus_Config2__AdjustmentAmount__c = 295.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry41);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry42 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix4.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 95.00, Apttus_Config2__AdjustmentAmount__c = 95.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry42);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry51 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix5.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 295.00, Apttus_Config2__AdjustmentAmount__c = 295.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry51);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry52 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix5.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 195.00, Apttus_Config2__AdjustmentAmount__c = 195.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUK');
            prixeMatrixEntryList.add(priceMatrixEntry52);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry61 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix6.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 295.00, Apttus_Config2__AdjustmentAmount__c = 295.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-AUZ');
            prixeMatrixEntryList.add(priceMatrixEntry61);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry62 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix6.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 95.00, Apttus_Config2__AdjustmentAmount__c = 95.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-AUZ');
            prixeMatrixEntryList.add(priceMatrixEntry62);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry71 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix7.Id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__PriceOverride__c = 195.00, Apttus_Config2__AdjustmentAmount__c = 195.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '8', Apttus_Config2__Dimension2Value__c = 'NZ-TRI');
            prixeMatrixEntryList.add(priceMatrixEntry71);

            Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry72 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix7.Id, Apttus_Config2__Sequence__c = 2, Apttus_Config2__PriceOverride__c = 85.00, Apttus_Config2__AdjustmentAmount__c = 85.00, Apttus_Config2__AdjustmentType__c = 'List Price Override', Apttus_Config2__Dimension1Value__c = '99', Apttus_Config2__Dimension2Value__c = 'NZ-TRI');
            prixeMatrixEntryList.add(priceMatrixEntry72);
            insert prixeMatrixEntryList;

            String CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
            Account testAcc = APTS_TestDataUtility.createAccount(CustomerRecTypeId, 'USD', 'BEB', 'EN');
            //testAcc.CurrencyIsoCode = 'EUR';
            //insert testAcc;
            System.debug('***TEST CLASS : testAcc===>'+testAcc);

            //create opportunity
            Opportunity testOpportunity = APTS_TestDataUtility.createOpportunities(testAcc.Id, testUser, 'FRP', 'ILS', 'ILS', 'EUR');
            testOpportunity.Pricebook2ID = stdPricebookId;
            //insert testOpportunity;
            System.debug('***TEST CLASS : testOpportunity===>'+testOpportunity);

            //insert Proposal     
            Apttus_Proposal__Proposal__c testProposal = APTS_TestDataUtility.createProposal('TestProposal', testOpportunity.Id, 'EUR', testAcc.Id, 'Proposal', priceList.id);
            testProposal.Apttus_Proposal__Primary__c = true;
            testProposal.Apttus_Proposal__Approval_Stage__c = 'None';
            //insert testProposal;          
            System.debug('***TEST CLASS : testProposal===>'+testProposal);
            
            test.StopTest();
        }
    }
    
    @isTest static void When_NonCompQuoteWithEngProductCodeQtyisChanged_Expect_QtyUpdateWithEngProduct(){
        test.startTest();
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }               
        }
        
        map<String, Product2> productNameWithRecordMap = new map<String, Product2>();
        for(Product2 productRecord : [select Id,Name,ProductCode,Apts_CoursePricing__c from Product2 order by CreatedDate]){
           productNameWithRecordMap.put(productRecord.Name, productRecord);
        }
        
        update new Product2(Id = productNameWithRecordMap.get('Travel Insurance').Id, Apts_CoursePricing__c = true); 
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c testconfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration.Apttus_Config2__BusinessObjectType__c ='Proposal';
        insert testconfiguration;
        System.debug('***TEST CLASS : configuration===>'+testconfiguration);
        system.assert(testconfiguration.Name == 'APTpS TST Configuration 2');
        
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        
        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_OPTION, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Course Literature English').Id, Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem2);
        
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100,  Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        
        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100,  Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        
        Insert lineItemsList;
        
        system.debug('==Travel Insurance=='+productNameWithRecordMap.get('Travel Insurance').Id);
        
        System.assert(lineItem4.Apttus_Config2__OptionId__c == productNameWithRecordMap.get('Travel Insurance').Id);
        System.assert(lineItem2.Apttus_Config2__OptionId__c == productNameWithRecordMap.get('Course Literature English').Id);
        
        Apttus_Config2__ProductAttributeValue__c productAttribute1 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute1.Apttus_Config2__LineItemId__c = lineItem1.Id;
        productAttribute1.Language__c = System.Label.ProductLanguageEnglish;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute2 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute2.Apttus_Config2__LineItemId__c = lineItem2.Id;
        productAttribute2.Language__c = System.Label.ProductLanguageEnglish;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute3 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute3.Apttus_Config2__LineItemId__c = lineItem3.Id;
        productAttribute3.Language__c = System.Label.ProductLanguageEnglish;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute4 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute4.Apttus_Config2__LineItemId__c = lineItem4.Id;
        productAttribute4.Language__c = System.Label.ProductLanguageEnglish;
        
        Insert new list<Apttus_Config2__ProductAttributeValue__c>{productAttribute1, productAttribute2, productAttribute3, productAttribute4};
        
        lineItem1.Apttus_Config2__AttributeValueId__c = productAttribute1.Id;
        lineItem2.Apttus_Config2__AttributeValueId__c = productAttribute2.Id;
        lineItem3.Apttus_Config2__AttributeValueId__c = productAttribute3.Id;
        lineItem4.Apttus_Config2__AttributeValueId__c = productAttribute4.Id;
        
        Update new list<Apttus_Config2__LineItem__c>{lineItem1, lineItem2, lineItem3, lineItem4};
        
        APTS_EFPricingCallback pcbInstance = new APTS_EFPricingCallback();
        pcbInstance.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
        
        testconfiguration.Apttus_Config2__Status__c = 'Saved';
        update testconfiguration;
        
        system.assert(testconfiguration.Apttus_Config2__Status__c == 'Saved');

        //reprice API
        Apttus_Config2.PricingWebService.updatePriceForCart(testconfiguration.id);
        
        //system.assert(lineItem4.Apttus_Config2__Quantity__c == 13);
        system.debug('=Quntitychanged=='+lineItem1.Apttus_Config2__Quantity__c+'_'+lineItem2.Apttus_Config2__Quantity__c+'_'+lineItem3.Apttus_Config2__Quantity__c+'_'+lineItem4.Apttus_Config2__Quantity__c);
        
        test.StopTest();
    }
    
    @isTest static void When_NonCompQuoteWithNonEngProductCodeQtyisChanged_Expect_QtyUpdateWithNonEngProduct(){
        test.startTest();
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }               
        }
        
        map<String, Product2> productNameWithRecordMap = new map<String, Product2>();
        for(Product2 productRecord : [select Id,Name,ProductCode,Apts_CoursePricing__c from Product2 order by CreatedDate]){
           productNameWithRecordMap.put(productRecord.Name, productRecord);
        }
        
        update new Product2(Id = productNameWithRecordMap.get('Travel Insurance').Id, Apts_CoursePricing__c = true); 
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c testconfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration.Apttus_Config2__BusinessObjectType__c ='Proposal';
        insert testconfiguration;
        System.debug('***TEST CLASS : configuration===>'+testconfiguration);
        system.assert(testconfiguration.Name == 'APTpS TST Configuration 2');
        
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        
        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_OPTION, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Course Literature Non English').Id, Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem2);
        
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100,  Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        
        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100,  Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        
        Insert lineItemsList;
        
        system.debug('==Travel Insurance=='+productNameWithRecordMap.get('Travel Insurance').Id);
        
        System.assert(lineItem4.Apttus_Config2__OptionId__c == productNameWithRecordMap.get('Travel Insurance').Id);
        System.assert(lineItem2.Apttus_Config2__OptionId__c == productNameWithRecordMap.get('Course Literature Non English').Id);
        
        Apttus_Config2__ProductAttributeValue__c productAttribute1 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute1.Apttus_Config2__LineItemId__c = lineItem1.Id;
        productAttribute1.Language__c = 'Spanish' ;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute2 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute2.Apttus_Config2__LineItemId__c = lineItem2.Id;
        productAttribute2.Language__c = 'Spanish' ;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute3 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute3.Apttus_Config2__LineItemId__c = lineItem3.Id;
        productAttribute3.Language__c = 'Spanish' ;
        
        Apttus_Config2__ProductAttributeValue__c productAttribute4 = new Apttus_Config2__ProductAttributeValue__c();     
        productAttribute4.Apttus_Config2__LineItemId__c = lineItem4.Id;
        productAttribute4.Language__c = 'Spanish' ;
        
        Insert new list<Apttus_Config2__ProductAttributeValue__c>{productAttribute1, productAttribute2, productAttribute3, productAttribute4};
        
        lineItem1.Apttus_Config2__AttributeValueId__c = productAttribute1.Id;
        lineItem2.Apttus_Config2__AttributeValueId__c = productAttribute2.Id;
        lineItem3.Apttus_Config2__AttributeValueId__c = productAttribute3.Id;
        lineItem4.Apttus_Config2__AttributeValueId__c = productAttribute4.Id;
        
        Update new list<Apttus_Config2__LineItem__c>{lineItem1, lineItem2, lineItem3, lineItem4};
        
        APTS_EFPricingCallback pcbInstance = new APTS_EFPricingCallback();
        pcbInstance.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
        
        testconfiguration.Apttus_Config2__Status__c = 'Saved';
        update testconfiguration;
        
        system.assert(testconfiguration.Apttus_Config2__Status__c == 'Saved');

        //reprice API
        Apttus_Config2.PricingWebService.updatePriceForCart(testconfiguration.id);
        
        test.StopTest();
    }    
   
    @isTest static void When_QuoteiscomparitiveWithCourcePricing_Expect_PricingWithotherPricematrix(){
        test.startTest();
        
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c, Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c limit 1];
        
        //insert Proposal     
        Apttus_Proposal__Proposal__c testProposal1 = APTS_TestDataUtility.createProposal('TestProposal', testProposal.Apttus_Proposal__Opportunity__c, 'EUR', testProposal.Apttus_Proposal__Account__c, 'Proposal', testProposal.Apttus_QPConfig__PriceListId__c);
        testProposal1.Apttus_Proposal__Primary__c = true;
        testProposal1.Apttus_Proposal__Approval_Stage__c = 'None';
        testProposal1.ComparativeQuote__c = TRUE;
        //insert testProposal1;
        System.debug('***TEST CLASS : testProposal1 ===>'+testProposal1);
        
        testProposal1.ComparativeQuote__c = TRUE;
        
        update testProposal1;
        system.assert(testProposal1.ComparativeQuote__c == true);

        //create product configuration
        Apttus_Config2__ProductConfiguration__c testConfiguration1 = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 1', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal1.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testConfiguration1.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        insert testConfiguration1;
        System.debug('***TEST CLASS : testConfiguration1===>'+testConfiguration1);
            
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }               
        }
        
        list<Product2> productList = new list<Product2>();
        for(Product2 productRecord : [select Id,ProductCode from Product2 order by CreatedDate]){
            productList.add(productRecord);
            system.debug('==productRecord1=='+productRecord);
        }
            
        //create line items
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productList[0].Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        System.debug('***TEST CLASS : lineItem1===>'+lineItem1);
        
        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[1].Id,
            Apttus_Config2__Description__c = 'Users - Dashboard Only Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[1].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 10, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 2, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING);
        lineItemsList.add(lineItem2);
        System.debug('***TEST CLASS : lineItem2===>'+lineItem2);
        
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[2].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price',  Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        System.debug('***TEST CLASS : lineItem3===>'+lineItem3);

        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[3].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[3].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        System.debug('***TEST CLASS : lineItem4===>'+lineItem4);

        Apttus_Config2__LineItem__c lineItem5 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[6].Id, Apttus_Config2__BasePrice__c = 800,  Apttus_Config2__PriceListItemId__c = priceListItemList[6].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[6].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem5);
        System.debug('***TEST CLASS : lineItem5===>'+lineItem5);
        
        insert lineItemsList;
        System.debug('***TEST CLASS : lineItemsList===>'+lineItemsList);

        testConfiguration1.Apttus_Config2__Status__c = 'Saved';
        update testConfiguration1;
        system.assert(testConfiguration1.Apttus_Config2__Status__c == 'Saved');

        //reprice API
        APTS_EFPricingCallback pcbInstance = new APTS_EFPricingCallback();
        Apttus_Config2.PricingWebService.updatePriceForCart(testConfiguration1.id);
        pcbInstance.finish();
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c testconfiguration2 = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 3', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal1.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration2.Apttus_Config2__BusinessObjectType__c ='Proposal';
        insert testconfiguration2;
        System.debug('***TEST CLASS : testConfiguration1===>'+testConfiguration1);
        
        //create line items
        lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productList[0].Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        System.debug('***TEST CLASS : lineItem1===>'+lineItem1);
        
        lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[1].Id,
            Apttus_Config2__Description__c = 'Users - Dashboard Only Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[1].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 10, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 2, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING);
        lineItemsList.add(lineItem2);
        System.debug('***TEST CLASS : lineItem2===>'+lineItem2);
        
        lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[2].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price',  Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        System.debug('***TEST CLASS : lineItem3===>'+lineItem3);

        lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[3].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[3].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        System.debug('***TEST CLASS : lineItem4===>'+lineItem4);

        lineItem5 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[6].Id, Apttus_Config2__BasePrice__c = 800,  Apttus_Config2__PriceListItemId__c = priceListItemList[6].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[6].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 3, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem5);
        System.debug('***TEST CLASS : lineItem5===>'+lineItem5);
        
        insert lineItemsList;
        System.debug('***TEST CLASS : lineItemsList===>'+lineItemsList);

        testconfiguration2.Apttus_Config2__Status__c = 'Saved';
        update testconfiguration2;
        system.assert(testconfiguration2.Apttus_Config2__Status__c == 'Saved');
        
        APTS_EFPricingCallback pcbInstance1 = new APTS_EFPricingCallback();
        //reprice API
        Apttus_Config2.PricingWebService.updatePriceForCart(testconfiguration2.id);
        pcbInstance1.finish();
        
        test.StopTest();
    }
    
    @isTest static void When_QuoteiscomparitiveWithTIPricing_Expect_PricingWithotherPricematrix(){
        test.startTest();
        
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c, Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c limit 1];
        
        //insert Proposal     
        Apttus_Proposal__Proposal__c testProposal1 = APTS_TestDataUtility.createProposal('TestProposal', testProposal.Apttus_Proposal__Opportunity__c, 'EUR', testProposal.Apttus_Proposal__Account__c, 'Proposal', testProposal.Apttus_QPConfig__PriceListId__c);
        testProposal1.Apttus_Proposal__Primary__c = true;
        testProposal1.Apttus_Proposal__Approval_Stage__c = 'None';
        testProposal1.ComparativeQuote__c = TRUE;
        //insert testProposal1;
        System.debug('***TEST CLASS : testProposal1 ===>'+testProposal1);
        
        testProposal1.ComparativeQuote__c = TRUE;
        
        update testProposal1;
        system.assert(testProposal1.ComparativeQuote__c == true);

        //create product configuration
        Apttus_Config2__ProductConfiguration__c testConfiguration1 = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 1', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal1.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testConfiguration1.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        insert testConfiguration1;
        System.debug('***TEST CLASS : testConfiguration1===>'+testConfiguration1);
            
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }               
        }
        
        list<Product2> productList = new list<Product2>();
        map<String, Product2> productNameWithRecordMap = new map<String, Product2>();
        for(Product2 productRecord : [select Id,Name,ProductCode,Apts_CoursePricing__c from Product2 order by CreatedDate]){
            productList.add(productRecord);
            productNameWithRecordMap.put(productRecord.Name, productRecord);
            system.debug('==productRecord1=='+productRecord);
        }
        
        update new Product2(Id = productNameWithRecordMap.get('Travel Insurance').Id, Apts_CoursePricing__c = false); 
        
        //create line items
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productList[0].Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        System.debug('***TEST CLASS : lineItem1===>'+lineItem1);
        
        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[1].Id,
            Apttus_Config2__Description__c = 'Users - Dashboard Only Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[1].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 10, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 2, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING);
        lineItemsList.add(lineItem2);
        System.debug('***TEST CLASS : lineItem2===>'+lineItem2);
        
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[2].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price',  Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        System.debug('***TEST CLASS : lineItem3===>'+lineItem3);

        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[3].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[3].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        System.debug('***TEST CLASS : lineItem4===>'+lineItem4);

        Apttus_Config2__LineItem__c lineItem5 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration1.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[6].Id, Apttus_Config2__BasePrice__c = 800,  Apttus_Config2__PriceListItemId__c = priceListItemList[6].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[6].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem5);
        System.debug('***TEST CLASS : lineItem5===>'+lineItem5);
        
        insert lineItemsList;
        System.debug('***TEST CLASS : lineItemsList===>'+lineItemsList);

        testConfiguration1.Apttus_Config2__Status__c = 'Saved';
        update testConfiguration1;
        system.assert(testConfiguration1.Apttus_Config2__Status__c == 'Saved');

        //reprice API
        APTS_EFPricingCallback pcbInstance = new APTS_EFPricingCallback();
        Apttus_Config2.PricingWebService.updatePriceForCart(testConfiguration1.id);
        pcbInstance.finish();
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c testconfiguration2 = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 3', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal1.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration2.Apttus_Config2__BusinessObjectType__c ='Proposal';
        insert testconfiguration2;
        System.debug('***TEST CLASS : testConfiguration1===>'+testConfiguration1);
        
        //create line items
        lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productList[0].Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        System.debug('***TEST CLASS : lineItem1===>'+lineItem1);
        
        lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[0].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[1].Id,
            Apttus_Config2__Description__c = 'Users - Dashboard Only Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[1].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 10, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 2, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING);
        lineItemsList.add(lineItem2);
        System.debug('***TEST CLASS : lineItem2===>'+lineItem2);
        
        lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[2].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price',  Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        System.debug('***TEST CLASS : lineItem3===>'+lineItem3);

        lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[2].Id, Apttus_Config2__BasePrice__c = 1000,  Apttus_Config2__PriceListItemId__c = priceListItemList[3].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[3].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);
        System.debug('***TEST CLASS : lineItem4===>'+lineItem4);

        lineItem5 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration2.Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = productList[6].Id, Apttus_Config2__BasePrice__c = 800,  Apttus_Config2__PriceListItemId__c = priceListItemList[6].Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productList[6].Id, Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__Quantity__c = 3, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem5);
        System.debug('***TEST CLASS : lineItem5===>'+lineItem5);
        
        insert lineItemsList;
        System.debug('***TEST CLASS : lineItemsList===>'+lineItemsList);

        testconfiguration2.Apttus_Config2__Status__c = 'Saved';
        update testconfiguration2;
        system.assert(testconfiguration2.Apttus_Config2__Status__c == 'Saved');
        
        APTS_EFPricingCallback pcbInstance1 = new APTS_EFPricingCallback();
        //reprice API
        Apttus_Config2.PricingWebService.updatePriceForCart(testconfiguration2.id);
        pcbInstance1.finish();
        
        test.StopTest();
    }

    @isTest static void When_NonCompQuoteWithcurrentThreshHoldNotEqlToQty_Expect_updateCoursePricingOnMatrix(){
        test.startTest();
        
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }               
        }
        
        map<String, Product2> productNameWithRecordMap = new map<String, Product2>();
        for(Product2 productRecord : [select Id,Name,ProductCode,Apts_CoursePricing__c from Product2 order by CreatedDate]){
           productNameWithRecordMap.put(productRecord.Name, productRecord);
        }
        
        //update new Product2(Id = productNameWithRecordMap.get('Travel Insurance').Id, Apts_CoursePricing__c = true); 
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c testconfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration.Apttus_Config2__BusinessObjectType__c ='Proposal';
        insert testconfiguration;
        System.debug('***TEST CLASS : configuration===>'+testconfiguration);
        system.assert(testconfiguration.Name == 'APTpS TST Configuration 2');
        
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        Apttus_Config2__LineItem__c testLineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id, 
            Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        Insert testLineItem;
        
        List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixList = [select Id, Apttus_Config2__AdjustmentAmount__c from Apttus_Config2__PriceMatrixEntry__c];
        
        Map<Id, List<Apttus_Config2__PriceMatrixEntry__c>> lineItemPriceMatrixMap = new Map<Id, List<Apttus_Config2__PriceMatrixEntry__c>> ();
        
        lineItemPriceMatrixMap.put(testLineItem.Id, priceMatrixList);   
        
        Double currentThreshHold = APTS_EFPricingCallbackHelper.updateCoursePricingOnMatrix(testLineItem, double.valueOf(5), lineItemPriceMatrixMap);
        
        Double currentThreshHold1 = APTS_EFPricingCallbackHelper.updateCoursePricingOnMatrix(testLineItem, double.valueOf(1), lineItemPriceMatrixMap);
        
        testLineItem.Apttus_Config2__Quantity__c = 8;
        update testLineItem;
        
        Double currentThreshHold2 = APTS_EFPricingCallbackHelper.updateCoursePricingOnMatrix(testLineItem, double.valueOf(5), lineItemPriceMatrixMap);
        
        test.StopTest();
    }
}