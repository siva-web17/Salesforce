/**
 * Created by Arkadiusz Celej on 11.01.2018.
 */

@IsTest
private class LeadTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void whenProgramChangesUpdateProgramOnSystemCallTasks() {
        //given
        Integer numberOfLeads = 50;
        TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
        leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
        Lead[] leads = new Lead[]{};
        Task[] systemTasks = new Task[]{};
        for(Integer i = 0 ; i < numberOfLeads; i++){
            leads.add((Lead)leadBuilder.build().getRecord());
            systemTasks.addAll(leadBuilder.tasks);
        }
        insert leads;

        TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
        for(Integer i = 0 ; i < numberOfLeads; i++){
            tb.build();
            tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
            tb.setField('Program__c', picklistValuesHelper.program);
            tb.setWho(leads[i].Id);
            systemTasks.add((Task)tb.getRecord());
        }
        insert systemTasks;

        for(Lead l : leads){
            l.Program__c = picklistValuesHelper.program2;
        }

        //when
        Test.startTest();
        update leads;
        Test.stopTest();

        //then
        Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
        Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
        System.assert(updatedLeads.size() > 0);
        for(Lead l : updatedLeads){
            System.assertEquals(picklistValuesHelper.program2, l.Tasks[0].Program__c,' Incorrect program');
        }
    }

    @isTest
    static void whenOwnerChangesReassignOpenTasks() {
        User u = TestDataFactory.createAdminUser(true);
        System.runAs(u){
            Integer numberOfLeads = 50;
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Lead[] leads = new Lead[]{};
            Task[] systemTasks = new Task[]{};
            for(Integer i = 0 ; i < numberOfLeads; i++){
                leads.add((Lead)leadBuilder.build().getRecord());
            }
            insert leads;
    
            TestDataFactory.TaskBuilder tb = new TestDataFactory.TaskBuilder();
            for(Integer i = 0 ; i < numberOfLeads; i++){
                tb.build();
                tb.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName);
                tb.setWho(leads[i].Id);
                systemTasks.add((Task)tb.getRecord());
            }
            insert systemTasks;
    
            for(Lead l : leads){
                l.OwnerId = u.Id;
            }
    
            Test.startTest();
            update leads;
            Test.stopTest();
    
            Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
            Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
            System.assert(updatedLeads.size() > 0);
            for(Lead l : updatedLeads){
                System.assertEquals(u.Id, l.Tasks[0].OwnerId,'Tasks should be reassigned to new Lead Owner');
            }
        }
    }

    @isTest
    static void whenOwnerChangesCreateSystemCallTasks() {
        User u = TestDataFactory.createAdminUser(true);
        System.runAs(u){
            Integer numberOfLeads = 50;
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            leadBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Lead[] leads = new Lead[]{};
            Task[] systemTasks = new Task[]{};
            for(Integer i = 0 ; i < numberOfLeads; i++){
                leads.add((Lead)leadBuilder.build().getRecord());
            }
            insert leads;
    
            for(Lead l : leads){
                l.OwnerId = u.Id;
            }
    
            Test.startTest();
            update leads;
            Test.stopTest();
    
            Set<Id> leadIds = (new Map<Id, Lead>(leads)).keySet();
            Lead[] updatedLeads = LeadsSelector.getLeadsWithOpenTasks(leadIds, Label.SystemCallTaskRecordTypeDeveloperName);
            System.assert(updatedLeads.size() > 0);
            //for(Lead l : updatedLeads){
            //    System.assertEquals(1, l.Tasks.size(),'Lead should have one and only one system call task');
            //    System.assertEquals(u.Id, l.Tasks[0].OwnerId,'Tasks should be reassigned to new Lead Owner');
            //}
        }
    }

    @isTest
    static void whenLeadCreatedPopulateSalesOfficeProgram(){
        Map<String,String> salesOfficeValues = new Map<String,String>{
                'Market__c'=>'DEB',
                'program__c' => 'AY',
                'SaleOfficeCode__c'=>'DEB'
        };
        SalesOfficeProgram__c salesOffieRecord = TestDataFactory.createSalesOfficeProgram('Name', '' ,salesOfficeValues,true);

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
        List<Lead> leadlist = new List<Lead>();
        Map<String, String> leadFieldValues = new Map<String, String>{
                'program__c' => 'AY',
                'Market__c' => 'DEB',
                'SalesOffice__c'=>'DEB',
                'Email'=>'record@ef.com'
        };
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '', leadFieldValues, true);
            leadlist.add(newLead);
            LeadsHelper.populateSalesOfficeProgram(leadlist);
        }
    }

    @isTest
    static void whenLeadCreatedPopulateSource(){
        Map<String,String> sourceValues = new Map<String,String>{
                'Name'=>'testSource',
                'Market__c'=>'DEB',
                'Code__c'=>'E007'
        };

        Source__c sourceRecord = TestDataFactory.createSource('SourceName', '', sourceValues ,TRUE);

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
        List<Lead> leadlist = new List<Lead>();
        Map<String, String> leadFieldValues = new Map<String, String>{
                'program__c' => 'AY',
                'Market__c' => 'DEB',
                'SalesOffice__c'=>'DEB',
                'Email'=>'record@ef.com',
                'SourceCodeAuto__c'=>'E007'
        };
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '', leadFieldValues, true);
            leadlist.add(newLead);
            LeadsHelper.populateSourceBasedonSourceCodeAuto(leadlist);
        }
    }

    @isTest
    static void whenLeadCreatedPopulateSourceCodeAndPartner(){
        Map<String,String> sourceValues = new Map<String,String>{
                'Name'=>'testSource',
                'Market__c'=>'DEB',
                'Code__c'=>'E007'
        };

        Source__c sourceRecord = TestDataFactory.createSource('SourceName', '', sourceValues ,TRUE);

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
        List<Lead> leadlist = new List<Lead>();
        Map<String, String> leadFieldValues = new Map<String, String>{
                'program__c' => 'AY',
                'Market__c' => 'DEB',
                'SalesOffice__c'=>'DEB',
                'Email'=>'record@ef.com',
                'Source__c'=>sourceRecord.Id,
                'Street'=>'2Main'
        };
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '', leadFieldValues, true);
            leadlist.add(newLead);
            LeadsHelper.populateSourceCodeAutoAndPartnerFromSource(leadlist);
            LeadsHelper.updateHadAddressFilledOnCreation(leadList);
        }
    }

    @isTest
    static void whenLeadCreatedPopulatePublicGroup() {
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            TestDataFactory.createPublicGroup(TRUE, 'DEB_DEB_AYP', 'DEB_DEB_AYP');
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
            List<Lead> leadlist = new List<Lead>();
            Map<String, String> leadFieldValues = new Map<String, String>{
                    'program__c' => 'AYP',
                    'Market__c' => 'DEB',
                    'SalesOffice__c' => 'DEB',
                    'Email' => 'record@ef.com'
            };
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '', leadFieldValues, true);
            leadlist.add(newLead);
            LeadsHelper.createShareRecordsOnInsert(leadlist);
        }
    }

    @isTest
    static void leadSelector(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
            Map<String, String> leadFieldValues = new Map<String, String>{
                    'program__c' => 'AY',
                    'Market__c' => 'DEB',
                    'SalesOffice__c'=>'DEB',
                    'Email'=>'record@ef.com'
            };
            Lead newLead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '',leadFieldValues, true);

            LeadsSelector.leadRecordMap(new List<Id>{newLead.Id});
            LeadsSelector.getNotConvertedLeadMapById(new List<Id>{newLead.Id});
            LeadsSelector.getLeadByConvertedOpportunityId(new Set<Id>{newLead.Id});
        }
    }

    @isTest
     static void whenLeadCreatedPopulateRanking() {
         //User tAdminUser = TestDataFactory.createAdminUser(True);
         //system.runAs(tAdminUser) {
             List<LeadRankingSetting__c> leadRankingSetting = Test.loadData(LeadRankingSetting__c.sObjectType, 'File_LeadRankingSettings');
             List<LegalSettings__c> legalSetting = Test.loadData(LegalSettings__c.sObjectType, 'File_LegalSettings');
        	Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
            Lead leadRec=new Lead();
            leadRec.FirstName = 'tyyu89';
            leadRec.LastName = 'lastname89';
            leadRec.program__c = 'AY';
            leadRec.Market__c = 'DEB';
            leadRec.SalesOffice__c='DEB';
            leadRec.Email='record@ef.com';
            leadRec.ReadyForRanking__c=TRUE;
            leadRec.IsDupeProcessed__c=TRUE;
            leadRec.Ranking__c=5;
            leadRec.RequestType__c='BR';
            insert leadRec;

            RankingHandler.getLeadSettings(new List<Lead>{leadRec});
        //}
     }

    @isTest
    static void whenLeadCreateCheckRanking() {
        //User tAdminUser = TestDataFactory.createAdminUser(True);
        //system.runAs(tAdminUser) {
            List<LeadRankingSetting__c> leadRankingSetting = Test.loadData(LeadRankingSetting__c.sObjectType, 'File_LeadRankingSettings');
            List<LegalSettings__c> legalSetting = Test.loadData(LegalSettings__c.sObjectType, 'File_LegalSettings');
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
            Lead leadRec=new Lead();
            leadRec.FirstName = 'tyyu89';
            leadRec.LastName = 'lastname89';
            leadRec.program__c = 'AY';
            leadRec.Market__c = 'DEB';
            leadRec.SalesOffice__c='DEB';
            leadRec.Email='record@ef.com';
            leadRec.ReadyForRanking__c=TRUE;
            leadRec.IsDupeProcessed__c=TRUE;              
            leadRec.creationType__c='Account';
            leadRec.CreationMethod__c='Excel Import';
            leadRec.RequestType__c='BR';
            insert leadRec;
   
            RankingHandler.getLeadSettings(new List<Lead>{leadRec});         
        //}
    }
	
	@IsTest
    static void when_LeadHasAddressOnCreation_Expect_FlagIsSetToTrue(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfLeads = 10;
            String testAddress = 'Marszalkowska 15';
            Set<Id> leadIds = new Set<Id>();

            List<Lead> leads = new List<Lead>();
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Lead lead = (Lead)leadBuilder.getRecord();
                lead.Street = testAddress;
                leads.add(lead);
                leadBuilder.build();
            }

            //when
            Test.startTest();
            insert leads;
            Test.stopTest();

            //then
            for(Lead lead : leads){
                leadIds.add(lead.Id);
            }
            List<Lead> insertedLeads = [
                    SELECT HadAddressonCreation__c, Address, Street
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            System.assertEquals(numOfLeads, insertedLeads.size());
            for(Integer i = 0; i<numOfLeads; i++){
                System.assertEquals(testAddress, insertedLeads[i].Street);
                System.assertEquals(TRUE, insertedLeads[i].HadAddressonCreation__c);
            }
        }
    }

    @IsTest
    static void When_LeadCreatedFromGlobalActionByUser_Expect_CreateSystemTaskForThisLead() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser) {

            Integer numberOfLeads = 10;
            Id SystemCallTaskRecordType = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            List<Lead> leads = new List<Lead>();

            for(Integer i = 0 ; i < numberOfLeads; i++){
                Lead lead = (Lead)leadBuilder.build().getRecord();
                lead.CreationMethod__c = Label.Lead_CreationMethod_Enteredbyuser;
                leads.add(lead);
            }

            Test.startTest();

            insert leads;

            Test.stopTest();

            List<Task> SystemTasksForLeads = [SELECT Id,RecordTypeId,WhoId,ActivityDate,Type,NextCallType__c From Task];

            System.assert(SystemTasksForLeads.size() == numberOfLeads, 'Amount of Tasks created is equal to number of Lead Created');
            for(Task task : SystemTasksForLeads){
                System.assertEquals(task.RecordTypeId, SystemCallTaskRecordType, 'All Tasks are System Call Task Record Type');
                System.assert(task.ActivityDate == System.today(),'Activity Date is Today');
                System.assert(task.Type == TasksHelper.CALL,'Type is Call');
                System.assert(task.NextCallType__c == TasksHelper.CONTACT_CUSTOMER,'NextCallType is Contact Customer');
            }
        }
    }

	@IsTest
    static void when_LeadDoesNotHaveAddressOnCreation_Expect_FlagIsSetToFalse(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfLeads = 10;

            List<Lead> leads = new List<Lead>();
            Set<Id> leadIds = new Set<Id>();
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            for(Integer i = 0; i < numOfLeads; i++){
                Lead lead = (Lead)leadBuilder.getRecord();
                leads.add(lead);
                leadBuilder.build();
            }

            //when
            Test.startTest();
            insert leads;
            Test.stopTest();

            //then
            for(Lead lead : leads){
                leadIds.add(lead.Id);
            }
            List<Lead> insertedLeads = [
                    SELECT HadAddressonCreation__c, Address, Street
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            System.assertEquals(numOfLeads, insertedLeads.size());
            for(Integer i = 0; i<numOfLeads; i++){
                System.assertEquals(null, insertedLeads[i].Street);
                System.assertEquals(FALSE, insertedLeads[i].HadAddressOnCreation__c);
            }
        }
    }
    
    @IsTest
    static void When_LeadCreatedFromExcelImport_Expect_DoNotCreateSystemTaskForThisLead() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser) {

            Integer numberOfLeads = 10;
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            List<Lead> leads = new List<Lead>();

            for(Integer i = 0 ; i < numberOfLeads; i++){
                Lead lead = (Lead)leadBuilder.build().getRecord();
                lead.CreationMethod__c = Label.Lead_CreationMethod_ExcelImport;
                leads.add(lead);
            }

            Test.startTest();

            insert leads;

            Test.stopTest();

            List<Task> SystemTasksForLeads = [SELECT Id From Task];
            System.assert(SystemTasksForLeads.isEmpty(),'No system Tasks are created for Leads with CreationMethod different than UserCreated');

        }
    }
}