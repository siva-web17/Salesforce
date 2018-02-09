/*******************************************************************************************************************************************
* @author        Karan Khatri
* @date          25/11/2016        
* @description   This class creates test data for test classes.
*******************************************************************************************************************************************/
@isTest
public class APTS_TestDataUtility {


    //Method to fetch profile
    public static Profile getProfile(String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :ProfileName limit 1];
        return profile;
    }

    //creating user
    public static User createUser(Id profileId) {

        User objUser = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'ISO-8859-1', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = profileId,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'APTS_EFTestUser@gmail.com');
        insert objUser ;
        system.assertNotEquals(null, objUser.Id);
        system.debug('User Inserted!!!!!!!');
        return objUser ;
    }

    public static User getTestUser(String UserName) {
        return [SELECT Id, IsActive FROM User WHERE username = :UserName];
    }

    public static Account getTestAccount(String Name) {
        return [SELECT Id, CurrencyIsoCode, Language__c, Market__c FROM Account WHERE name = :Name];
    }

    public static Apttus_Proposal__Proposal__c getTestQuote(Id quoteId) {
        String query = 'SELECT ';
        String whereclause = '';
        for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.StaticTextTranslationFieldSet.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Apttus_Proposal__Opportunity__c , CurrencyIsoCode,Apttus_Proposal__Proposal_Name__c, Market__c,Program__c,Product__c ,Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c ' ;
        whereclause = ' where Id = :quoteId';
        return Database.query(query);
    }

    public static Apttus_Proposal__Proposal__c getTestQuoteByName(String quoteName) {
        String query = 'SELECT ';
        String whereclause = '';
        for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.StaticTextTranslationFieldSet.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Apttus_Proposal__Opportunity__c , CurrencyIsoCode,Apttus_Proposal__Proposal_Name__c, Market__c,Program__c,Product__c ,Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c ' ;
        whereclause = ' where Name = :quoteName';
        return Database.query(query);
    }

    public static Opportunity getTestOpportunity(String Name) {
        return [SELECT Id, CurrencyIsoCode, Market__c,Product__c,Program__c FROM Opportunity WHERE name = :Name];
    }

    //Create Quote/Proposal record
    public static Apttus_Proposal__Proposal__c createProposal(String propName, Id oppId, String currcode, Id accId, String QuoteType, ID priceListId) {
        ID QuoteRecTypeId;
        if (QuoteType == 'Proposal') {
            QuoteRecTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
        }
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c(
                Apttus_Proposal__Proposal_Name__c = propName,
                Apttus_Proposal__Opportunity__c = oppId,
                RecordTypeId = QuoteRecTypeId,
                Apttus_QPConfig__PriceListId__c = priceListId,
                Apttus_Proposal__Primary__c = true,
                Apttus_Proposal__Approval_Stage__c = 'None',
                Apttus_Proposal__Account__c = accId);
        insert prop;
        return prop;
    }

    //Create Quote/Proposal record
    public static Apttus_Proposal__Proposal__c createProposalWithoutPriceList(String propName, Id oppId, String currcode, Id accId, String QuoteType, String marketCode, String programCode) {
        ID QuoteRecTypeId;
        if (QuoteType == 'Proposal') {
            QuoteRecTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
        }
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c(
                Apttus_Proposal__Proposal_Name__c = propName,
                Apttus_Proposal__Opportunity__c = oppId,
                RecordTypeId = QuoteRecTypeId,
                CurrencyIsoCode = currcode,
                Market__c = marketCode,
                program__c = programCode,
                Apttus_Proposal__Primary__c = true,
                Apttus_Proposal__Approval_Stage__c = 'None',
                Apttus_Proposal__Account__c = accId);
        insert prop;
        return prop;
    }

    //Create Proposal Line Item

    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem(Id QuoteId) {

        Apttus_Proposal__Proposal_Line_Item__c proplineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proplineItem.Apttus_Proposal__Proposal__c = QuoteId;
        proplineItem.Apttus_QPConfig__LineType__c = System.Label.ProposalLineItemTypeProductService;
        //proplineItem.APTS_Market__c   =   '';
        //proplineItem.APTS_Language__c =   '';
        //proplineItem.APTS_Product_Code__c =   '';
        return proplineItem;
    }

    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItemWithLineType(Id QuoteId, String LineType, Id ProductId) {

        Apttus_Proposal__Proposal_Line_Item__c proplineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proplineItem.Apttus_Proposal__Proposal__c = QuoteId;
        proplineItem.Apttus_QPConfig__LineType__c = LineType;
        if (LineType == 'Product/Service') {
            proplineItem.Apttus_Proposal__Product__c = ProductId;
        } else {
            proplineItem.Apttus_QPConfig__OptionId__c = ProductId;
        }

        //proplineItem.APTS_Market__c   =   '';
        //proplineItem.APTS_Language__c =   '';
        //proplineItem.APTS_Product_Code__c =   '';
        //Insert proplineItem
        return proplineItem;
    }

    public static void createProposalLineItemByFinalizingCart(Id cartId) {
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO finalRequest = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        finalRequest.CartId = cartId;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO finalResponse = Apttus_CPQApi.CPQWebService.finalizeCart(finalRequest);
    }

    //Create Proposal Line Item2
    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem2(Id QuoteId) {

        Apttus_Proposal__Proposal_Line_Item__c proplineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proplineItem.Apttus_Proposal__Proposal__c = QuoteId;
        proplineItem.Apttus_QPConfig__LineType__c = System.Label.ProposalLineItemTypeOption;
        return proplineItem;
    }

    //Create Proposal Line Item3
    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem3(Id QuoteId) {

        Apttus_Proposal__Proposal_Line_Item__c proplineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proplineItem.Apttus_Proposal__Proposal__c = QuoteId;
        proplineItem.Apttus_QPConfig__LineType__c = 'Misc';
        return proplineItem;
    }

    public static Translation__c createTranslationRecord(String RecordType, String marketCode, String language, Id productId) {
        Id recordTypeId;
        Translation__c newTranslation = new Translation__c(
        );
        if (RecordType == 'Static Text Translation') {
            recordTypeId = Schema.SObjectType.Translation__c.getRecordTypeInfosByName().get('Static Text Translation').getRecordTypeId();

            for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.StaticTextTranslationFieldSet.getFields()) {
                newTranslation.put(f.getFieldPath(), f.getFieldPath());
            }
            newTranslation.RecordTypeId = recordTypeId;
            newTranslation.Market__c = marketCode;
            newTranslation.Language__c = language;

        } else {
            recordTypeId = Schema.SObjectType.Translation__c.getRecordTypeInfosByName().get('Product Translation').getRecordTypeId();

            for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.ProductTranslationfieldSet.getFields()) {
                newTranslation.put(f.getFieldPath(), f.getFieldPath());
            }
            newTranslation.RecordTypeId = recordTypeId;
            newTranslation.Market__c = marketCode;
            newTranslation.Language__c = language;
            newTranslation.Product__c = productId;
            newTranslation.Unique_Record_Identifier__c = '';
        }

        insert newTranslation;
        system.debug('newTranslation' + newTranslation);
        return newTranslation;

    }

    public static List<Apttus_Proposal__Proposal_Line_Item__c> getQuoteProposalLineItems(Id QuoteId) {
        String Query = 'Select ';
        for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.ProductTranslationfieldSet.getFields()) {
            Query = Query + f.getFieldPath() + ',';
            //proposalLineItemRecord.put(f.getFieldPath(), translationsMap.get(uniqueRecord).get(f.getFieldPath()));
        }
        Query = Query + 'Id,Name from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c=: ' + 'QuoteId' ;
        return Database.query(Query);
    }


    //Create Opportunity record
    public static Opportunity createOpportunities(ID acctId, User owner, String marketCode, String programCode, String productCode, String currencyCode) {
        Opportunity oppty = new Opportunity(
                AccountId = acctId,
                Name = 'TestOpportunity',
                CloseDate = Date.today().addDays(5),
                OwnerId = owner.id,
                Type = 'New Business',
                StageName = 'Prospecting',
                CurrencyIsoCode = currencyCode,
                Market__c = marketCode,
                Program__c = programCode,
                Product__c = productCode,
                Description = 'testDiscription');
        System.debug(LoggingLevel.Info, '####Count query before opty insert ' + Limits.getQueries());
        insert oppty;
        return oppty;
    }

    //create account
    public static Account createAccount(string recordType, String currencyCode, String marketCode, String language) {
        Account account = new Account(
                Name = 'TestAccount',
                RecordTypeId = recordType,
                Type = 'Customer',
                BillingCountryCode = 'US',
                BillingCountry = 'United States',
                BillingCity = 'TestCity',
                BillingState = 'Alabama',
                BillingPostalCode = '050121',
                BillingStreet = 'Teststr',
                ShippingStreet = 'testcountry',
                ShippingCity = 'Alabama',
                ShippingState = 'Alabama',
                ShippingCountry = 'United States',
                ShippingPostalCode = '0501431',
                Industry = 'Fund',
                CurrencyIsoCode = currencyCode,
                Language__c = language,
                Market__c = marketCode
        );
        System.debug('account:>>>>' + account);
        insert account;
        return account;
    }

    //create account2
    public static Account createAccount2(string recordType, String currencyCode, String marketCode, String language) {
        Account account2 = new Account(
                Name = 'AccountTest2',
                RecordTypeId = recordType,
                Type = 'Customer',
                BillingCountry = 'USA',
                BillingCity = 'TestCity2',
                BillingState = 'TestState2',
                BillingPostalCode = '050122',
                BillingStreet = 'Teststr2',
                ShippingStreet = 'testcountry2',
                ShippingCity = 'TestCity2',
                ShippingState = 'TestState2',
                ShippingCountry = 'USA',
                ShippingPostalCode = '0501432',
                Industry = 'Fund',
                CurrencyIsoCode = currencyCode,
                Language__c = language,
                Market__c = marketCode
        );
        System.debug('account:>>>>' + account2);
        insert account2;
        return account2;
    }
    
    //create PresonAccount 
    public static Account createPersonAccount(string recordType) {
        Account personAcc = new Account(
                RecordTypeId = recordType,
                FirstName   =   'Test First Name',
                /**MiddleName   =   'Test MiddleName',**/
                LastName    =   'Test Lastname',
                PersonBirthdate =   system.date.newInstance(1988, 09, 08),
                /**Gender__pc       =   'Male',**/
                /**NickName__pc =   'Test nickName',**/
                PersonMailingStreet =   'Test Street',
                PersonMailingPostalCode =   '54321',
                PersonMailingCountry    =   'United States',
                PersonMailingState  =   'Idaho', 
                /**FirstNameEn__c       =   'Test first Name',
                LastNameEn__c       =   'Test last name',**/
                ShippingPostalCode  =   '54321',
                ShippingCity            =   'Test City',
                ShippingCountry         =   'United States',
                ShippingState       =   'Idaho',
                ShippingStreet      =   'Test Street',
                /**Nationality__pc      =   'American',**/
                PersonEmail         =   'test@apttus.com',
                /**Email2__pc           =   'salesforce@apttus.com',**/
                /**ParentEmail__pc      =   'test@salesforce.com',**/
                PersonHomePhone =   '1278643845', 
                PersonMobilePhone   =   '5796432186',
                PersonOtherPhone    =   '4678213468'
                /**,
                PersonalID__pc      =   'Test Id',
                PassportType__pc    =   'USA',
                PassportNumber__pc  =   '12CaUSA56',
                PassportIssueDate__pc   =   system.date.newInstance(2006, 08, 09), 
                PassportExpiryDate__pc  =   system.date.newInstance(2029, 09, 08)**/
        );
        System.debug('account:>>>>' + personAcc);
        insert personAcc;
        return personAcc;
    }

