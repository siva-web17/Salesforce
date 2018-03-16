@istest
public class ExternalRouterTest {
    public static String market = 'DEB';
	 @testSetup	
    static void testDataSetup(){
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = APTS_TestDataUtility.getProfile('System Administrator');
        //insert User
        User testUser = APTS_TestDataUtility.createUser(SystemAdminProfile.ID);
    	
        System.runAs(testUser) {
            
            //create Account

            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, True);

        }
    }
    
     @isTest
    static void ExternalRouterSuccess(){
        Test.startTest();
       	List<Account> acc = [SELECT Id, Name FROM Account];
        Test.setMock(HttpCalloutMock.class, new MockGenerator_Test());
        ExternalRouter.callUpdateAccountDetailsService(string.valueOf(acc));
        ExternalRouter.callUpdateAccountFamilyDetailsService(string.valueOf(acc));
        ExternalRouter.callNewAccountFamilyDetailsService(string.valueOf(acc));
        ExternalRouter.callNewSyncToPoseidonService(string.valueOf(acc));
        system.assertEquals(1, acc.size());
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