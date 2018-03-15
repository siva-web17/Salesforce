@IsTest(SeeAllData=false)
public class AccountsServiceTest {
    public static String market = 'DEB';
	
    @testSetup	
    static void testDataSetup(){
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        //insert User
        User tAdminUser = TestDataFactory.createAdminUser(True);
        system.runAs(tAdminUser) {
            
          Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
          Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', 
                                                                     recordTypeId, personAccountFieldValues, True);
            map<String, String> oppData	=	new Map<String, String>();
            oppData.put('Market__c', market);
            oppData.put('StageName', 'Booking');
            oppData.put('CloseDate',String.valueOf(System.today().addDays(365)));
            Opportunity opp		=	TestDataFactory.createOpportunityForAccount(newAccount.Id, 
                                                                                'TestOpportunityforAccount', oppData, true);
        }
    }
    
    @isTest
    static void syncAccountDetailsToPoseidonSuccess(){
        Test.startTest();
        List<Account>		accList	=	[SELECT Name, LastModifiedById, CreatedById, Market__c, Region__c, 
                                         PersonHomePhone, PersonMobilePhone, PersonOtherPhone, PersonEmail, 
                                         BillingStreet, ShippingAddress, PersonOtherAddress, PersonMailingAddress,
                                         Email2__c, ShippingStreet, PersonOtherPostalCode, Id, PersonMailingStreet,
                                         PersonMailingCity, PersonMailingPostalCode, PersonMailingCountryCode, 
                                         PersonMailingState, ShippingCity, ShippingState,  Gender__c, Nickname__c, 
                                         Salutation, PersonBirthdate, Nationality__c, Language__c, PassportExpiryDate__c,
                                         OtherNationalities__c, PassportIssueDate__c, PassportNumber__c, PersonalID__c,
                                         LastNameEn__c, IsProtectedIdentity__c, BirthCountryCode__pc, FirstNameEn__c,
                                         MiddleNameEn__c, BirthCity__pc, passportType__c, FirstName, LastName, MiddleName,
                                         DoNotSMS__c, CreatedDate,LastModifiedDate 
                                         FROM ACCOUNT];
        Map<Id, Account>	accMap	=	new Map<Id,Account>();
        system.assertEquals(1, accList.size());
        for(Account a : acclist){
            accMap.put(a.Id, a);
        }
        Test.setMock(HttpCalloutMock.class, new MockGenerator_Test());
        AccountsService.syncAccountDetailsToPoseidon(accMap);
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