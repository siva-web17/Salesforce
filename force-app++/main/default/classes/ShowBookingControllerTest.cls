@IsTest
public class ShowBookingControllerTest {

    static testMethod void openBookingTest(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{
               tAdminUser.Id
        }, true, false);
        system.runAs(tAdminUser) {
            Test.startTest();
            String market = 'NOO';
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName',
                    recordTypeId, personAccountFieldValues, True);
            Map<String, String> oppData = new Map<String, String>();
            oppData.put('Market__c', market);
            oppData.put('StageName', 'Booking');
            oppData.put('CloseDate', String.valueOf(System.today().addDays(365)));
            Opportunity opp = TestDataFactory.createOpportunityForAccount(newAccount.Id,
                    'TestOpportunityforAccount', oppData, true);
            List<Booking__c> listBook = new List<Booking__c>();
            Booking__c Book = new Booking__c();
            Book.Name = 'Test';
            Book.AccountId__c = (newAccount.id);
            Book.OpportunityId__c = (opp.id);
            listBook.add(Book);
            insert listBook;
	        ShowBookingController Booking = new ShowBookingController(new ApexPages.StandardController(Book));
            Test.stopTest();
    	}
    }
}