/*    public static  Map<String,List<String>> getProProgramDependency()
    {
                Map<String,List<String>> productProgramMap=new Map<String,List<String>>();
        productProgramMap.put('',);
    }*/

    Public static List<String> retrievePickListValues(String SObjectApiName, String PickListApiName) {

        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult ;
        if (SObjectApiName == 'Account') {
            if (PickListApiname == 'Language__c') {
                fieldResult = Account.Language__c.getDescribe();
            } else if (PickListApiname == 'CurrencyIsoCode') {
                fieldResult = Account.CurrencyIsoCode.getDescribe();
            } else if (PickListApiname == 'Market__c') {
                fieldResult = Account.Market__c.getDescribe();
            }
        } else if (SObjectApiName == 'Opportunity') {
            if (PickListApiname == 'Program__c') {
                fieldResult = Opportunity.Program__c.getDescribe();
            } else if (PickListApiname == 'Product__c') {
                fieldResult = Opportunity.Product__c.getDescribe();
            }
        }
        if (fieldResult != null) {
            List<Schema.PicklistEntry> pickListvalue = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListrecord : pickListvalue) {
                pickListValuesList.add(pickListrecord.getValue());
            }
        }
        return pickListValuesList;

    }

    public static List<String> getRandomPickListValue(List<String> Actualvalue, Integer expectedListCount) {
        if (Actualvalue.size() <= expectedListCount) return Actualvalue;
        List<String> actuals = new List<String>();
        List<String> clones = Actualvalue.clone();
        while (actuals.size() < expectedListCount) {
            Integer index = (Math.random() * (clones.size() - 1)).intValue();
            actuals.add(clones.remove(index));
        }
        return actuals;
    }

    //create product
    public static Product2 createProduct(String name, String productCode, String configType, boolean isActive, boolean hasoptions, boolean isCustomizable, String productType, boolean isCoursePricing, String DestinationLocation) {
        Product2 product = new Product2(Name = name,
                ProductCode = productCode,
                Apttus_Config2__ConfigurationType__c = configType,
                IsActive = isActive,
                EnableStartDateEndDate__c = true,
                Apttus_Config2__HasOptions__c = hasoptions,
                Apttus_Config2__Customizable__c = isCustomizable,
                Apttus_Config2__ProductType__c = productType,
                Apts_CoursePricing__c = isCoursePricing,
                APTS_Destination_Location__c = DestinationLocation
                //Northern Hemisphere
        );
        return product;
    }

    public static Fixed_Fare__c createFixedfare(String DepPoint,String DestinationCode,String Season,Integer FromDay,
            Integer FromMonth,String FromTo,String ProductCode,String ProgramCode,Integer ToDayint,Integer ToMonth)
    {
        Fixed_Fare__c fixedFare = new Fixed_Fare__c(
                Departure_Point__c = DepPoint,
                Destination__c = DestinationCode,
                Flight_Season__c = Season,
                From_Day__c = FromDay,
                From_Month__c = FromMonth,
                From_To__c = FromTo,
                Product__c = ProductCode,
                Program__c = ProgramCode,
                To_Day__c = ToDayint,
                To_Month__c = ToMonth
                //Northern Hemisphere
        );
        return fixedFare;
    }

    //create Supplement
    public static Season_Supplements__c createSeaSonSupplement(Date startDate, Date endDate, Boolean isMainSupplement, Id seasonSupplementProductId, string DestinationLocation, String currencystring, String market, Id productGroupId) {
        Season_Supplements__c objSeasonSupplement = new Season_Supplements__c(Name = '',
                Destination_Location__c = DestinationLocation,
                IsMainSupplement__c = isMainSupplement,
                APTS_Market__c = market,
                CurrencyIsoCode = currencystring,
                ProductGroup__c = productGroupId,
                SeasonSupplementProduct__c = seasonSupplementProductId,
                SupplementEndDate__c = endDate,
                SupplementStartDate__c = startDate

                //Northern Hemisphere
        );
        return objSeasonSupplement;
    }

    //create Price List
    public static Apttus_Config2__PriceList__c createPriceList(String name, boolean isActive, String version, String year, string marketCode, String programCode, String currencyCode) {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = name,
                Apttus_Config2__Active__c = isActive,
                Brackets_Threshold__c = 8,
                Apts_BracketsThresholdTI__c = 3,
                Version__c = version,
                Market__c = marketCode,
                Program__c = programCode,
                CurrencyIsoCode = currencyCode,
                APTS_Default__c = true,
                Year__c = year);
        insert priceList;
        return priceList;
    }

