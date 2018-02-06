/**
 * Created by arjun.mohan on 1/3/2018.
 */

@isTest(SeeAllData=false)
public class ProposalLineItemTriggerTest {

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
            String currencyvalue = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'CurrencyIsoCode'), 1)[0];
            String market = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'Market__c'), 1)[0];
            String language = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'Language__c'), 1)[0];
            /*String program=APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Opportunity','Program__c'),1)[0];
            String productCode=APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Opportunity','Product__c'),1)[0];*/

            //Waiting for confirmation from Manos to remove hard coded value as these two are dependent picklist values.
            String program = 'ILSH';
            String productCode = 'ILS';

            /**
            String currencyvalue=APTS_TestDataUtility.retrivePickListvalues('Account','CurrencyIsoCode')[0];
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
            //inserting translation record Default Market hard Coded to USB and language set to english
            List<Translation__c> translationRecordList = new List<Translation__c>();
            for(Product2 productRecord : [select Id, Name, ProductCode, Apts_CoursePricing__c from Product2 order by CreatedDate]){
                translationRecordList.add(APTS_TestDataUtility.createTranslationRecord('Product Translation', 'USB', 'EN', productRecord.Id));
            }
            TestProp = APTS_TestDataUtility.createProposal('TestProposal', oppty.Id, currencyValue, accountRecord.Id, 'Proposal', priceList.Id);
            System.debug('***TEST CLASS : oppty===>' + translationRecordList);

            CreatePricListItems(priceList,productList);
            list<Apttus_Config2__LineItem__c> lineItems = CreateLineItems();
            insert lineItems;

            list<Apttus_Proposal__Proposal_Line_Item__c> proposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            for (Apttus_Config2__LineItem__c record : lineItems) {
                proposalList.add(APTS_TestDataUtility.createProposalLineItemWithLineType(TestProp.Id,record.Apttus_Config2__LineType__c, record.Apttus_Config2__ProductId__c));
            }
            System.debug('Before Insert'+proposalList.size());
            insert proposalList;
            System.debug('After Insert'+proposalList.size());
        }
    }

    public static testMethod void When_LanguageOfAccountIsNotMatchingWithLanguageOfTranslationObject_Expect_LineItemTranslationsInEnglish() {
        test.startTest();
        User testUser = APTS_TestDataUtility.getTestUser('APTS_EFTestUser@gmail.com');
        accountRecord = APTS_TestDataUtility.getTestAccount('TestAccount');
        oppty = APTS_TestDataUtility.getTestOpportunity('TestOpportunity');
        system.debug('!!!!!!!!!!!!!!!!!!!!' + accountRecord);
        String languageofAccount = accountRecord.Language__c;

        //test.startTest();
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];

        Apttus_Config2__ProductConfiguration__c testConfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        insert testConfiguration;
        system.debug('Inserted config' );
        //APTS_TestDataUtility.createProposalLineItemByFinalizingCart(testconfiguration.Id);
        system.debug('cart finalized' );

        list<Apttus_Proposal__Proposal_Line_Item__c> proposalList = APTS_TestDataUtility.getQuoteProposalLineItems(testProposal.Id);
        List<Translation__c> translationrecordList = [Select Id, Name, Unique_Record_Identifier__c from Translation__c];
        System.debug('Translation list is'+translationrecordList);

        System.runAs(testUser) {
            for (Apttus_Proposal__Proposal_Line_Item__c proposalRecord : proposalList) {
                for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.ProductTranslationFieldSet.getFields()) {
                    System.assert(Proposalrecord.get(f.getFieldPath()) != null, 'Field values are empty for translation fields');
                }
            }
            //System.assert(TestProp.Apttus_QPConfig__PriceListId__c == null, 'Price List Auto Populated');
        }
        Test.stopTest();
    }

    public static testMethod void When_InputListIsEmpty_Expect_ErrorLogInCatchBlock() {
        ProposalLineItemHelper.updateProposalLineItemFieldsBeforeCreation(null);
    }

    public static list<Apttus_Config2__LineItem__c> CreateLineItems() {
        System.debug('***Inside create line item===>' );
        Apttus_Proposal__Proposal__c testProposal = [select Id, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
        Apttus_Config2__ProductConfiguration__c testConfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTPS TST Configuration 2', Apttus_Config2__AccountId__c = testProposal.Apttus_Proposal__Account__c, Apttus_Config2__PriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__Proposald__c = testProposal.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = testProposal.Apttus_QPConfig__PriceListId__c);
        testconfiguration.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        insert testConfiguration;
        System.debug('***TEST CLASS : configuration===>' + testConfiguration);
        //system.assert(testconfiguration.Name == 'APTpS TST Configuration 2');
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
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100, Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
                Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
                Apttus_Config2__Quantity__c = 5, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1,
                Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);

        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = testconfiguration.Id, Apttus_Config2__SellingTerm__c = 1,
                Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW,
                Apttus_Config2__ProductId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__BasePrice__c = 100, Apttus_Config2__PriceListItemId__c = priceListItemList[8].Id,
                Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__OptionId__c = productNameWithRecordMap.get('Travel Insurance').Id, Apttus_Config2__PriceListId__c = priceList.Id,
                Apttus_Config2__Quantity__c = 8, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1,
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
        System.debug('***TEST CLASS : PRODUCT 9===>'+product9);

        insert productsList;
        return productsList;
    }

    public static void CreatePricListItems(Apttus_Config2__PriceList__c priceList,List<Product2> productList)
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

        insert priceListItemsList;
        System.debug('***TEST CLASS : priceListItemsList===>'+priceListItemsList);
    }
}