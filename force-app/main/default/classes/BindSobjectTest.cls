@isTest
public class BindSobjectTest {
	public static String market = 'DEB';
    public static String salesOffice1 = 'DEB';
    public static final String testOpportunityName = 'TestOpportunityRecord';
    
    @testSetup	
    static void testDataSetup(){
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        //insert User
        User tAdminUser = TestDataFactory.createAdminUser(True);
        //TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        system.runAs(tAdminUser) {
            
            
            Map<String, String> markets = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c');
            List<String> products = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Product__c').values();
            List<String> salesOffices = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'SalesOffice__c').get(markets.values()[0]);
            List<String> Programs = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'Program__c').get(markets.values()[0]);
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, True);
			string dateValue = string.valueof(System.today());
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => Market,
                    'Product__c' => products[0],
                    'SalesOffice__c' =>salesOffice1,
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues, True);
            
            //create price list
            string priceListMarketCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Market__c.PicklistValues[0].getValue();
            string programCode = SObjectType.Apttus_Config2__PriceList__c.Fields.Program__c.PicklistValues[0].getValue();
            string priceListCurrencyCode = SObjectType.Apttus_Config2__PriceList__c.Fields.CurrencyIsoCode.PicklistValues[0].getValue();
            Apttus_Config2__PriceList__c priceList = APTS_TestDataUtility.createPriceList('APTPS TST PriceList 1', true, 'V0', '2017', priceListMarketCode, programCode, priceListCurrencyCode);
 			
          
            //insert Proposal
            Apttus_Proposal__Proposal__c TestProp = APTS_TestDataUtility.createProposal('TestProposal', newOpportunityPersonAccount.Id, 'EUR', newAccount.Id,'Proposal',priceList.id);
            TestProp.Apttus_Proposal__Primary__c=true;
            TestProp.Apttus_Proposal__Approval_Stage__c='None';           
    
        }
    }
    
    @isTest 
    static void dataBindTest() {
        Id currentrecord;
        Test.startTest();
        List<Apttus_Proposal__Proposal__c> proposalListQuery = [SELECT Id,Name FROM Apttus_Proposal__Proposal__c];
        List<Account> AccountListQuery = [SELECT Id,Name FROM Account];
        List<Opportunity> OpportunityListQuery = [SELECT Id,Name FROM Opportunity];
        List<Apttus_Config2__PriceList__c> PriceListQuery = [SELECT Id,Name FROM Apttus_Config2__PriceList__c];
        system.assertEquals(1, proposalListQuery.size());
        //BindSobject bindobj = new BindSobject();
        try{
        BindSobject.dataBind(proposalListQuery[0].id);
        BindSobject.dataBind(null);
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'dataBind', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
        // BindSobject.createRecordTest(wrapperData);
        Test.stopTest();
    }
    
    @isTest
    static void createRecordTest(){
        Test.startTest();
        BindSobject.SobjectBindWrapper	bso	=	new BindSobject.SobjectBindWrapper();
        bso.personAcc	=	[SELECT FirstName, MiddleName, LastName,PersonBirthdate, Gender__c, Nickname__c, PersonMailingStreet,
                             PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, FirstNameEn__c, LastNameEn__c, ShippingPostalCode,
                             ShippingCity, ShippingState, ShippingStreet, Nationality__c, PersonEmail, Email2__c, ParentEmail__c, PersonHomePhone,
                             PersonMobilePhone, PersonOtherPhone, PersonalID__c, PassportType__c, PassportNumber__c, PassportIssueDate__c,
               				 PassportExpiryDate__c
                             FROM Account][0];
        bso.opp				=	[SELECT SalesOffice__c, Owner.Name FROM Opportunity][0];
        bso.PriceList		=	[SELECT Year__c, Version__c FROM Apttus_Config2__PriceList__c][0];
        bso.Quote			=	[SELECT CurrencyIsoCode FROM Apttus_Proposal__Proposal__c][0];
        bso.age				=	2.8;
        
        //String	jsonString	=	JSON.stringify(bso);
        String	jsonString		=	JSON.serialize(bso);
        system.debug('the json'+jsonString);
        BindSobject.createRecord(jsonString,true,bso.Quote.id);
        BindSobject.GetSalesOffice();
        BindSobject.GetGender();
        BindSobject.GetBookingType();
        BindSobject.GetBookingChannel();
        BindSobject.GetNationality();
        BindSobject.GetPassportType();
       // BindSobject.GetStateValues();
        BindSobject.GetCurrency();
        Account accAssert = [select id, firstname from account][0];
        opportunity oppAssert =	[SELECT SalesOffice__c, Owner.Name FROM Opportunity][0];
        Apttus_Config2__PriceList__c PLAssert =	[SELECT Year__c, Version__c FROM Apttus_Config2__PriceList__c][0];
        Apttus_Proposal__Proposal__c QuoAssert = [SELECT CurrencyIsoCode FROM Apttus_Proposal__Proposal__c][0];
        system.assertEquals(accAssert.firstname, bso.personAcc.firstname);
        system.assertEquals(oppAssert.SalesOffice__c, bso.opp.SalesOffice__c);
        system.assertEquals(PLAssert.Version__c, bso.PriceList.Version__c);
        system.assertEquals(QuoAssert.CurrencyIsoCode, bso.Quote.CurrencyIsoCode);
        //test.setMock(BindSobject.SobjectBindWrapper.class, jsonString);
        //test.setMock(HttpCalloutMock.class, jsonString);
        Test.stopTest();
    }
    
     @isTest
    static void failureRecordTest(){
         Test.startTest();
        BindSobject.SobjectBindWrapper	bso	=	new BindSobject.SobjectBindWrapper();
        bso.personAcc	=	[SELECT FirstName, MiddleName, LastName,PersonBirthdate, Gender__c, Nickname__c, PersonMailingStreet,
                             PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, FirstNameEn__c, LastNameEn__c, ShippingPostalCode,
                             ShippingCity, ShippingState, ShippingStreet, Nationality__c, PersonEmail, Email2__c, ParentEmail__c, PersonHomePhone,
                             PersonMobilePhone, PersonOtherPhone, PersonalID__c, PassportType__c, PassportNumber__c, PassportIssueDate__c,
                PassportExpiryDate__c
                             FROM Account][0];
        bso.opp				=	[SELECT SalesOffice__c, Owner.Name FROM Opportunity][0];
        bso.PriceList		=	[SELECT Year__c, Version__c FROM Apttus_Config2__PriceList__c][0];
        bso.Quote			=	[SELECT CurrencyIsoCode FROM Apttus_Proposal__Proposal__c][0];
        bso.age				=	2.8;
        
        bso.personAcc.Email2__c = 'testemail';
        bso.opp.SalesOffice__c = 'testPicklist';
        bso.PriceList.Version__c = '';
        bso.PriceList.Year__c = '';
       // update bso.PriceList;
        bso.Quote.CurrencyIsoCode	= 'test';
        
        //String	jsonString	=	JSON.stringify(bso);
        String	jsonString		=	JSON.serialize(bso);
        system.debug('the json'+jsonString);
        BindSobject.createRecord(jsonString,true,bso.Quote.id);
        BindSobject.GetSalesOffice();
        BindSobject.GetGender();
        BindSobject.GetBookingType();
        BindSobject.GetBookingChannel();
        BindSobject.GetNationality();
        BindSobject.GetPassportType();
       // BindSobject.GetCountryValues();
        //BindSobject.GetStateValues();
        BindSobject.GetCurrency();
        opportunity oppAssert =	[SELECT SalesOffice__c, Owner.Name FROM Opportunity][0];
        Apttus_Config2__PriceList__c PLAssert =	[SELECT Year__c, Version__c FROM Apttus_Config2__PriceList__c][0];
        Apttus_Proposal__Proposal__c QuoAssert = [SELECT CurrencyIsoCode FROM Apttus_Proposal__Proposal__c][0];
        system.assertNotEquals(oppAssert.SalesOffice__c, bso.opp.SalesOffice__c);
        system.assertNotEquals(PLAssert.Version__c, bso.PriceList.Version__c);
        system.assertNotEquals(QuoAssert.CurrencyIsoCode, bso.Quote.CurrencyIsoCode);
        //test.setMock(BindSobject.SobjectBindWrapper.class, jsonString);
        //test.setMock(HttpCalloutMock.class, jsonString);
        Test.stopTest();
    }
   
}