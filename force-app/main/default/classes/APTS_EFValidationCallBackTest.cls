@isTest
private class APTS_EFValidationCallBackTest {
    
    @testSetup static void testDataSetup() {
        Test.startTest();
        //get system admin profile
        Profile systemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        //insert User
        User adminUser = APTS_TestDataUtility.createUser(systemAdminProfile.Id);
        System.runAs(adminUser) {           
            
            Account testAccount = APTS_CPQTestUtility.createAccount('test apttus account', 'Enterprise');
            //populate custom fields value if required
            insert testAccount;
            system.assert(testAccount.Name == 'test apttus account');
            
            Contact testContact = APTS_CPQTestUtility.createContact('Apttus', testAccount.Id);
            //populate custom fields value if required
            insert testContact;
            system.assert(testContact.Id != null);
            
            Opportunity testOpportunity = APTS_CPQTestUtility.createOpportunity('test Apttus Opportunity', 'New Customer', testAccount.Id, 'Propose');
            //populate custom fields value if required
            insert testOpportunity;
            system.assert(testOpportunity.Name == 'test Apttus Opportunity');
            
            Apttus_Config2__PriceList__c testPriceList = APTS_CPQTestUtility.createPriceList('test Apttus Price List', true);
            //populate custom fields value if required
            insert testPriceList;
            system.assert(testPriceList.Name == 'test Apttus Price List');
            
            Product2 testProduct = APTS_CPQTestUtility.createProduct('test Apttus Product', 'APTS', 'Apttus', 'Bundle', true, true, true, true);
            //populate custom fields value if required
            insert testProduct;
            system.assert(testProduct.Name == 'test Apttus Product');
            
            PricebookEntry testPBE = APTS_CPQTestUtility.createPricebookEntry(Test.getStandardPricebookId(), testProduct.Id, 100, true);
            //populate custom fields value if required
            insert testPBE;
            system.assert(testPBE.Id != null);
            
            Apttus_Config2__PriceListItem__c testPriceListItem = APTS_CPQTestUtility.createPriceListItem(testPriceList.Id, testProduct.Id, 100, 'Standard Price', 'One Time', 'Per Unit', 'Each', true);
            //populate custom fields value if required
            insert testPriceListItem;
            system.assert(testPriceListItem.Id != null);
            
            Apttus_Proposal__Proposal__c testProposal = APTS_CPQTestUtility.createProposal('test Apttus Proposal', testAccount.Id, testOpportunity.Id, 'Proposal', testPriceList.Id);
            testProposal.Product__c = 'ILS';
            testProposal.Market__c = 'DEB';
            //populate custom fields value if required
            insert testProposal;
            system.assert(testProposal.Id != null);
            
            //create product configuration
            Apttus_Config2__ProductConfiguration__c testProductConfiguration = APTS_CPQTestUtility.createConfiguration('APTTUS Test Config', testAccount.Id, testPriceList.Id, testProposal.Id);            
            insert testProductConfiguration;            
            system.assert(testProductConfiguration != null);
            
            Apttus_Config2__ClassificationName__c testClassification = APTS_CPQTestUtility.createCategory('test Apttus Classification', 'test Hiearchy Label', 'Apttus', null, true);
            //populate custom fields value if required
            insert testClassification;
            system.assert(testClassification.Name == 'test Apttus Classification');
            
            Apttus_Config2__ClassificationHierarchy__c testClassificationHierarchy = APTS_CPQTestUtility.createClassificationHierarchy(testClassification.Id, 'Classification Hierarchy Label');
            //populate custom fields value if required
            insert testClassificationHierarchy;
            system.assert(testClassificationHierarchy.Id != null);
            
            Apttus_Config2__ProductOptionComponent__c testProductOptionComponent = APTS_CPQTestUtility.createProductOptionComponent(1);
            //populate custom fields value if required
            insert testProductOptionComponent;
            system.assert(testProductOptionComponent.Id != null);
            
            Apttus_Config2__SummaryGroup__c testSummaryGroup = APTS_CPQTestUtility.createSummaryGroup(testProductConfiguration.Id, 1, 1);
            //populate custom fields value if required
            testSummaryGroup.Apttus_Config2__LineType__c = System.Label.ValidateCartGrandTotal;
            testSummaryGroup.Apttus_Config2__NetAdjustmentPercent__c = 5;
            testSummaryGroup.Apttus_Config2__ExtendedRollupPrice__c = 5;
            insert testSummaryGroup;
            system.assert(testSummaryGroup.Id != null);
            
            APTS_CPQTestUtility.createLineItem(testProductConfiguration.Id, testProduct.Id, 1);
            list<Apttus_Config2__LineItem__c> listLineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = : testProductConfiguration.Id];
            system.assert(listLineItem != null);
            
            test.StopTest();
        }
    }
    
    @isTest static void checkPriceOverrideEditable_Expect_ValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> allLineItemsToUpdateLIst = new List<Apttus_Config2__LineItem__c>();
        allLineItems = [select Id, Apttus_Config2__ConfigurationId__c, Apttus_Config2__PricingStatus__c from Apttus_Config2__LineItem__c];      
        
        allLineItemsToUpdateLIst.add(new Apttus_Config2__LineItem__c(Id = allLineItems[0].Id, Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride));
        
        update allLineItemsToUpdateLIst;
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
        Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());
        
        Test.stopTest();
    }
    
    @isTest static void checkQuantityDestionationAccomodation_Expect_ValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        
        List<Product2> productList = new List<Product2>();
        
        Product2 productRecord1 = new Product2(
            Name = 'Auckland',
            ProductCode = 'NZ-AUC',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Bundle',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            APTS_Destination_Location__c = 'Southern Hemisphere',
            Apttus_Config2__ProductType__c = 'Destination',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = false);
        
        productList.add(productRecord1);
        
        Product2 productRecord2 = new Product2(
            Name = 'Junior Course',
            ProductCode = 'JU',
            IsActive = true,
            Family = 'Junior Course',
            Apttus_Config2__ConfigurationType__c = 'Option',
            Apttus_Config2__Customizable__c = false,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = false,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Week',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Course',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = true);
        
        productList.add(productRecord2);
        
        Product2 productRecord3 = new Product2(
            Name = 'Auckland',
            ProductCode = 'FTEFX',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Bundle',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            APTS_Destination_Location__c = 'Southern Hemisphere',
            Apttus_Config2__ProductType__c = 'Destination',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false);
        
        productList.add(productRecord3);
        
        insert productList;
        
        //Create Product Gorup
        Apttus_Config2__ProductGroup__c productgroup = new Apttus_Config2__ProductGroup__c(
            Name = 'Northern Hemisphere',
            Apttus_Config2__Description__c = 'Used for the Season Supplement',
            Apttus_Config2__GroupType__c = 'Standard');
        insert productgroup;
        
        //Create Product Group Member
        Apttus_Config2__ProductGroupMember__c productgroupmember = new Apttus_Config2__ProductGroupMember__c(
            Apttus_Config2__ProductId__c = productRecord3.Id,
            Apttus_Config2__ProductGroupId__c = productgroup.Id,
            Apttus_Config2__Sequence__c = 18.0);
        insert productgroupmember;
        
        //Create PriceList
        Apttus_Config2__PriceList__c priceListRecord = new Apttus_Config2__PriceList__c(
            Name = 'Commercial Price List',
            Apttus_Config2__Active__c = True,
            Version__c = 'V1',
            Year__c = '2017'
        );
        
        insert priceListRecord;
        
        //create price list items
        List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price'
        );
        
        plistItems.add(pLI1);
        
        Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Subscription Fee'
        );
        
        plistItems.add(pLI2);
        
        insert plistItems;
        
        //Create Departure Point
        Departure_Point__c departurePoint = new Departure_Point__c(
            Name = 'Paris',
            Code__c = 'PAR1',
            APTS_Default_Unique_Identifier__c = 'BangkokTHBBKKAPP11',
            Market__c = 'FRP',
            Product__c = 'ILS',
            Active__c = true);
        insert departurePoint;
        
        Apttus_Config2__ProductConfiguration__c testProductConfiguration = new Apttus_Config2__ProductConfiguration__c();
        testProductConfiguration = [select Id from Apttus_Config2__ProductConfiguration__c  where Name = 'APTTUS Test Config'];
        //Create Line Items
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c LineItem1 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfiguration.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Subscription Fee',
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__PriceListItemId__c = pLI1.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'added by code',
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            Apttus_Config2__OptionId__c = productRecord1.Id,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation
        );
        
        allLineItems.add(LineItem1);
        
        Apttus_Config2__LineItem__c LineItem2 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfiguration.Id,
            Apttus_Config2__OptionId__c = productRecord2.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 2,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 2,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 4,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Product_Subtype__c = System.Label.ProductSubTypeHostFamily
        );
        allLineItems.add(LineItem2);
        
        Apttus_Config2__LineItem__c LineItem3 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfiguration.Id,
            Apttus_Config2__OptionId__c = productRecord3.Id,
            Apttus_Config2__ItemSequence__c =1,
            Apttus_Config2__LineNumber__c = 3,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c ='Upgraded',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'License Fee',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'Upgraded', //'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 5,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 3,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 6,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Product_Subtype__c = System.Label.ProductSubTypeHotel,
            Apttus_Config2__StartDate__c = System.today().addDays(22)
        );
        
        allLineItems.add(LineItem3);
        
        Apttus_Config2__LineItem__c LineItem4 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfiguration.Id,
            Apttus_Config2__ItemSequence__c=1,
            Apttus_Config2__LineNumber__c = 4,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='Upgraded',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord2.Id,
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'Upgraded', //'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 4,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__EndDate__c = System.today() + 8,
            Apttus_Config2__StartDate__c = System.today(),
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Product_Subtype__c = System.Label.ProductSubTypeResidence
        );
        
        allLineItems.add(LineItem4);
        
        for(Apttus_Config2__LineItem__c lineItemRecord : allLineItems){
            lineItemRecord.Apttus_Config2__PricingStatus__c = 'Pending';
        }
        
        insert allLineItems;
        
        list<Apttus_Config2__ProductAttributeValue__c> productattributevalueList = new list<Apttus_Config2__ProductAttributeValue__c>();
        
        Apttus_Config2__ProductAttributeValue__c productattributevalue2 = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__IsTransient__c = false,
            /**APTS_SpecialDiet__c = false,**/
            Country__c = System.Label.ProductCountryUK,
            Apttus_Config2__LineItemId__c = LineItem2.Id);
        productattributevalueList.add(productattributevalue2);
        
        Apttus_Config2__ProductAttributeValue__c productattributevalue3 = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__IsTransient__c = false,
            /**APTS_SpecialDiet__c = false,**/
            Country__c = System.Label.ProductCountryUK,
            Apttus_Config2__LineItemId__c = LineItem3.Id);
        productattributevalueList.add(productattributevalue3);
        
        Apttus_Config2__ProductAttributeValue__c productattributevalue4 = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__IsTransient__c = false,
            /**APTS_SpecialDiet__c = false,**/
            Country__c = System.Label.ProductCountryUK,
            Apttus_Config2__LineItemId__c = LineItem4.Id);
        productattributevalueList.add(productattributevalue4);
        
        insert productattributevalueList;       
        
        
        LineItem2.Apttus_Config2__AttributeValueId__c = productattributevalue2.Id;        
        LineItem3.Apttus_Config2__AttributeValueId__c = productattributevalue3.Id;
        LineItem4.Apttus_Config2__AttributeValueId__c = productattributevalue4.Id;
        
        update allLineItems;
        
        for(Apttus_Config2__ProductAttributeValue__c attributeValue : productattributevalueList){
            attributeValue.Country__c = System.Label.ProductCountryUK;
        }
        
        update productattributevalueList;
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
        Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());
        
        Test.stopTest();
    }
    
    @isTest static void validateCartTotalDiscountValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> allLineItemsToUpdateLIst = new List<Apttus_Config2__LineItem__c>();
        allLineItems = [select Id, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__LineNumber__c from Apttus_Config2__LineItem__c];
        
        allLineItemsToUpdateLIst.add(new Apttus_Config2__LineItem__c(Id = allLineItems[0].Id, Apttus_Config2__LineType__c = System.Label.ProposalLineItemTypeOption, Apttus_Config2__NetPrice__c = 10, Apttus_Config2__BaseExtendedPrice__c  = 40));
        
        update allLineItemsToUpdateLIst;
        
        update new Apttus_Proposal__Proposal__c(Id = allLineItems[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, ComparativeQuote__c = true);
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
        
        Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());        
        
        Test.stopTest();
    }
    
    @isTest static void validateCartByDestinationandTotalCourceWeekforCourceWeekGreaterthan12_Expect_ValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        
        Apttus_Config2__ProductConfiguration__c testProductConfigurationRecord = [select Id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c limit 1];
        
        List<Product2> productList = new List<Product2>();
        
        Product2 productRecord1 = new Product2(
            Name = 'Brisbane',
            ProductCode = 'AU-BRS',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Bundle',
            Apttus_Config2__Customizable__c = false,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Week',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Course',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = true);
        
        productList.add(productRecord1);
        
        Product2 productRecord2 = new Product2(
            Name = 'Australia Overseas Health Cover',
            ProductCode = 'OSHC',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Option',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Insurance',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = false);
        
        productList.add(productRecord2);
        
        
        insert productList;
        
        //Create PriceList
        Apttus_Config2__PriceList__c priceListRecord = new Apttus_Config2__PriceList__c(
            Name = 'Commercial Price List',
            Apttus_Config2__Active__c = True,
            Version__c = 'V1',
            Year__c = '2017'
        );
        
        insert priceListRecord;
        
        //create price list items
        List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price'
        );
        
        plistItems.add(pLI1);
        
        Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Subscription Fee'
        );
        
        plistItems.add(pLI2);
        
        insert plistItems;
        
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c LineItem1 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Subscription Fee',
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__PriceListItemId__c = pLI1.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__Quantity__c = 14,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'added by code',
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            //Apttus_Config2__OptionId__c = productRecord1.Id,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Apttus_Config2__NetPrice__c = 50
        );
        
        allLineItems.add(LineItem1);
        
        Apttus_Config2__LineItem__c LineItem2 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__OptionId__c = productRecord2.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c = 'New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 14,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 2,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 4,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = 'Course',
            Product_Subtype__c = System.Label.ProductSubTypeHostFamily,
            Apttus_Config2__NetPrice__c = 60
        );
        allLineItems.add(LineItem2);
        
        insert allLineItems;
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
        Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());        
        
        Test.stopTest();
    }
    
    @isTest static void validateCartByDestinationandTotalCourceWeekforQtyGreaterthan12_Expect_ValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        
        Apttus_Config2__ProductConfiguration__c testProductConfigurationRecord = [select Id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c limit 1];
        
        List<Product2> productList = new List<Product2>();
        
        Product2 productRecord1 = new Product2(
            Name = 'Brisbane',
            ProductCode = 'AU-BRS',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Bundle',
            Apttus_Config2__Customizable__c = false,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Week',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Course',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = true);
        
        productList.add(productRecord1);
        
        Product2 productRecord2 = new Product2(
            Name = 'Australia Overseas Health Cover',
            ProductCode = 'OSHC',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Option',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Insurance',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = false);
        
        productList.add(productRecord2);
        
        
        insert productList;
        
        //Create PriceList
        Apttus_Config2__PriceList__c priceListRecord = new Apttus_Config2__PriceList__c(
            Name = 'Commercial Price List',
            Apttus_Config2__Active__c = True,
            Version__c = 'V1',
            Year__c = '2017'
        );
        
        insert priceListRecord;
        
        //create price list items
        List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price'
        );
        
        plistItems.add(pLI1);
        
        Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Subscription Fee'
        );
        
        plistItems.add(pLI2);
        
        insert plistItems;
        
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c LineItem1 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Subscription Fee',
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__PriceListItemId__c = pLI1.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__Quantity__c = 14,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'added by code',
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            //Apttus_Config2__OptionId__c = productRecord1.Id,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Apttus_Config2__NetPrice__c = 50
        );
        
        allLineItems.add(LineItem1);
        
        Apttus_Config2__LineItem__c LineItem2 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__OptionId__c = productRecord2.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c = 'New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 14,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 2,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 4,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = 'Course',
            Product_Subtype__c = System.Label.ProductSubTypeHostFamily,
            Apttus_Config2__NetPrice__c = 60
        );
        allLineItems.add(LineItem2);
        
        insert allLineItems;
        
        update new Apttus_Proposal__Proposal__c(Id = testProductConfigurationRecord.Apttus_QPConfig__Proposald__c, ComparativeQuote__c = true);
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
        Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());
        
        Test.stopTest();
    }
    
    @isTest static void validateCartByDestinationandStartDate_Expect_ValidationMessage() {
        test.startTest();
        
        PageReference pref = Page.Apttus_Config2__CartDetailView;
        Test.setCurrentPage(pref);
        
        Apttus_Config2__ProductConfiguration__c testProductConfigurationRecord = [select Id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c limit 1];
        
        update new Apttus_Proposal__Proposal__c(Id = testProductConfigurationRecord.Apttus_QPConfig__Proposald__c, Market__c = 'DEB', Product__c = 'ILS');
        
        //Create Departure Point
        Departure_Point__c departurePoint = new Departure_Point__c(
            Name = 'Paris',
            Code__c = 'PAR1',
            APTS_Default_Unique_Identifier__c = 'DDP TEST LisaDEBTESTILS',
            Market__c = 'DEB',
            Product__c = 'ILS',
            Active__c = true);
        insert departurePoint;
        
        update new Apttus_Proposal__Proposal__c(Id = testProductConfigurationRecord.Apttus_QPConfig__Proposald__c, APTS_Departure_Point__c = departurePoint.id);
        
        List<Product2> productList = new List<Product2>();
        
        Product2 productRecord1 = new Product2(
            Name = 'Auckland',
            ProductCode = 'NZ-AUC',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Bundle',
            Apttus_Config2__Customizable__c = false,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Week',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = 'Destination',
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = true);
        
        productList.add(productRecord1);
        
        Product2 productRecord2 = new Product2(
            Name = 'Flight Booked by EF (Fixed Fare)',
            ProductCode = 'FTEFX',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Option',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = System.Label.ProductTypeAccommodation,
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = false);
        
        productList.add(productRecord2);
        
        Product2 productRecord3 = new Product2(
            Name = 'Flight Booked by EF (Fixed Fare)',
            ProductCode = 'FTEFX',
            IsActive = true,
            Family = 'Destination',
            Apttus_Config2__ConfigurationType__c = 'Option',
            Apttus_Config2__Customizable__c = true,
            Apttus_Config2__ExcludeFromSitemap__c = false,
            Apttus_Config2__HasAttributes__c = true,
            Apttus_Config2__HasDefaults__c = false,
            Apttus_Config2__HasOptions__c = true,
            Apttus_Config2__HasSearchAttributes__c = false,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.0,
            Apttus_Config2__ProductType__c = System.Label.ProductTypeAccommodation,
            APTS_Is_Optional__c = false,
            APTS_PriceOverrideAllowed__c = false,
            EnableStartDateEndDate__c = true,
            Apts_TI_Pricing__c = false,
            Apts_CoursePricing__c = false);
        
        productList.add(productRecord3);
        
        
        insert productList;
        
        //Create Product Gorup
        Apttus_Config2__ProductGroup__c productgroup = new Apttus_Config2__ProductGroup__c(
            Name = 'Northern Hemisphere',
            Apttus_Config2__Description__c = 'Used for the Season Supplement',
            Apttus_Config2__GroupType__c = 'Standard');
        insert productgroup;
        
        //Create Product Group Member
        Apttus_Config2__ProductGroupMember__c productgroupmember = new Apttus_Config2__ProductGroupMember__c(
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ProductGroupId__c = productgroup.Id,
            Apttus_Config2__Sequence__c = 18.0);
        insert productgroupmember;
        
        //Create PriceList
        Apttus_Config2__PriceList__c priceListRecord = new Apttus_Config2__PriceList__c(
            Name = 'Commercial Price List',
            Apttus_Config2__Active__c = True,
            Version__c = 'V1',
            Year__c = '2017'
        );
        
        insert priceListRecord;
        
        //create price list items
        List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Standard Price'
        );
        
        plistItems.add(pLI1);
        
        Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__PriceListId__c = priceListRecord.Id,
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__ChargeType__c = 'Subscription Fee'
        );
        
        plistItems.add(pLI2);
        
        insert plistItems;
        
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c LineItem1 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c='New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Subscription Fee',
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__PriceListItemId__c = pLI1.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 100,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'added by code',
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            //Apttus_Config2__OptionId__c = productRecord1.Id,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Apttus_Config2__NetPrice__c = 50
        );
        
        allLineItems.add(LineItem1);
        
        Apttus_Config2__LineItem__c LineItem2 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__OptionId__c = productRecord2.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c = 'New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 2,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 4,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Product_Subtype__c = System.Label.ProductSubTypeHostFamily,
            Apttus_Config2__NetPrice__c = 60,
            Apttus_Config2__Description__c = 'Flight Booked by EF (Fixed Fare)',
            Apttus_Config2__StartDate__c = System.today() + 2
        );
        allLineItems.add(LineItem2);
        
        Apttus_Config2__LineItem__c LineItem3 = new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = testProductConfigurationRecord.Id,
            Apttus_Config2__OptionId__c = productRecord3.Id,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__IsPrimaryLine__c = True,
            Apttus_Config2__LineStatus__c = 'New',
            Apttus_Config2__PriceListId__c = priceListRecord.id,
            //Apttus_Config2__ChargeType__c = 'Standard Type',
            Apttus_Config2__ChargeType__c = 'Usage',
            Apttus_Config2__ProductId__c = productRecord1.Id,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__PriceListItemId__c = pLI2.id,
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Frequency__c = 'One Time',
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__ListPrice__c = 200,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 2,
            //Apttus_Config2__ShipToAccountId__c = billToAccountRecord.id,
            Apttus_Config2__AddedBy__c = 'xyz',
            Apttus_Config2__EndDate__c = System.today() + 4,
            //Apttus_Config2__AdjustmentType__c = System.Label.ProductAdjustmentPriceOverride,
            APTS_Product_Type__c = System.Label.ProductTypeAccommodation,
            Product_Subtype__c = System.Label.ProductSubTypeHostFamily,
            Apttus_Config2__NetPrice__c = 60,
            Apttus_Config2__Description__c = 'Flight Booked by EF (Fixed Fare)',
            Apttus_Config2__StartDate__c = System.today() + 1
        );
        allLineItems.add(LineItem3);
        
        insert allLineItems;
        
        Apttus_Config2.CustomClass.ValidationResult vResult = Apttus_Config2.CPQWebService.validateCart(allLineItems[0].Apttus_Config2__ConfigurationId__c);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        mapValues.put('pageAction', System.Label.ValidateCartActionFinalize);
        
       Apttus_Config2.CallbackTester.testValidationCallback(allLineItems[0].Apttus_Config2__ConfigurationId__c, allLineItems, null, new APTS_EFValidationCallBack());
       
        Test.stopTest();
    }
}