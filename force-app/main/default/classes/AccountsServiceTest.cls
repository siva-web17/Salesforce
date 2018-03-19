@IsTest(SeeAllData=false)
public class AccountsServiceTest {
    public static String market = 'DEB';

    @testSetup 
    static void testDataSetup() {
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
            map<String, String> oppData = new Map<String, String>();
            oppData.put('Market__c', market);
            oppData.put('StageName', 'Booking');
            oppData.put('CloseDate', String.valueOf(System.today().addDays(365)));
            Opportunity opp = TestDataFactory.createOpportunityForAccount(newAccount.Id,
                    'TestOpportunityforAccount', oppData, true);
        }
    }

    @isTest
    static void syncAccountDetailsToPoseidonSuccess() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{
                tAdminUser.Id
        }, true, false);
        system.runAs(tAdminUser) {
            Test.startTest();
            List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
            Set<Id> accountsIds = new Set<Id>();
            for (Account account : accounts) {
                accountsIds.add(account.Id);
            }
            Map<Id, Account> accMap = AccountsSelector.getAccountDetailsbasedonAccountId(accountsIds);
            Test.setMock(HttpCalloutMock.class, new MockGenerator_Test());
            AccountsService.syncAccountDetailsToPoseidon(accMap);
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