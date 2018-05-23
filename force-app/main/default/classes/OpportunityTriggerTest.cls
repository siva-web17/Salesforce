@isTest
private class OpportunityTriggerTest {
    public static String market = 'DEB';
    public static String salesOffice1 = 'DEB';
    public static final String testOpportunityName = 'TestOpportunityRecord';
    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @testSetup
    static void testDataSetup() {
        Test.startTest();
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        User tAdminUser = TestDataFactory.createAdminUser(True);
        Group group1 = new Group(name = 'DEB_DEB_AY',
                type = 'Regular');
        insert group1;
        system.runAs(tAdminUser) {
            Map<String, String> markets = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c');
            List<String> products = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Product__c').values();
            List<String> salesOffices = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'SalesOffice__c').get(markets.values()[0]);
            List<String> Programs = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'Program__c').get(markets.values()[0]);
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market,
                    'Language__c' => 'DE'
            };
            Map<String, String> personAccountFieldValues2 = new Map<String, String>{
                    'Market__c' => 'Atv',
                    'Language__c' => 'HU'
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues2, True);
            Account newAccount2 = TestDataFactory.createPersonAccount('SecondTestFirstName', 'SecondTestAccFirstName', recordTypeId, personAccountFieldValues, True);
            string dateValue = string.valueof(System.today());
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => Market,
                    'Product__c' => products[0],
                    'SalesOffice__c' => salesOffice1,
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue
            };
            Map<String, String> opportunityFieldValues2 = new Map<String, String>{
                    'Market__c' => 'ATV',
                    'Product__c' => products[0],
                    'SalesOffice__c' => 'ATV',
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues2, True);
            Opportunity newOpportunityPersonAccount2 = TestDataFactory.createOpportunityForAccount(newAccount2.id, 'testOppName', opportunityFieldValues, True);
        }
    }

    @isTest
    static void createShareOnInsertSuccess() {
        Test.startTest();
        List<Opportunity> opplist = [
                SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId, Account.PersonBirthdate,
                        TemplateKey__c, OwnerId, IsActive__c
                FROM Opportunity
        ];
        List<Opportunity> opplist1 = [
                SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId,TemplateKey__c,
                        OwnerId, IsActive__c
                FROM Opportunity
                WHERE Name = :'TestOpportunityRecord'
        ];
        List<Opportunity> opplist2 = [
                SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId,TemplateKey__c, OwnerId,
                        IsActive__c
                FROM Opportunity
                WHERE Name = :'testOppname'
        ];
        List<Group> publicGroupList = [Select Id, Name FROM Group];
        List<Task> newTask = [SELECT ID,Program__c from Task];
        Map<Id, Task> TaskMap = new Map<Id, Task>();
        for (Task T : newTask) {
            TaskMap.put(T.Id, T);
        }
        insert newTask;
        OpportunitiesHelper.createShareOnInsert(oppList);
        OpportunitiesHelper.UpdateMarketCodeOnAccount(opplist1, oppList2);
        Map<Id, Date> bday = new Map<Id, Date>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity o : oppList) {
            bday.put(o.Id, o.Account.PersonBirthdate);
            oppMap.put(o.Id, o);
        }
        OpportunitiesHelper.setTemplatesForOpportunities(oppList, bday);
        OpportunitiesHelper.calculateMonths(25, 30);
        OpportunitiesHelper.reassignOpenActivitiesForOpportunities(oppList, oppMap);
        OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opplist[0]);
        OpportunitiesHelper.populateSalesOfficeProgram(oppList);
        OpportunitiesHelper.populateSourceBasedonSorceCodeAuto(oppList);
        OpportunitiesHelper.populateSourceCodeAutoAndPartnerFromSource(oppList);
        OpportunitiesHelper.changeProgramOnSystemCallTasks(oppList, oppMap);
        OpportunitiesHelper.createShareOnUpdateTypes(opplist1, opplist2);
        Map<Id, Opportunity> oppMap1 = new Map<Id, Opportunity>();
        for (Opportunity o : oppList1) {
            oppMap1.put(o.Id, o);
        }
        Map<Id, Opportunity> oppMap2 = new Map<Id, Opportunity>(oppMap1);
        for (Opportunity o : oppList2) {
            oppMap2.put(o.Id, o);
        }
        OpportunitiesHelper.setDefaultLetterAndLabel(oppMap1, oppMap2);
        Test.stopTest();
    }

    @isTest
    static void whenOwnerChangesCreateSystemCallTasks() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){
            User u = TestDataFactory.createAdminUser(true);
            Integer numberOfLeads = 50;
            List<Opportunity> opplist = [
                    SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId, Account.PersonBirthdate,
                            TemplateKey__c, OwnerId, IsActive__c
                    FROM Opportunity
            ];
            TestDataFactory.OpportunityBuilder OpportunityBuilder = new TestDataFactory.OpportunityBuilder();
            OpportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Opportunity[] Opp = new Opportunity[]{
            };
            Task[] systemTasks = new Task[]{
            };
            for (Integer i = 0; i < numberOfLeads; i++) {
                Opp.add((Opportunity) OpportunityBuilder.build().getRecord());
            }
            insert Opp;
            for (Opportunity O : Opp) {
                O.OwnerId = u.Id;
            }
            Test.startTest();
            update Opp;
            Test.stopTest();
            Id recordId;
            List<id> oppID = new List<id>();
            Set<String> taskRecordTypes = new Set<String>();
            Opportunity[] updatedOpportunity = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(oppID, taskRecordTypes);
            System.assert(updatedOpportunity.size() == 0);
            for (Opportunity O : updatedOpportunity) {
                System.assertEquals(1, O.Tasks.size(), 'Opportunity should have one and only one system call task');
                System.assertEquals(u.Id, O.Tasks[0].OwnerId, 'Task should be reassigned to new Lead Owner');
                OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opplist[0]);
            }
        }
    }

    @isTest
    static void whenOpportunityCreatedCloseDateShouldBeUpdated(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true, false);
        System.runAs(adminUser){
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = (Opportunity)ob.getRecord();
            Test.startTest();
            insert opp;
            Test.stopTest();

            opp = [SELECT CloseDate FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(System.today().addMonths(2), opp.CloseDate);
        }
    }

    @isTest
    static void whenOpportunityCreatedByMigrationSkipCloseDateUpdate(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true, false);
        System.runAs(adminUser){
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = (Opportunity)ob.getRecord();
            opp.CloseDate = System.today().addDays(1);
            opp.IsByConversion__c = true;
            Test.startTest();
            insert opp;
            Test.stopTest();

            opp = [SELECT CloseDate FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(System.today().addDays(1), opp.CloseDate);
        }
    }
}