//create Price Dimensions
    public static Apttus_Config2__PriceDimension__c createPriceDimension(String name, String configType, String contextType, String businessObject, String dataSource) {
        Apttus_Config2__PriceDimension__c priceDimension = new Apttus_Config2__PriceDimension__c(name = name,
                Apttus_Config2__Type__c = configType,
                Apttus_Config2__ContextType__c = contextType,
                Apttus_Config2__BusinessObject__c = businessObject,
                Apttus_Config2__Datasource__c = dataSource);
        return priceDimension;
    }

//create Price Dimensions
    public static Apttus_Config2__PriceListItem__c createPriceListItem(Id priceListId, double listPrice, Id productId, String chargeType) {
        Apttus_Config2__PriceListItem__c priceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,
                Apttus_Config2__ListPrice__c = listPrice,
                Apttus_Config2__ProductId__c = productId,
                Apttus_Config2__ChargeType__c = chargeType);
        return priceListItem1;
    }

    //create Destination
    public static destination__c createDestination(string destinationCode, string language) {
        Destination__c destination = new Destination__c(DestinationCode__c = destinationCode,
                Language__c = language);
        return destination;
    }

    //create product configuration
    public static Apttus_Config2__ProductConfiguration__c createApttus_ProductConfiguration(Id accountId, Id priceListId, Id proposalId, string bussinessObjectType) {
        Apttus_Config2__ProductConfiguration__c ProductConfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 1',
                Apttus_Config2__AccountId__c = accountId,
                Apttus_Config2__PriceListId__c = priceListId,
                Apttus_QPConfig__Proposald__c = proposalId,
                Apttus_Config2__VersionNumber__c = 1,
                Apttus_Config2__EffectivePriceListId__c = priceListId,
                Apttus_Config2__BusinessObjectType__c = bussinessObjectType);
        return ProductConfiguration;
    }

    //create LineItemlist
    public static Apttus_Config2__LineItem__c createApttus_LineItem(Id configuration1Id, Id product1Id, Id priceListItem2Id, Id priceListId, Id product2Id, string productUom, string chargeType) {
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration1Id,
                Apttus_Config2__ParentBundleNumber__c = 1,
                Apttus_Config2__ProductId__c = product1Id,
                Apttus_Config2__BasePrice__c = 1000,
                Apttus_Config2__Uom__c = productUom,
                Apttus_Config2__PriceListItemId__c = priceListItem2Id,
                Apttus_Config2__Description__c = 'Users - Dashboard Only Access',
                Apttus_Config2__PriceListId__c = priceListId,
                Apttus_Config2__ChargeType__c = chargeType,
                Apttus_Config2__OptionId__c = product2Id,
                Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__Quantity__c = 10,
                Apttus_Config2__ItemSequence__c = 1,
                Apttus_Config2__LineNumber__c = 1,
                Apttus_Config2__PrimaryLineNumber__c = 2);
        return lineItem;
    }

    //create Product Attribute Value
    public static Apttus_Config2__ProductAttributeValue__c createApttus_ProductAttributeValue(Id lineItem2Id, string destinationName) {
        Apttus_Config2__ProductAttributeValue__c productValue = new Apttus_Config2__ProductAttributeValue__c(APTS_Start_Date__c = system.today(),
                APTS_End_Date__c = System.today() + 1,
                Quantity__c = 12.0,
                APTS_Destination_Name__c = destinationName,
                Apttus_Config2__LineItemId__c = lineItem2Id
        );
        return productValue;
    }

    //create Apttus ProductGroup
    public static Apttus_Config2__ProductGroup__c createApttus_ProductGroupValue(string groupName, string groupType, string currencyCode) {
        Apttus_Config2__ProductGroup__c productGroupValue = new Apttus_Config2__ProductGroup__c(Name = groupName,
                Apttus_Config2__GroupType__c = groupType,
                CurrencyIsoCode = currencyCode);
        return productGroupValue;
    }
    
    public static Fixed_Fare__c getFixedfare()  {
        return [select Departure_Point__c,Destination__c,Flight_Season__c,From_Day__c,From_Month__c,From_To__c,Product__c,Program__c,To_Day__c,To_Month__c from Fixed_Fare__c limit 1];
    }
    
    public static Apttus_Config2__ProductConfiguration__c  getTestConfig(String ConfigName) {
        return [select id,name from Apttus_Config2__ProductConfiguration__c where name=:ConfigName limit 1];
    }
    
    public static Departure_Point__c createDeparturePoint(String DepPoint,String ProductCode,String ProgramCode,String MarketCode,String CurrCode) {
        Departure_Point__c depPointobj = new Departure_Point__c(
                Active__c = true,
                Code__c = DepPoint,
                Market__c = MarketCode,
                Product__c = ProductCode,
                Program__c = ProgramCode,
                CurrencyIsoCode=CurrCode

                //Northern Hemisphere
        );
        return depPointobj;
    }
    
     public static List<Apttus_Config2__LineItem__c> getLineItemsForConfigId(Id ConfigId) {
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id,Name,Apttus_Config2__LineType__c,FixedFareSeason__c,Apttus_Config2__LineStatus__c,APTS_Product_Type__c,
                Apttus_Config2__ProductId__c,Apttus_Config2__BasePrice__c,Apttus_Config2__PriceListItemId__c,Apttus_Config2__Description__c
        ,Apttus_Config2__PriceListId__c,Apttus_Config2__Quantity__c,Apttus_Config2__LineNumber__c,Apttus_Config2__StartDate__c,Apttus_Config2__EndDate__c
        FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :ConfigId ];
        return lineItems;
    }


}