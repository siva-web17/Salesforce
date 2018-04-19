/**
 * Created by Arkadiusz Celej on 04.01.2018.
 */

@IsTest
private class AccountTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void whenDateOfBirthOrLanguageChangeResetLetterAndLabelOnOpportunity() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            //given
            TestDataFactory.TemplateSettingBuilder templateSettingBuilder = new TestDataFactory.TemplateSettingBuilder();
            TemplateSetting__c ts = (TemplateSetting__c) templateSettingBuilder.getRecord();
            ts.Market__c = picklistValuesHelper.market;
            ts.Program__c = picklistValuesHelper.program;
            ts.Language__c = picklistValuesHelper.language;
            templateSettingBuilder.withAge(10);
            templateSettingBuilder.withLetter();
            templateSettingBuilder.withLabel();
            templateSettingBuilder.save();
            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = (Opportunity) oppBuilder.getRecord();
            opp.Market__c = picklistValuesHelper.market;
            opp.SalesOffice__c = picklistValuesHelper.salesOffice;
            opp.Program__c = picklistValuesHelper.program;
            opp.Product__c = picklistValuesHelper.product;
            oppBuilder.withPersonAccount();
            oppBuilder.getAccount().Language__c = picklistValuesHelper.language;
            oppBuilder.save();

            Account personAccount = oppBuilder.getAccount();
            TestDataFactory.TaskBuilder sbrTaskBuilder = new TestDataFactory.TaskBuilder();
            sbrTaskBuilder.withRecordType(TasksHelper.SBR_TASK_DEVELOPER_NAME);
            sbrTaskBuilder.setWhat(oppBuilder.getRecord().Id);
            sbrTaskBuilder.save();
            //when
            Test.startTest();
            personAccount.PersonBirthdate = System.today().addYears(-10);

            update personAccount;
            Test.stopTest();
            //then

            opp = [SELECT Id, Letter__c, Label__c FROM Opportunity WHERE Id = :oppBuilder.getRecord().Id];
            System.assertEquals(templateSettingBuilder.templateLetter.Id, opp.Letter__c, 'Invalid Letter');
            System.assertEquals(templateSettingBuilder.templateLabel.Id, opp.Label__c, 'Invalid Label');
        }
    }

    @isTest
    static void whenAccountHasInactiveOpportunityThenSkipSaveToPoseidonCall(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            ob.withPersonAccount();
            ob.setField('IsActive__c', false);
            ob.save();
            Account personAccount = ob.getAccount();
			Test.setMock(HttpCalloutMock.class, new ExternalRouterMock());
            Test.startTest();
            try {
                Booking__c book = new Booking__c(AccountId__c = personAccount.Id, OpportunityId__c = ob.getRecord().Id);
                insert book;
                personAccount.FirstName = personAccount.FirstName + 'ChangedName';
                update personAccount;
                //System.assert(false);
            }catch (Exception ex){
                String message = ex.getMessage();
                System.assert(message.contains(Label.NoActiveOpportunity));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void whenAccountHasActiveOpportunityThenCallSaveToPoseidon(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ExternalRouterMock());
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            ob.withPersonAccount().save();
            Account personAccount = ob.getAccount();
            Booking__c book = new Booking__c(AccountId__c = personAccount.Id, OpportunityId__c = ob.getRecord().Id);
            insert book;

            Test.startTest();
            personAccount.FirstName = personAccount.FirstName+'ChangedName';
            personAccount.PersonMailingStreet = 'NewStreet';
            personAccount.InvalidEmail__c = true;
            update personAccount;
            Test.stopTest();
        }
    }

    @IsTest
    static void when_InsertedAccountHasMarketNOOAndLangNull_expect_LangIsSet(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser) {

            String expectedLanguageValue = 'NO';

            //given
            Integer numOfAccounts = 5;
            List<Account> accounts = new List<Account>();
            Account acc = new Account();

            for(Integer i = 0; i<numOfAccounts; i++){
                TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
                pab.setField('Market__c', 'NOO');
                accounts.add((Account)pab.getRecord());
            }

            //when
            Test.startTest();
            insert accounts;
            Test.stopTest();

            //then
            accounts = [SELECT Language__c FROM Account];
            for(Account account : accounts){
                System.assertEquals(expectedLanguageValue, account.Language__c, 'Expecting specific Account Language');
            }
        }
    }

    @IsTest
    static void when_UpdatedAccountHasMarketNOOAndLangNull_expect_LangIsSet(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            String startingMarketValue = 'AZB';
            String newMarketValue = 'NOO';
            String expectedLanguageValue = 'NO';

            //given
            Integer numOfAccounts = 5;
            List<Account> accounts = new List<Account>();
            Account acc = new Account();

            for(Integer i = 0; i<numOfAccounts; i++){
                TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
                pab.setField('Market__c', startingMarketValue);
                accounts.add((Account)pab.getRecord());
            }
            insert accounts;
            accounts = [SELECT Market__c, Language__c FROM Account];

            for(Account account : accounts){
                System.assertEquals(startingMarketValue, account.Market__c);
                System.assertEquals(null, account.Language__c);
                account.Market__c = 'NOO';
            }

            //when
            Test.startTest();
            update accounts;
            Test.stopTest();

            //then
            accounts = [SELECT Market__c, Language__c FROM Account];
            for(Account account : accounts){
                System.assertEquals(newMarketValue, account.Market__c, 'Expecting specific Account Market value');
                System.assertEquals(expectedLanguageValue, account.Language__c, 'Expecting specific Account Language value');
            }
        }
    }
}