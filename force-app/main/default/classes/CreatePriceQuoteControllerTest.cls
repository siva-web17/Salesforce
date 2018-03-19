@isTest
public class CreatePriceQuoteControllerTest {
    public static String market = 'DEB';

    @testSetup
    static void testDataSetup() {
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        User tAdminUser = TestDataFactory.createAdminUser(True);
        system.runAs(tAdminUser) {
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
        }
    }

    static testMethod void openPoseidonToCreateQuoteTest() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{
                tAdminUser.Id
        }, true, false);
        system.runAs(tAdminUser) {
            Test.startTest();
            List<Opportunity> listOpp = new List<Opportunity>();
            Opportunity Oppo1 = new Opportunity();
            Oppo1.Name = 'Test';
            Oppo1.StageName = 'Booking';
            Oppo1.CloseDate = Date.valueOf('2017-01-01');
            listOpp.add(Oppo1);
            insert listOpp;
            List<Account> AccountList = [
                    select id, FirstName,LastName,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,
                            PersonMailingStreet, RecalculateRanking__c, PersonEmail,Email2__c,PersonHomePhone,PersonMobilePhone,
                            PersonOtherPhone,PersonBirthdate,Market__c,Region__c,
                            HasBooking__c
                    from Account
                    limit 1
            ];
            Account accountRecord = new Account();
            Lead leadRecord = new Lead();
            CreatePriceQuoteController objOppClass = new CreatePriceQuoteController(new ApexPages.StandardController(Oppo1));
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([select id,StageName,Name,CloseDate from Opportunity limit 1]);
            objOppClass.returnvalue = 'None';
            objOppClass.RecordId = string.valueOf(AccountList[0].Id);
            system.assertEquals('None', objOppClass.returnvalue);
            objOppClass.openPoseidonToCreateQuote();
            Set<Id> recordIdSet = new Set<Id>();
            Id OppId = Id.valueOf(objOppClass.RecordId);
            recordIdSet.add(OppId);
            List<Task> objTaskList = TasksSelector.getSPQTasksByTaskId(recordIdSet, system.label.SPQTask);
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(system.label.SPQTask).getRecordTypeId();
            Task newTask = new Task();
            newTask.WhatId = Oppo1.Id;
            newTask.Program__c = 'ILS';
            newTask.FollowUpDate__c = Datetime.now();
            system.debug('followup>>>>' + newTask.FollowUpDate__c);
            newTask.ActivityDate = Datetime.now().Date();
            system.debug('ActivityDate>>>>' + newTask.ActivityDate);
            newTask.ActivityDateTime__c = Datetime.now();
            newTask.recordtypeid = recordTypeId;
            newTask.Status = 'Open';
            newTask.Type = 'Call';
            insert newTask;
            System.debug('newTask after' + newTask);
            Test.stopTest();
            Map<Id, Account> accMap = new Map<Id, Account>();
            system.assertEquals(1, AccountList.size());
            for (Account a : AccountList) {
                accMap.put(a.Id, a);
            }
            CreatePriceQuoteController.AccountfieldsForPriceQuote(accountRecord);
            CreatePriceQuoteController.LeadfieldsForPriceQuote(leadRecord);
        }
    }

    static testMethod void createSPQTaskTest() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{
                tAdminUser.Id
        }, true, false);
        system.runAs(tAdminUser) {
            Test.startTest();
            Opportunity Oppo1 = new Opportunity();
            Oppo1.Name = 'Test';
            Oppo1.StageName = 'Booking';
            Oppo1.CloseDate = Date.valueOf('2017-01-01');
            insert Oppo1;

            List<Task> TaskList = new List<Task>();
            Task newTask = new Task();
            newTask.WhatId = Oppo1.Id;
            newTask.FollowUpDate__c = Datetime.now();
            system.debug('followup>>>>' + newTask.FollowUpDate__c);
            newTask.ActivityDate = Datetime.now().Date();
            system.debug('ActivityDate>>>>' + newTask.ActivityDate);
            newTask.ActivityDateTime__c = Datetime.now();
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(system.label.SPQTask).getRecordTypeId();
            newTask.recordtypeid = recordTypeId;
            newTask.Program__c = 'AY';
            newTask.Type = 'SPQ';
            insert newTask;
            system.debug('newTask>>>' + newTask);
            Test.stopTest();
            CreatePriceQuoteController objTaskClass = new CreatePriceQuoteController(new ApexPages.StandardController(newTask));
            objTaskClass.openPoseidonToCreateQuote();
        } 
    }
}