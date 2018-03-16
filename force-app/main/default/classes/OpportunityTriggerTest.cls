@isTest
private class OpportunityTriggerTest {
    public static String market = 'DEB';
    public static String salesOffice1 = 'DEB';
    public static final String testOpportunityName = 'TestOpportunityRecord';
    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @testSetup
    static void testDataSetup(){
        Test.startTest();
        //get system admin profile
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        //insert User
        User tAdminUser = TestDataFactory.createAdminUser(True);
        //TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        //creating new public group
        Group	group1	=	new Group(name = 'DEB_DEB_AY',
                type	=	'Regular');
        insert group1;

        system.runAs(tAdminUser) {


            Map<String, String> markets = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c');
            List<String> products = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Product__c').values();
            List<String> salesOffices = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'SalesOffice__c').get(markets.values()[0]);
            List<String> Programs = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'Program__c').get(markets.values()[0]);
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market,
                    'Language__c'	=> 'DE'
            };
            Map<String, String> personAccountFieldValues2 = new Map<String, String>{
                    'Market__c' => 'Atv',
                    'Language__c'	=> 'HU'
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues2, True);
            Account newAccount2 = TestDataFactory.createPersonAccount('SecondTestFirstName', 'SecondTestAccFirstName', recordTypeId, personAccountFieldValues, True);
            string dateValue = string.valueof(System.today());
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => Market,
                    'Product__c' => products[0],
                    'SalesOffice__c' =>salesOffice1,
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue

            };
            Map<String, String> opportunityFieldValues2 = new Map<String, String>{
                    'Market__c' => 'ATV',
                    'Product__c' => products[0],
                    'SalesOffice__c' =>'ATV',
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue

            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues2, True);
            Opportunity newOpportunityPersonAccount2 = TestDataFactory.createOpportunityForAccount(newAccount2.id, 'testOppName', opportunityFieldValues, True);
        }
    }

    @isTest
    static void createShareOnInsertSuccess(){
        Test.startTest();
        List<Opportunity> opplist	=	[SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId, Account.PersonBirthdate,
                TemplateKey__c, OwnerId, IsActive__c FROM Opportunity];
        List<Opportunity> opplist1	=	[SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId,TemplateKey__c,
                OwnerId, IsActive__c
        FROM Opportunity
        WHERE Name=: 'TestOpportunityRecord'];
        List<Opportunity> opplist2	=	[SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId,TemplateKey__c, OwnerId,
                IsActive__c
        FROM Opportunity
        WHERE Name=: 'testOppname'];
        List<Group>		publicGroupList = [Select Id, Name FROM Group ];
        List<Task> newTask = [SELECT ID,Program__c from Task];
        Map<Id,Task>	TaskMap	=	new Map<Id,Task>();
        for(Task T:newTask){
            TaskMap.put(T.Id, T);
        }
        insert newTask;
        //system.assertEquals(newTask, opplist, msg);Program__c
        //system.assertNotEquals(newTask, opplist, 'Task and opportunity program is not matching');*/
        OpportunitiesHelper.createShareOnInsert(oppList);
        OpportunitiesHelper.UpdateMarketCodeOnAccount(opplist1, oppList2);
        Map<Id,Date>	bday	=	new Map<Id,Date>();
        Map<Id,Opportunity>	oppMap	=	new Map<Id,Opportunity>();
        for(Opportunity o:oppList){
            bday.put(o.Id,o.Account.PersonBirthdate);
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
        Map<Id,Opportunity> oppMap1 	=	new Map<Id,Opportunity>();
        for(Opportunity o:oppList1){
            oppMap1.put(o.Id,o);
        }
        Map<Id,Opportunity> oppMap2 	=	new Map<Id,Opportunity>(oppMap1);
        for(Opportunity o:oppList2){
            oppMap2.put(o.Id,o);
        }
        OpportunitiesHelper.setDefaultLetterAndLabel(oppMap1, oppMap2);

        //OpportunitiesHelper.findMatchingTemplateSetting(templateKey, birthday, templateSettings);
        Test.stopTest();
    }

    @isTest
    static void whenOwnerChangesCreateSystemCallTasks() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            Integer numberOfLeads = 50;
            List<Opportunity> opplist	=	[SELECT name, ID,Program__c,SalesOffice__c, RecordSharingKey__c, Market__c, AccountId, Account.PersonBirthdate,
                    TemplateKey__c, OwnerId, IsActive__c FROM Opportunity];
            TestDataFactory.OpportunityBuilder OpportunityBuilder = new TestDataFactory.OpportunityBuilder();
            OpportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Opportunity[] Opp = new Opportunity[]{};
            Task[] systemTasks = new Task[]{};
            for(Integer i = 0 ; i < numberOfLeads; i++){
                Opp.add((Opportunity)OpportunityBuilder.build().getRecord());
            }
            insert Opp;

            for(Opportunity O : Opp){
                O.OwnerId = tAdminUser.Id;
            }

            Test.startTest();
            update Opp;
            Test.stopTest();
            Id recordId;
            List<id>  oppID= new List<id>();
            Set<String> taskRecordTypes = new Set<String>();
            //Set<Id> OpportunityIds = (new Map<Id, Opportunity>(Opp)).keySet();
            Opportunity[] updatedOpportunity = OpportunitiesSelector.getOpportunitiesWithTasksByIdAndTaskRecordType(oppID,taskRecordTypes );
            System.assert(updatedOpportunity.size() == 0);
            for(Opportunity O : updatedOpportunity){
                System.assertEquals(1, O.Tasks.size(),'Opportunity should have one and only one system call task');
                System.assertEquals(tAdminUser.Id, O.Tasks[0].OwnerId,'Task should be reassigned to new Lead Owner');
                OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opplist[0]);
            }
        }
    }

    @isTest
    static void whenProgramChangesUpdateProgramOnSystemCallTasks() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            //given
            Integer numberOfOpportunities = 50;
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            opportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Opportunity[] opportunities = new Opportunity[]{
            };

            for (Integer i = 0; i < numberOfOpportunities; i++) {
                opportunityBuilder.build();
                Opportunity opp = (Opportunity) opportunityBuilder.getRecord();

                opp.Market__c = picklistValuesHelper.market;
                opp.Product__c = picklistValuesHelper.product;
                opp.Program__c = picklistValuesHelper.program;
                opportunities.add(opp);
            }
            insert opportunities;

            Task[] systemTasks = new Task[]{
            };
            TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
            for (Integer i = 0; i < numberOfOpportunities; i++) {
                tb.build();
                tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
                tb.setWhat(opportunities[i].Id);
                systemTasks.add((Task) tb.getRecord());
            }
            insert systemTasks;

            for (Opportunity opp : opportunities) {
                opp.Program__c = picklistValuesHelper.program2;
            }

            //when
            Test.startTest();
            update opportunities;
            Test.stopTest();

            //then
            Set<Id> opportunityIds = (new Map<Id, Opportunity>(opportunities)).keySet();
            opportunities = OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName);
            System.assert(opportunities.size() > 0);
            for (Opportunity opp : opportunities) {
                System.assertEquals(picklistValuesHelper.program2, opp.Tasks[0].Program__c, 'Incorrect program');
            }
        }
    }

    @isTest
    static void whenOwnerChangesReassignOpenTasks() {
        User u = TestDataFactory.createAdminUser(true);

        Integer numberOfOpportunities = 50;
        TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
        opportunityBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Opportunity[] opportunities = new Opportunity[]{};

        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            opportunityBuilder.build();
            Opportunity opp = (Opportunity)opportunityBuilder.getRecord();
            opportunities.add(opp);
        }
        insert opportunities;

        Task[] systemTasks = new Task[]{};
        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfOpportunities; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setField('Program__c', picklistValuesHelper.program);
            tb.setWhat(opportunities[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Opportunity opp : opportunities){
            opp.OwnerId = u.Id;
        }

        //when
        Test.startTest();
        update opportunities;
        Test.stopTest();

        //then
        Set<Id> opportunityIds = (new Map<Id, Opportunity>(opportunities)).keySet();
        opportunities = OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(opportunities.size() > 0);
        for(Opportunity opp : opportunities){
            System.assertEquals(u.Id, opp.Tasks[0].OwnerId,'Incorrect program');
        }
    }
}