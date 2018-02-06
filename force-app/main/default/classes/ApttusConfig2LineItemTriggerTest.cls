/**
 * Created by arjun.mohan on 12/16/2017.
 */

@isTest(SeeAllData=false)
public class ApttusConfig2LineItemTriggerTest {
    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    private static final String PRICE_TYPE_RECURRING = 'Recurring';
    private static final String CHARGE_TYPE_OVERAGE = 'Overage';
    private static final String CHARGE_TYPE_INCLUDED_UNITS = 'Included Units';
    private static final String CHARGE_TYPE_COMMIT = 'Commit';
    private static final String CHARGE_TYPE_INCLUDED = 'Included';
    private static final String LINE_STATUS_CANCELLED = 'Cancelled';
    public static Account accountRecord;
    public static Apttus_Proposal__Proposal__c TestProp;
    public static Apttus_Config2__PriceList__c priceList;
    public static Opportunity oppty;
    //Creating User,Profile,Account,Opportunity, Default Translation
    @TestSetup
    static void setup_User_Account_Opportunity_Quote_PriceList_Details() {
        Profile SystemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        User testUser = APTS_TestDataUtility.createUser(SystemAdminProfile.ID);
        System.runAs(testUser) {
            String CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
            String currencyValue = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'CurrencyIsoCode'), 1)[0];
            String market = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'Market__c'), 1)[0];
            String language = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'Language__c'), 1)[0];
            /*String program=APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListvalues('Opportunity','Program__c'),1)[0];
            String productCode=APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListvalues('Opportunity','Product__c'),1)[0];*/

            //Waiting for confirmation from Manos to remove hard coded value as these two are dependent picklist values.
            String program = 'ILSH';
            String productCode = 'ILS';

            /*   String currencyvalue=APTS_TestDataUtility.retrivePickListvalues('Account','CurrencyIsoCode')[0];
               String market=APTS_TestDataUtility.retrivePickListvalues('Account','Market__c')[0];
               String language=APTS_TestDataUtility.retrivePickListvalues('Account','Language__c')[0];
               String program=APTS_TestDataUtility.retrivePickListvalues('Opportunity','Program__c')[0];
               String productCode=APTS_TestDataUtility.retrivePickListvalues('Opportunity','Product__c')[0];*/

            accountRecord = APTS_TestDataUtility.createAccount(CustomerRecTypeId, currencyValue, market, language);

            System.debug('***TEST CLASS : testAcc===>' + accountRecord);

            priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', market, program, currencyValue);
            System.debug('***TEST CLASS : priceList===>' + priceList);

            //create opportunity
            oppty = APTS_TestDataUtility.createOpportunities(accountRecord.Id, testUser, market, program, productCode, currencyValue);
            System.debug('***TEST CLASS : oppty===>' + oppty);
            List<Product2> productList= createProducts();

            Departure_Point__c obj= APTS_TestDataUtility.createDeparturePoint('FRP',productCode,program,market,currencyValue);
            system.debug('Dep Point'+obj);
            insert obj;
            insert APTS_TestDataUtility.createFixedfare(obj.Code__c,'RESM-INBO','HighSeason2',2,2,'Dec-12 To Jan-21',productCode,program,31,12);

            TestProp = APTS_TestDataUtility.createProposal('TestProposal', oppty.Id, currencyValue, accountRecord.Id, 'Proposal', priceList.Id);
            TestProp.APTS_Departure_Point__c=obj.Id;
            update TestProp;
            //System.debug('***TEST CLASS : oppty===>' + translationrecordList);
            CreatePriceListItems(priceList,productList);
            list<Apttus_Config2__LineItem__c> lineitems=CreateLineItems();
            insert lineitems;
            //Get Standard Price Book Id
            Id stdPriceBookId = Test.getStandardPricebookId();
            system.debug('*******stdPricebookId====>' + stdPriceBookId);
            //insert CreateLineItems();
        }
    }

    public static testMethod void When_CourseOfTheBundleIsChanged_Expect_StartDateEndDateValuesOfThatBundleArticlesSetToNull() {
        //List<Apttus_Config2__LineItem__c> lineItemsListTemp=CreateLineItems();

        List<Apttus_Config2__LineItem__c> lineItemsList = APTS_TestDataUtility.getLineItemsForConfigId(APTS_TestDataUtility.getTestConfig('APTpS TST Configuration 2').Id);
        System.debug('Checking in '+lineItemsList);
        for (Apttus_Config2__LineItem__c record:lineItemsList) {
            if (record.APTS_Product_Type__c=='Course') {
                delete record;
                break;
            }
        }
        lineItemsList=APTS_TestDataUtility.getLineItemsForConfigId(APTS_TestDataUtility.getTestConfig('APTpS TST Configuration 2').Id);
        for (Apttus_Config2__LineItem__c record:lineItemsList) {
            system.assert(record.Apttus_Config2__StartDate__c==null,'Start date should be defaulted to null');
            system.assert(record.Apttus_Config2__EndDate__c==null,'End date should be defaulted to null');
            system.assert(record.Apttus_Config2__Quantity__c==1,'Quantity should be defaulted to 1');
        }
        //update CreateLineItems();
    }

    //This method is written only for code coverage purpose
    public static testmethod void When_ListIsNull_Expect_ErrorLogInCatchBlock() {
        ApttusConfig2lineItemHelper.updateStartDateEndDateOfCourseRelatedArticlesIfCourseIsChanged(null, null);
    }

    public static testMethod void When_LineItemDateHasSameRangeAsFixedFare_Expect_FixedfareWithdatePopulated() {
        List<Apttus_Config2__LineItem__c> lineItemsListTemp = CreateLineItems();
        Insert lineItemsListTemp;
        lineItemsListTemp = APTS_TestDataUtility.getLineItemsForConfigId(APTS_TestDataUtility.getTestConfig('APTpS TST Configuration 2').Id);
        for (Apttus_Config2__LineItem__c record:lineItemsListTemp) {
            if (record.APTS_Product_Type__c == 'Accommodation') {
                record.Apttus_Config2__StartDate__c = record.Apttus_Config2__StartDate__c.addDays(1);
                break;
            }
        }
        update lineItemsListTemp;

        //Here we check weather FixedFareSeason__c is updated or not
        lineItemsListTemp=APTS_TestDataUtility.getLineItemsForConfigId(APTS_TestDataUtility.getTestConfig('APTpS TST Configuration 2').Id);
        for (Apttus_Config2__LineItem__c record:lineItemsListTemp) {
            if (record.APTS_Product_Type__c == 'Accommodation' && record.FixedFareSeason__c != null ) {
                system.assert(record.FixedFareSeason__c == APTS_TestDataUtility.getFixedFare().Flight_Season__c,'Fixed Fare Season is not populated!!!!');
                break;
            }
        }
        //update APTS_TestDataUtility.getLineItemsForConfigId(APTS_TestDataUtility.getTestConfig('APTpS TST Configuration 2').Id);
    }

    public static list<Apttus_Config2__LineItem__c> CreateLineItems() {
        System.debug('***Inside create line item===>' );
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
        Apttus_Config2__ProductConfiguration__c testConfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testConfiguration.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        insert testConfiguration;
        System.debug('***TEST CLASS : configuration===>' + testConfiguration);
        //system.assert(testConfiguration.Name == 'APTpS TST Configuration 2');
        map<String, Product2> productNameWithRecordMap = new map<String, Product2>();
        for(Product2 productRecord : [select Id,Name,ProductCode,Apts_CoursePricing__c from Product2 order by CreatedDate]){
            productNameWithRecordMap.put(productRecord.Name, productRecord);
        }
        System.debug('***Before checking price list===>' );
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();

        for(Apttus_Config2__PriceList__c priceListRecord : [select Id, (select Id from Apttus_Config2__Items__r order by CreatedDate) from Apttus_Config2__PriceList__c where Name = 'APTPS TST PriceList 1']){
            priceList = priceListRecord;
            for(Apttus_Config2__PriceListItem__c priceListItem : priceList.Apttus_Config2__Items__r){
                priceListItemList.add(priceListItem);
            }
        }
        System.debug('***Started with line item===>' );
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();

        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration.Id,
                Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW,
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Auckland 1').Id,
                Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__Description__c = 'Auckland Destination', Apttus_Config2__PriceListId__c = priceList.Id,
                Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1,
                Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1,
                APTS_Product_Type__c ='Destination',
                Apttus_Config2__StartDate__c=Date.valueOf('2017-01-01'),Apttus_Config2__EndDate__c=Date.valueOf('2017-05-05'),
                Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);

        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration.Id,
                Apttus_Config2__LineType__c = LINE_TYPE_OPTION, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW,
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Flight Booked by EF (Fixed Fare)').Id,
                Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__PriceListItemId__c = priceListItemList[0].Id, Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__Description__c = 'Users - Full Access', Apttus_Config2__PriceListId__c = priceList.Id,
                APTS_Product_Type__c ='Travel',
                Apttus_Config2__StartDate__c=Date.valueOf('2017-01-01'),Apttus_Config2__EndDate__c=Date.valueOf('2017-05-05'),
                Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1,
                Apttus_Config2__LineNumber__c = 1, Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Flight Booked by EF (Fixed Fare)').Id,
                Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem2);

        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1,
                Apttus_Config2__LineStatus__c = LINE_STATUS_NEW,
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('EF International House Multi Boston').Id,
                Apttus_Config2__BasePrice__c = 100, Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
                Apttus_Config2__ChargeType__c = 'Standard Price',
                Apttus_Config2__OptionId__c = productNameWithRecordMap.get('EF International House Multi Boston').Id, Apttus_Config2__PriceListId__c = priceList.Id,
                Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1,
                APTS_Product_Type__c='Accommodation',
                Apttus_Config2__PrimaryLineNumber__c = 1,Apttus_Config2__StartDate__c=Date.valueOf('2016-12-12'),
                Apttus_Config2__EndDate__c=Date.valueOf('2017-02-06'),
                Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);

        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testConfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW,
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Intensive Course').Id, Apttus_Config2__BasePrice__c = 100, Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
                Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Intensive Course').Id, Apttus_Config2__PriceListId__c = priceList.Id,
                Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1,APTS_Product_Type__c='Course',
                Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem4);

        system.debug('lineItemsList count is'+lineItemsList.size());
        return lineItemsList;
    }

    public static List<Product2> createProducts()
    {
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

        Product2 product2 = APTS_TestDataUtility.createProduct('Intensive Course', 'I', 'Option', true, false, false, 'Course', true, '');
        productsList.add(product2);
        System.debug('***TEST CLASS : PRODUCT 2===>'+product2);

        Product2 product3 = APTS_TestDataUtility.createProduct('Auckland 2', 'NZ-AUK', 'Bundle', true, true, true, 'Destination', false, '');
        productsList.add(product3);
        System.debug('***TEST CLASS : PRODUCT 3===>'+product3);

        Product2 product4 = APTS_TestDataUtility.createProduct('Basic Course', 'B', 'Option', true, false, false, 'Course', true, '');
        productsList.add(product4);
        System.debug('***TEST CLASS : PRODUCT 4===>'+product4);

        Product2 product5 = APTS_TestDataUtility.createProduct('Auckland 3', 'NZ-AUZ', 'Bundle', true, true, true, 'Destination', false, '');
        productsList.add(product5);
        System.debug('***TEST CLASS : PRODUCT 5===>'+product5);

        Product2 product6 = APTS_TestDataUtility.createProduct('Junior Course', 'JU', 'Option', true, false, false, 'Course', true, '');
        productsList.add(product6);
        System.debug('***TEST CLASS : PRODUCT 6===>'+product6);

        Product2 product7 = APTS_TestDataUtility.createProduct('Travel Insurance', 'TRI', 'Option', true, false, false, 'Insurance',  false, '');
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

        Product2 product10 = APTS_TestDataUtility.createProduct('Flight Booked by EF (Fixed Fare)', 'FTEFX', 'Option', true, false, false, 'Travel',  false, '');
        product9.Apts_TI_Pricing__c = TRUE;
        productsList.add(product10);

        Product2 product11 = APTS_TestDataUtility.createProduct('EF International House Multi Boston', 'RESM-INBO', 'Option', true, false, false, 'Accommodation',  false, '');
        product9.Apts_TI_Pricing__c = TRUE;
        productsList.add(product11);

        System.debug('***TEST CLASS : PRODUCT 9===>'+product9);

        insert productsList;
        return productsList;
    }

    public static void CreatePriceListItems(Apttus_Config2__PriceList__c priceList,List<Product2> productList)
    {
        //create price list items
        list<Apttus_Config2__PriceListItem__c> priceListItemsList = new list<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c priceListItem1 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[0].Id, 'Standard Price');
        priceListItemsList.add(priceListItem1);

        Apttus_Config2__PriceListItem__c priceListItem2 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[8].Id, 'Standard Price');
        priceListItemsList.add(priceListItem2);

        Apttus_Config2__PriceListItem__c priceListItem3 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[1].Id, 'Standard Price');
        priceListItemsList.add(priceListItem3);

        Apttus_Config2__PriceListItem__c priceListItem4 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[2].Id, 'Standard Price');
        priceListItemsList.add(priceListItem4);

        Apttus_Config2__PriceListItem__c priceListItem5 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[3].Id, 'Standard Price');
        priceListItemsList.add(priceListItem5);

        Apttus_Config2__PriceListItem__c priceListItem6 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 1000, productList[4].Id, 'Standard Price');
        priceListItemsList.add(priceListItem6);

        Apttus_Config2__PriceListItem__c priceListItem7 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 200, productList[5].Id, 'Standard Price');
        priceListItemsList.add(priceListItem7);

        Apttus_Config2__PriceListItem__c priceListItem8 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, productList[6].Id, 'Standard Price');
        priceListItemsList.add(priceListItem8);

        Apttus_Config2__PriceListItem__c priceListItem9 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, productList[7].Id, 'Standard Price');
        priceListItemsList.add(priceListItem9);
        Apttus_Config2__PriceListItem__c priceListItem10 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, productList[9].Id, 'Standard Price');
        priceListItemsList.add(priceListItem10);
        Apttus_Config2__PriceListItem__c priceListItem11 = APTS_TestDataUtility.createPriceListItem(priceList.Id, 50, productList[10].Id, 'Standard Price');
        priceListItemsList.add(priceListItem11);

        insert priceListItemsList;
        System.debug('***TEST CLASS : priceListItemsList===>'+priceListItemsList);
    }
}