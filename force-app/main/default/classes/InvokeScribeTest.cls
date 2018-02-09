@isTest
public class InvokeScribeTest {
    @testSetup	
    static void testDataSetup(){
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        //insert User
        User testUser = APTS_TestDataUtility.createUser(SystemAdminProfile.ID);
        System.runAs(testUser) {
            //Get Standard Price Book Id
            Id stdPriceBookId = Test.getStandardPricebookId();
            
            //create Account
            String CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
            string currencyCode = SObjectType.Account.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            string marketCode = SObjectType.Account.Fields.Market__c.PicklistValues[0].getValue();
            string language = SObjectType.Account.Fields.Language__c.PicklistValues[0].getValue();
 			Account testAccount = APTS_TestDataUtility.createAccount(CustomerRecTypeId, currencyCode, marketCode, language);
            
            //create opportunity
            string opportunityMarketCode = SObjectType.Opportunity.Fields.Market__c.PicklistValues[0].getValue();
            string opportunityProgramCode = SObjectType.Opportunity.Fields.Program__c.PicklistValues[3].getValue();
            string opportunityProductCode = SObjectType.Opportunity.Fields.Product__c.PicklistValues[0].getValue();
            string opportunityCurrencyCode = SObjectType.Opportunity.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            Opportunity testOpportunity = APTS_TestDataUtility.createOpportunities(testAccount.Id, testUser, opportunityMarketCode, opportunityProgramCode, opportunityProductCode, opportunityCurrencyCode);
            testOpportunity.Pricebook2ID = stdPricebookId;
           
            //create price list
            string priceListMarketCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Market__c.PicklistValues[0].getValue();
            string programCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Program__c.PicklistValues[0].getValue();
            string priceListCurrencyCode = SObjectType.Apttus_Config2__PriceList__c.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            Apttus_Config2__PriceList__c priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', priceListMarketCode, programCode, priceListCurrencyCode);
 			 
            //create Proposal
            Apttus_Proposal__Proposal__c TestProp = APTS_TestDataUtility.createProposal('TestProposal', testOpportunity.Id, 'EUR', testAccount.Id,'Proposal',priceList.id);
            
        }
    }
    @isTest
    static void InvokeScribeSuccess(){
        Test.startTest();
        List<Apttus_Proposal__Proposal__c>	testProposal	=	[SELECT Id, Name FROM Apttus_Proposal__Proposal__c];
        system.assertEquals(1, testProposal.size());
        Test.setMock(HttpCalloutMock.class, new MockGenerator_Test());
        InvokeScribe.InvokeScribeAfterFinishBooking(testProposal[0].Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void InvokeScribeFailure(){
        Test.startTest();
        List<Apttus_Proposal__Proposal__c>	testProposal	=	[SELECT Id, Name FROM Apttus_Proposal__Proposal__c];
        InvokeScribe.InvokeScribeAfterFinishBooking(testProposal[0].Id);
        system.assertEquals(1, testProposal.size());
        Test.stopTest();
    }
    
    public class MockGenerator_Test implements HttpCalloutMock{
        public HttpResponse respond(HTTPrequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(405);
            res.setStatus('Method Not Allowed');
            return res;
        }
    }
}