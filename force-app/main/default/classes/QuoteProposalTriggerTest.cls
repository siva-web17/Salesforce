/**
 * Created by arjun.mohan on 12/12/2017.
 */
@isTest(SeeAllData = false)
public class QuoteProposalTriggerTest {

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

            //Waiting for confirmation from Manos to remove hard coded value as these two are dependent picklist values.
            String program = 'ILSH';
            String productCode = 'ILS';
            accountRecord = APTS_TestDataUtility.createAccount(CustomerRecTypeId, currencyValue, market, language);
            priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', market, program, currencyValue);

            //create opportunity
            oppty = APTS_TestDataUtility.createOpportunities(accountRecord.Id, testUser, market, program, productCode, currencyValue);

            //inserting translation record Default Market hard Coded to USB and language set to english
            Translation__c translationStaticRecord = APTS_TestDataUtility.createTranslationRecord('Static Text Translation', 'USB', 'EN', null);
        }
    }

    public static testMethod void When_LanguageOfAccountIsNotMatchingWithLanguageOfTranslationObject_Expect_TranslationsInEnglish() {
        test.startTest();
        User testUser = APTS_TestDataUtility.getTestUser('APTS_EFTestUser@gmail.com');
        accountRecord = APTS_TestDataUtility.getTestAccount('TestAccount');
        oppty = APTS_TestDataUtility.getTestOpportunity('TestOpportunity');
        String languageOfAccount = accountRecord.Language__c;
        System.runAs(testUser) {
            if (accountRecord.Language__c != 'EN') {
                TestProp = APTS_TestDataUtility.createProposalWithoutPriceList('TestProposal', oppty.Id, accountRecord.CurrencyIsoCode, accountRecord.Id, 'Proposal','','');
            }
            else {
                for (String pickListValue : APTS_TestDataUtility.retrievePickListValues('Account', 'Language__c')) {
                    if (accountRecord.Language__c != pickListValue) {
                        accountRecord.Language__c = pickListValue;
                        break;
                    }
                }
                update accountRecord;
                TestProp = APTS_TestDataUtility.createProposalWithoutPriceList('TestProposal', oppty.Id, accountRecord.CurrencyIsoCode, accountRecord.Id, 'Proposal','','');
            }

            TestProp = APTS_TestDataUtility.getTestQuote(TestProp.Id);
            System.assertEquals(oppty.Market__c, TestProp.Market__c, 'Opportunity Market is different from proposal market');
            System.assertEquals(oppty.Program__c, TestProp.Program__c, 'Opportunity Program is different from proposal Program');
            System.assertEquals(oppty.Product__c, TestProp.Product__c, 'Opportunity Product is different from proposal Product');

            for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.StaticTextTranslationFieldSet.getFields()) {
                System.assert(TestProp.get(f.getFieldPath()) != null, 'Field values are empty for translation fields');
            }
            System.assert(TestProp.Apttus_QPConfig__PriceListId__c == null, 'Price List Auto Populated');
        }
        Test.stopTest();
    }

    public static testMethod void When_LanguageOfAccountIsMatchingWithLanguageOfTranslationObject_Expect_TranslationsInLanguageOfAccount() {

        test.startTest();

        User testUser = APTS_TestDataUtility.getTestUser('APTS_EFTestUser@gmail.com');
        accountRecord = APTS_TestDataUtility.getTestAccount('TestAccount');
        oppty = APTS_TestDataUtility.getTestOpportunity('TestOpportunity');
        String languageOfAccount = accountRecord.Language__c;

        //inserting translation record Which has same language as account
        Translation__c translationStaticRecord = APTS_TestDataUtility.createTranslationRecord('Static Text Translation', accountRecord.market__c, accountRecord.Language__c, null);

        System.runAs(testUser) {
            Apttus_Proposal__Proposal__c TestProposalForDifferentLanguage = APTS_TestDataUtility.createProposalWithoutPriceList('TestProposalForDifferentLanguage', oppty.Id, accountRecord.CurrencyIsoCode, accountRecord.Id, 'Proposal',oppty.Market__c,oppty.Program__c);

            TestProposalForDifferentLanguage = APTS_TestDataUtility.getTestQuote(TestProposalForDifferentLanguage.Id);
            system.debug('!!!!!!!!!!!!!!!!!!!! checking price list for insert' + TestProposalForDifferentLanguage);

            for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.StaticTextTranslationFieldSet.getFields()) {
                System.assert(TestProposalForDifferentLanguage.get(f.getFieldPath()) != null, 'Field values are empty for translation fields');
            }
            //Checking weather price list is getting populated while creating quote
            System.assert(TestProposalForDifferentLanguage.Apttus_QPConfig__PriceListId__c != null, 'Price List Not Populated');
        }
        Test.stopTest();
    }

    public static testMethod void When_ProposalHasSameMarketProgramOfPriceList_Expect_AutoPopulatePriceListInquote() {
        test.startTest();
        User testUser = APTS_TestDataUtility.getTestUser('APTS_EFTestUser@gmail.com');
        accountRecord = APTS_TestDataUtility.getTestAccount('TestAccount');
        oppty = APTS_TestDataUtility.getTestOpportunity('TestOpportunity');

        String languageOfAccount = accountRecord.Language__c;
        String currencyValue = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'CurrencyIsoCode'), 1)[0];
        String market = APTS_TestDataUtility.getRandomPickListValue(APTS_TestDataUtility.retrievePickListValues('Account', 'Market__c'), 1)[0];

        System.runAs(testUser) {
            Apttus_Config2__PriceList__c priceListRecord = APTS_TestDataUtility.createPriceList('APTPS TST AutoPopulatePriceList 1', true, 'V0', '2017', market, oppty.program__c, currencyValue);
            Apttus_Proposal__Proposal__c TestProposalForAutoPopulatePriceList = APTS_TestDataUtility.createProposalWithoutPriceList('TestProposalForDifferentLanguage', oppty.Id, currencyValue, accountRecord.Id, 'Proposal', '', oppty.program__c);
            TestProposalForAutoPopulatePriceList.Market__c = market;
            TestProposalForAutoPopulatePriceList.CurrencyIsoCode = currencyValue;
            Update TestProposalForAutoPopulatePriceList;
            TestProposalForAutoPopulatePriceList = APTS_TestDataUtility.getTestQuote(TestProposalForAutoPopulatePriceList.Id);
            System.assert(TestProposalForAutoPopulatePriceList.Apttus_QPConfig__PriceListId__c != null, 'Price List Not Populated');
        }
        Test.stopTest();
    }
}