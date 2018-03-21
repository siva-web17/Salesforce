@isTest
public class CreateBookingControllerTest { 
    public static String market = 'DEB';
    public static String salesOffice1 = 'DEB';
    public static final String testOpportunityName = 'TestOpportunityRecord';

    @testSetup
    static void testDataSetup() {
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        User tAdminUser = TestDataFactory.createAdminUser(True);

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
                    'SalesOffice__c' => salesOffice1,
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues, True);
        }
    }

    static testMethod void dataBindTest() {

        Test.startTest();
        List<Account> AccountListQuery = [SELECT Id,Name FROM Account];
        List<Opportunity> OpportunityListQuery = [SELECT Id,Name FROM Opportunity];
        system.assertEquals(1, OpportunityListQuery.size());
        CreateBookingController.dataBind(OpportunityListQuery[0].id);
        Test.stopTest();
    }

    static testMethod void updateAccountDetailsTest() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{
                tAdminUser.Id
        }, true, false);
        system.runAs(tAdminUser) {
            Test.startTest();
            CreateBookingController.IntermediateScreenWrapper ISW = new CreateBookingController.IntermediateScreenWrapper();
            ISW.personAcc = [
                    SELECT FirstName, MiddleName, LastName,PersonBirthdate, Gender__c, Nickname__c, PersonMailingStreet,
                            PersonMailingPostalCode, PersonMailingState, PersonMailingCountry, FirstNameEn__c, LastNameEn__c, ShippingPostalCode,
                            ShippingCity, ShippingState, ShippingStreet, Nationality__c, PersonEmail, Email2__c, ParentEmail__c, PersonHomePhone,
                            PersonMobilePhone, PersonOtherPhone, PersonalID__c, PassportType__c, PassportNumber__c, PassportIssueDate__c,
                            PassportExpiryDate__c
                    FROM Account
            ][0];
            ISW.opp = [SELECT SalesOffice__c, Owner.Name,AccountId FROM Opportunity][0];
            String jsonString = JSON.serialize(ISW);
            system.debug('the json' + jsonString);
            CreateBookingController.updateAccountDetails(jsonString);
            CreateBookingController.GetSalesOffice();
            CreateBookingController.GetGender();
            Account accAssert = [select id, firstname from account][0];
            opportunity oppAssert = [SELECT SalesOffice__c, Owner.Name,AccountId FROM Opportunity][0];
            Id AccountId;
            system.assertEquals(accAssert.firstname, ISW.personAcc.firstname);
            system.assertEquals(oppAssert.SalesOffice__c, ISW.opp.SalesOffice__c);
            Test.setMock(HttpCalloutMock.class, new MockGenerator_Test());
            Test.stopTest();
        }
    }

    public class MockGenerator_Test implements HttpCalloutMock {
        public HttpResponse respond(HTTPrequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(405);
            res.setStatus('Method Not Allowed');
            return res;
        }
    }
}