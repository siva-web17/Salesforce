/**
* Created by saiharish.r on 12/1/2017.
*/

@isTest
private class ProductAttributeValueTriggerTest {
    
    @testSetup static void testDataSetup() {
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        //insert User
        User testUser = APTS_TestDataUtility.createUser(SystemAdminProfile.ID);
        System.runAs(testUser) {
            //Get Standard Price Book Id
            Id stdPriceBookId = Test.getStandardPricebookId();
            
            //Create Product
            list<Product2> productsList = new list<Product2>();
            string configurationType_Bundle = SObjectType.Product2.Fields.Apttus_Config2__ConfigurationType__c.PicklistValues[1].getValue();
            string configurationType_Option = SObjectType.Product2.Fields.Apttus_Config2__ConfigurationType__c.PicklistValues[2].getValue();
            string productTypeDestination = SObjectType.Product2.Fields.Apttus_Config2__ProductType__c.PicklistValues[1].getValue();
            string productTypeCourse = SObjectType.Product2.Fields.Apttus_Config2__ProductType__c.PicklistValues[6].getValue();
            string productDestinationLocation = SObjectType.Product2.Fields.APTS_Destination_Location__c.PicklistValues[0].getValue();
            
            Product2 product = APTS_TestDataUtility.createProduct('Auckland 1', 'NZ-AUC', configurationType_Bundle, true, true, true, productTypeDestination,false,productDestinationLocation);
            //product1.ProductSubtype__c = APTS_Constants.PRODUCT_SUB_TYPE_Season_Supplements;
            productsList.add(product);
            Product2 optionProduct = APTS_TestDataUtility.createProduct('Intensive Course', 'NZ-AUC', configurationType_Option, true, false, false, productTypeCourse, true,productDestinationLocation);
            productsList.add(optionProduct);
            insert productsList;
           
            //create Account
            String CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
            string currencyCode = SObjectType.Account.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            string marketCode = SObjectType.Account.Fields.Market__c.PicklistValues[0].getValue();
            string language = SObjectType.Account.Fields.Language__c.PicklistValues[0].getValue();
            Account testAccount = APTS_TestDataUtility.createAccount(CustomerRecTypeId, currencyCode, marketCode, language);
           
            //create opportunity
            string opportunityMarketCode = SObjectType.Opportunity.Fields.Market__c.PicklistValues[0].getValue();
            string opportunityProgramCode = SObjectType.Opportunity.Fields.Program__c.PicklistValues[0].getValue();
            string opportunityProductCode = SObjectType.Opportunity.Fields.Product__c.PicklistValues[0].getValue();
            string opportunityCurrencyCode = SObjectType.Opportunity.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            Opportunity testOpportunity = APTS_TestDataUtility.createOpportunities(testAccount.Id, testUser, opportunityMarketCode, opportunityProgramCode, opportunityProductCode, opportunityCurrencyCode);
            testOpportunity.Pricebook2ID = stdPricebookId;

            //create Destination
            Destination__c destination = APTS_TestDataUtility.createDestination('NZ-AUC', 'English');            
            insert Destination;
            
            //create price list
            string priceListMarketCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Market__c.PicklistValues[0].getValue();
            string programCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Program__c.PicklistValues[0].getValue();
            string priceListCurrencyCode = SObjectType.Apttus_Config2__PriceList__c.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            Apttus_Config2__PriceList__c priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', priceListMarketCode, programCode, priceListCurrencyCode);
 
            //create Apttus PriceListItemprice list items
            string priceListItemchargeType = SObjectType.Apttus_Config2__PriceListItem__c.Fields.Apttus_Config2__ChargeType__c.PicklistValues[0].getValue();
            Apttus_Config2__PriceListItem__c priceListItem = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, optionProduct.Id, priceListItemchargeType);
            insert priceListItem;
            
            //insert Proposal
            Apttus_Proposal__Proposal__c TestProp = APTS_TestDataUtility.createProposal('TestProposal', testOpportunity.Id, 'EUR', testAccount.Id,'Proposal',priceList.id);
            TestProp.Apttus_Proposal__Primary__c=true;
            TestProp.Apttus_Proposal__Approval_Stage__c='None';

            //create product configuration
            string bussinessObjectType = SObjectType.Apttus_Config2__ProductConfiguration__c.Fields.Apttus_Config2__BusinessObjectType__c.PicklistValues[1].getValue();
            Apttus_Config2__ProductConfiguration__c configuration1 = APTS_TestDataUtility.createApttus_ProductConfiguration(testAccount.Id, priceList.Id, TestProp.Id, bussinessObjectType);
            insert configuration1;
        }
    }
    
    @isTest static void When_DestinationCodeOfProductAttributeValue_IsMatchingWith_DestinationCodeOfDestinationObject() {
        
        Test.startTest();
        
        //create LineItemList
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        List<Product2> productListQuery = [SELECT Id,Name FROM Product2];
        list<Apttus_Config2__PriceListItem__c> priceListItemsQuery = [SELECT Id,Name FROM Apttus_Config2__PriceListItem__c];
        Apttus_Config2__ProductConfiguration__c configurationQuery = [SELECT Id,Name FROM Apttus_Config2__ProductConfiguration__c configuration1];
        Apttus_Config2__PriceList__c priceListQuery = [SELECT Id,Name FROM Apttus_Config2__PriceList__c priceList];
        string productUom = SObjectType.Apttus_Config2__LineItem__c.Fields.Apttus_Config2__Uom__c.PicklistValues[0].getValue();
        string chargeType = SObjectType.Apttus_Config2__LineItem__c.Fields.Apttus_Config2__ChargeType__c.PicklistValues[0].getValue();

        Apttus_Config2__LineItem__c lineItem2 = APTS_TestDataUtility.createApttus_LineItem(configurationQuery.Id, productListQuery[0].Id,  priceListItemsQuery[0].Id, priceListQuery.Id, productListQuery[1].Id, productUom, chargeType);
        lineItemsList.add(lineItem2);
        insert lineItemsList;
 
        //create Product Attribute Value
        Apttus_Config2__ProductAttributeValue__c ApttusProductValue = APTS_TestDataUtility.createApttus_ProductAttributeValue(lineItem2.Id, 'Hasting Host Family');
        insert ApttusProductValue;
    
        Destination__c destinationQuery = [SELECT Id,Name,DestinationCode__c,Language__c 
                                           FROM Destination__c 
                                           LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c productAttributeValueQuery = [SELECT Id,Name,APTS_DestinationCode__c
                                                                               FROM Apttus_Config2__ProductAttributeValue__c
                                                                               LIMIT 1];
        system.assertEquals(productAttributeValueQuery.APTS_DestinationCode__c , destinationQuery.DestinationCode__c);

        
        ProductAttributeValueHelper.updateStartDateEndDateAndQty(ApttusProductValue.id, configurationQuery.Id  , system.today(), system.today()+1, 12.0);
 
        Test.stopTest();
    }
    
    @isTest static void When_DestinationCodeOfProductAttributeValue_IsNotMatchingWith_DestinationCodeOfDestinationObject() {
        
        Test.startTest();
        
        //create LineItemlist
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__PriceListItem__c> priceListItemsQuery = [SELECT Id,Name FROM Apttus_Config2__PriceListItem__c];
        Apttus_Config2__ProductConfiguration__c configurationQuery = [SELECT Id,Name FROM Apttus_Config2__ProductConfiguration__c configuration1];
        Apttus_Config2__PriceList__c priceListQuery = [SELECT Id,Name FROM Apttus_Config2__PriceList__c priceList];
        string productUom = SObjectType.Apttus_Config2__LineItem__c.Fields.Apttus_Config2__Uom__c.PicklistValues[0].getValue();
        string chargeType = SObjectType.Apttus_Config2__LineItem__c.Fields.Apttus_Config2__ChargeType__c.PicklistValues[0].getValue();
        Apttus_Config2__LineItem__c lineItem2 = APTS_TestDataUtility.createApttus_LineItem(configurationQuery.Id, null,  priceListItemsQuery[0].Id, priceListQuery.Id, null, productUom, chargeType);
        lineItemsList.add(lineItem2);
        insert lineItemsList;

        //create Product Attribute Value
        Apttus_Config2__ProductAttributeValue__c ApttusProductValue = APTS_TestDataUtility.createApttus_ProductAttributeValue(lineItem2.Id, 'Hasting Host Family');
        insert ApttusProductValue;

        Destination__c destinationQuery = [SELECT Id,Name,DestinationCode__c,Language__c 
                                           FROM Destination__c 
                                           LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c productAttributeValueQuery = [SELECT Id,Name,APTS_DestinationCode__c
                                                                               FROM Apttus_Config2__ProductAttributeValue__c
                                                                               LIMIT 1];
        system.assertNotEquals(productAttributeValueQuery.APTS_DestinationCode__c , destinationQuery.DestinationCode__c);
        
        //To Execute Catch
        ProductAttributeValueHelper.updateProductAttributeValueBeforeInsert(null);
        
        Test.stopTest();
    }
}