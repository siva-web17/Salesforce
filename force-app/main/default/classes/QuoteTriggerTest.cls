/**
 * Created by thejasvi.a on 3/19/2018.
 */
@IsTest
public class QuoteTriggerTest {
    public static String market = 'DEB';
    public static String salesOffice = 'DEB';
    public static String program = 'AY';

        static testMethod void createQuoteWithEmailSent() {
        List<Quote__c> quoteList = new List<Quote__c>();
        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Id recordTypeSPQId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get('SPQTask').Id;

        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => 'DEB'
        };
        Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, True);
        string dateValue = string.valueof(System.today());
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => market,
                'SalesOffice__c' => salesOffice,
                'Program__c' => program,
                'StageName' => 'Open',
                'Closedate' => dateValue
        }; 
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, 'testOpportunityName', opportunityFieldValues, True);

        Map<String, String> taskValues = new Map<String, String>{
                'Program__c' =>  program,
                'Type' => 'SPQ',
                'Subject' => 'SPQ Record',
                'RecordTypeId' => recordTypeSPQId
        };
        task newTask = TestDataFactory.createTaskForSobject(newOpportunityPersonAccount.Id, taskValues, TRUE);
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Quote__c quoteRec = new quote__c();
        quoteRec.Opportunity__c = newOpportunityPersonAccount.id;
        quoteRec.program__c = 'AY';
        quoterec.SentByEmail__c=TRUE;
        quoterec.QuotePDF__c='description';
        quoterec.QuoteCreatedBy__c=currentUser.Id;
        insert quoteRec;
        QuotesHelper.closeSPQTasksAndCreateNewTaskOnOpportunity(new List<Quote__c>{quoteRec});
    }

}