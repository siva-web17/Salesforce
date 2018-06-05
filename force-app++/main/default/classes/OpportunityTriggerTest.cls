@isTest
private class OpportunityTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void when_OppIsInserted_Expect_OpportunityShareIsCreated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testAccMarket = picklistValuesHelper.market;
            String testOppSalesOffice = picklistValuesHelper.salesOffice;
            String testOppProgram = picklistValuesHelper.program;
            String testGroupDeveloperName = testAccMarket + '_' + testOppSalesOffice + '_' + testOppProgram;

            Group group1 = new Group(
                    DeveloperName = testGroupDeveloperName,
                    Name = testGroupDeveloperName,
                    Type = 'Regular'
            );
            insert group1;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testAccMarket;
            insert accPerson;
            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testAccMarket;
                opp.SalesOffice__c = testOppSalesOffice;
                opp.Program__c = testOppProgram;
                opportunities.add(opp);
                ob.build();
            }

            //when
            Test.startTest();
            insert opportunities;
            Test.stopTest();

            //then
            List<OpportunityShare> opportunityShares = [
                    SELECT
                            UserOrGroupId
                    FROM OpportunityShare
                    WHERE RowCause = 'Manual'
            ];

            System.assertEquals(numOfOpps, opportunityShares.size(),
                    'Expecting specific amount of manually added OpportunityShares');

            List<Id> groupsId  = new List<Id>();
            for(OpportunityShare opportunityShare : opportunityShares){
                groupsId.add(opportunityShare.UserOrGroupId);
            }

            List<Group> groups = [
                    SELECT
                            DeveloperName
                    FROM Group
                    WHERE Id IN :groupsId
            ];

            for(Group gr : groups){
                System.assertEquals(testGroupDeveloperName, gr.DeveloperName,
                        'Expecting Opportunity is shared with specific group');
            }
        }
    }

    @isTest
    static void when_OppIsUpdated_Expect_OpportunityShareIsCreated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testMarket = picklistValuesHelper.market;
            String testSalesOffice = picklistValuesHelper.salesOffice;
            String testProgram = picklistValuesHelper.program;
            String testNewProgram = picklistValuesHelper.program2;
            String testGroupDeveloperName = testMarket + '_' + testSalesOffice + '_' + testProgram;
            String testNewGroupDeveloperName = testMarket + '_' + testSalesOffice + '_' + testNewProgram;

            User u = TestDataFactory.createAdminUser(true);

            Group group1 = new Group(
                    DeveloperName = testGroupDeveloperName,
                    Name = testGroupDeveloperName,
                    Type = 'Regular'
            );
            Group group2 = new Group(
                    DeveloperName = testNewGroupDeveloperName,
                    Name = testNewGroupDeveloperName,
                    Type = 'Regular'
            );

            insert group1;
            insert group2;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testMarket;
            insert accPerson;

            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testMarket;
                opp.SalesOffice__c = testSalesOffice;
                opp.Program__c = testProgram;
                opportunities.add(opp);
                ob.build();
            }
            insert opportunities;
            Set<Id> oppsIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppsIds.add(opportunity.Id);
            }

            opportunities = [SELECT Program__c, IsActive__c, OwnerId FROM Opportunity WHERE Id IN: oppsIds];
            List<OpportunityShare> oldOpportunityShares = [SELECT UserOrGroupId, OpportunityId FROM OpportunityShare];
            List<Id> oldOpportunitySharesIds = new List<Id>();

            System.assertEquals(numOfOpps, [SELECT COUNT() FROM Opportunity],
                    'Checking if specific amount of opps was added');
            System.assertEquals(numOfOpps, [SELECT COUNT() FROM OpportunityShare WHERE RowCause = 'Manual'],
                    'Checking if specific amount of OpportunityShare was added');

            for(OpportunityShare opportunityShare : oldOpportunityShares){
                oldOpportunitySharesIds.add(opportunityShare.Id);
            }

            //when
            Test.startTest();
            for(Opportunity opportunity : opportunities){
                opportunity.Program__c = testNewProgram;
            }
            opportunities[0].IsActive__c = FALSE;
            opportunities[1].OwnerId = u.Id;
            update opportunities;
            Test.stopTest();

            //then
            for(OpportunityShare oppShare : [
                    SELECT IsDeleted
                    FROM OpportunityShare
                    WHERE Id IN :oldOpportunitySharesIds]){
                System.assert(!oppShare.IsDeleted, 'Expecting old Opportunity Shares are deleted');
            }
            List<OpportunityShare> newOpportunityShares = [
                    SELECT UserOrGroupId
                    FROM OpportunityShare
                    WHERE IsDeleted = FALSE AND RowCause = 'Manual'
            ];

            List<Opportunity> newOpportunities = [SELECT RecordSharingKey__c, IsActive__c FROM Opportunity];
            System.assertEquals(numOfOpps, newOpportunityShares.size(), 'Expecting specific amount of OpportunityShare was added');

            List<Id> groupsId  = new List<Id>();
            for(OpportunityShare opportunityShare: newOpportunityShares){
                groupsId.add(opportunityShare.UserOrGroupId);
            }

            List<Group> groups = [
                    SELECT
                            DeveloperName
                    FROM Group
                    WHERE Id IN :groupsId
            ];

            for(Group gr : groups){
                System.assertEquals(testNewGroupDeveloperName, gr.DeveloperName,
                        'Expecting Opportunity is shared with specific group');
            }
        }
    }

    @IsTest
    static void when_TemplateKeyIsUpdated_Expect_DefaultLetterAndLabelSet(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Opportunity[] opportunities = new Opportunity[]{};
            Account[] accounts = new Account[]{};

            Integer numOfOpps = 5;
            Date birthDate = Date.newInstance(1990, 03, 20);
            String testMarket = picklistValuesHelper.market;
            String testLanguage = picklistValuesHelper.language;
            String testProgram = picklistValuesHelper.program;
            String testSalesOffice = picklistValuesHelper.salesOffice;
            String testNewProgram = picklistValuesHelper.program2;
            String testProduct = picklistValuesHelper.product;
            String testTemplateKey = testMarket + '-' + testProgram + '-' + testLanguage;
            String testNewTemplateKey= testMarket + '-' + testNewProgram + '-' + testLanguage;
            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();

            for(Integer i = 0; i < numOfOpps; i++){
                TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
                Account acc = (Account) pab.getRecord();
                acc.PersonBirthdate = birthDate;
                acc.Market__c = testMarket;
                acc.Language__c = testLanguage;
                accounts.add(acc);
            }
            insert accounts;

            for(Account account : accounts){
                Opportunity opp = (Opportunity)opportunityBuilder.getRecord();
                opp.Market__c = testMarket;
                opp.Program__c = testProgram;
                opp.SalesOffice__c = testSalesOffice;
                opp.AccountId = account.Id;
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;
            Set<Id> oppsIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppsIds.add(opportunity.Id);
            }

            opportunities = [SELECT Id, TemplateKey__c FROM Opportunity WHERE Id IN :oppsIds];
            System.assertEquals(testTemplateKey, opportunities[0].TemplateKey__c,
                    'Expecting specific value of TemplateKey__c in inserted Opportunity');

            List<Task> tasks = new List<Task>();
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();

            for(Opportunity opportunity : opportunities){
                Task t = (Task)taskBuilder.withRecordType(Label.SBRTask).getRecord();
                t.Product__c = testProduct;
                t.Program__c = testProgram;
                t.WhatId = opportunity.Id;
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;

            APXTConga4__Conga_Template__c templateLetter = new APXTConga4__Conga_Template__c(
                    Market__c = testMarket,
                    Language__c = testLanguage,
                    Program__c = testNewProgram,
                    APXTConga4__Template_Type__c = 'Letter'
            );

            APXTConga4__Conga_Template__c templateLabel = new APXTConga4__Conga_Template__c(
                    Market__c = testMarket,
                    Language__c = testLanguage,
                    Program__c = testNewProgram,
                    APXTConga4__Template_Type__c = 'Label'
            );
            insert templateLabel;
            insert templateLetter;

            List<APXTConga4__Conga_Template__c> conga_templateLetter = [
                    SELECT Id
                    FROM APXTConga4__Conga_Template__c
                    WHERE APXTConga4__Template_Type__c = 'Letter' AND Id = :templateLetter.Id
            ];

            List<APXTConga4__Conga_Template__c> conga_templateLabel = [
                    SELECT Id
                    FROM APXTConga4__Conga_Template__c
                    WHERE APXTConga4__Template_Type__c = 'Label' AND Id = :templateLabel.Id
            ];

            TemplateSetting__c ts = new TemplateSetting__c(
                    Market__c = testMarket,
                    Language__c = testLanguage,
                    Program__c = testNewProgram,
                    IsActive__c = TRUE,
                    Letter__c = conga_templateLetter[0].Id,
                    Label__c = conga_templateLabel[0].Id,
                    AgeFromYears__c = 27,
                    AgeFromMonths__c = 1,
                    AgeToYears__c = 30,
                    AgeToMonths__c = 1
            );
            insert ts;

            List<TemplateSetting__c> templateSettings = [SELECT TemplateKey__c FROM TemplateSetting__c WHERE Id = :ts.Id];
            System.assertEquals(testNewTemplateKey, templateSettings[0].TemplateKey__c,
                    'Expecting specific value of TemplateKey__c in inserted TemplateSetting__c');

            opportunities = [SELECT Program__c FROM Opportunity WHERE Id IN :oppsIds];

            //when
            Test.startTest();
            for(Opportunity opportunity : opportunities){
                opportunity.Program__c = testNewProgram;
            }
            update opportunities;
            Test.stopTest();

            //then
            for(Opportunity opps: [SELECT Letter__c, Label__c FROM Opportunity WHERE Id IN :oppsIds]){
                System.assertEquals(conga_templateLetter[0].Id, opps.Letter__c,
                        'Expecting specific value of field in updated Opportunity');
                System.assertEquals(conga_templateLabel[0].Id, opps.Label__c,
                        'Expecting specific value of field in updated Opportunity');
            }
        }
    }

    @isTest
    static void when_OppProgramIsChanged_Expect_SystemCallTaskAreUpdated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testAccMarket = picklistValuesHelper.market;
            String testOppSalesOffice = picklistValuesHelper.salesOffice;
            String testOppProgram = picklistValuesHelper.program;
            String testNewOppProgram = picklistValuesHelper.program2;
            Id taskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testAccMarket;
            insert accPerson;
            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testAccMarket;
                opp.SalesOffice__c = testOppSalesOffice;
                opp.Program__c = testOppProgram;
                opportunities.add(opp);
                ob.build();
            }
            insert opportunities;
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }

            opportunities = [SELECT Program__c FROM Opportunity WHERE Id IN :oppIds];
            System.assertEquals(numOfOpps, opportunities.size(), 'Checking if specific amount of opportunities was added');

            List<Task> tasks = new List<Task>();
            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();

            for(Opportunity opportunity : opportunities){
                Task t = (Task)taskBuilder.withRecordType(Label.SystemCallTaskRecordTypeDeveloperName).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.WhatId = opportunity.Id;
                tasks.add(t);
                taskBuilder.build();
            }
            insert tasks;
            Set<Id> taskIds = new Set<Id>();
            for(Task task : tasks){
                taskIds.add(task.Id);
            }

            tasks = [SELECT RecordTypeId FROM Task WHERE Id IN :taskIds];
            System.assertEquals(numOfOpps, tasks.size(), 'Checking if specific amount of tasks was added');

            for(Task task : tasks){
                System.assertEquals(taskRecordTypeId, task.RecordTypeId, 'Checking if specific task type was added');
            }

            //when
            Test.startTest();
            for(Opportunity opportunity : opportunities){
                opportunity.Program__c = testNewOppProgram;
            }
            update opportunities;
            Test.stopTest();

            //then
            opportunities = [SELECT Program__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(testNewOppProgram, opportunity.Program__c, 'Checking if Opp program was successfully changed');
            }

            tasks = [SELECT Program__c FROM Task WHERE Id IN :taskIds];
            for(Task task : tasks){
                System.assertEquals(testNewOppProgram, task.Program__c, 'Expecting specific value of updated task');
            }
        }
    }

    @isTest
    static void when_OwnerIsChanged_Expect_TaskAndEventsAreReassigned() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            User u = TestDataFactory.createAdminUser(true);
            Integer numberOfOpportunities = 5;

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            oppBuilder.setDefaultPicklistHelper(picklistValuesHelper);
            Opportunity[] Opp = new Opportunity[]{};

            for (Integer i = 0; i < numberOfOpportunities; i++){
                Opp.add((Opportunity) oppBuilder.build().getRecord());
            }
            insert Opp;
            List<Id> oppIds = new List<Id>();
            for(Opportunity opportunity : Opp){
                oppIds.add(opportunity.Id);
            }

            TestDataFactory.TaskBuilder taskBuilder = new TestDataFactory.TaskBuilder();
            List<Task> tasks = new List<Task>();

            TestDataFactory.EventBuilder eventBuilder = new TestDataFactory.EventBuilder();
            List<Event> events = new List<Event>();

            for(Opportunity opportunities :[SELECT Id FROM Opportunity WHERE Id IN :oppIds]){
                Task t = (Task)taskBuilder.withRecordType(Label.SBRTask).getRecord();
                t.Product__c = picklistValuesHelper.product;
                t.Program__c = picklistValuesHelper.program;
                t.WhatId = opportunities.Id;
                tasks.add(t);
                taskBuilder.build();

                Event e = (Event)eventBuilder.setWhat(opportunities.Id).getRecord();
                events.add(e);
                eventBuilder.build();
            }
            insert tasks;
            insert events;

            //when
            Test.startTest();
            for (Opportunity O : Opp) {
                O.OwnerId = u.Id;
            }
            update Opp;
            Test.stopTest();

            //then
            Opportunity[] updatedOpportunity = OpportunitiesSelector.getAllEventsAndTasksforOpportunity(oppIds);

            System.assertEquals(numberOfOpportunities, updatedOpportunity.size());
            for (Opportunity o : updatedOpportunity) {
                System.assertEquals(1, o.Tasks.size(), 'Expecting Opportunity should have specific number of tasks');
                System.assertEquals(1, o.Events.size(), 'Expecting Opportunity should have specific number of events');
                System.assertEquals(u.Id, o.Tasks[0].OwnerId, 'Expecting Task should have specific owner');
                System.assertEquals(u.Id, o.Events[0].OwnerId, 'Expecting Event should have specific owner');
            }
        }
    }

    @isTest
    static void when_OppIsInsertedAndMatchingSalesOfficeRecordExists_Expect_SalesOfficeFieldIsPopulated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testAccMarket = picklistValuesHelper.market;
            String testOppSalesOffice = picklistValuesHelper.salesOffice;
            String testOppProgram = picklistValuesHelper.program;
            String testGroupDeveloperName = testAccMarket + '_' + testOppSalesOffice + '_' + testOppProgram;
            String testSharingKey = testAccMarket + '-' + testOppSalesOffice + '-' + testOppProgram;

            SalesOfficeProgram__c salesOfficeProgram = new SalesOfficeProgram__c(
                    Market__c = testAccMarket,
                    Program__c = testOppProgram,
                    SaleOfficeCode__c = testOppSalesOffice
            );
            insert salesOfficeProgram;

            List<SalesOfficeProgram__c> salesOfficePrograms = [
                    SELECT Id, Name FROM SalesOfficeProgram__c WHERE Id = :salesOfficeProgram.Id
            ];
            System.assertEquals(1, salesOfficePrograms.size(),
                    'Checking if SalesOfficeProgram record was added successfully');
            System.assertEquals(testGroupDeveloperName, salesOfficePrograms[0].Name);

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testAccMarket;
            insert accPerson;
            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testAccMarket;
                opp.SalesOffice__c = testOppSalesOffice;
                opp.Program__c = testOppProgram;
                opportunities.add(opp);
                ob.build();
            }

            //when
            Test.startTest();
            insert opportunities;
            Test.stopTest();

            //then
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT SalesOfficeProgram__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(salesOfficePrograms[0].Id, opportunity.SalesOfficeProgram__c,
                        'Expecting Opp SalesOfficeProgram is the same as Opp RecordSharingKey');
            }
        }
    }

    @isTest
    static void when_OppIsInsertedAndMatchingSourceRecordExists_Expect_PartnerFieldIsPopulated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testAccMarket = picklistValuesHelper.market;
            String testOppSalesOffice = picklistValuesHelper.salesOffice;
            String testOppProgram = picklistValuesHelper.program;
            String testOppSourceCodeAuto = '12345678';
            String testGroupDeveloperName = testAccMarket + '_' + testOppSalesOffice + '_' + testOppProgram;
            String testSharingKey = testAccMarket + '-' + testOppSalesOffice + '-' + testOppProgram;

            Source__c source = new Source__c(
                    Name = 'Source Name',
                    Code__c = testOppSourceCodeAuto,
                    AvailableforExcelImport__c = FALSE,
                    AvailableforManualEntry__c = FALSE,
                    Market__c = testAccMarket
            );
            insert source;
            List<Source__c> sources = [SELECT Name FROM Source__c WHERE Id = :source.Id];
            System.assertEquals(1, sources.size(), 'Checking if Source was added successfully');

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testAccMarket;
            insert accPerson;
            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testAccMarket;
                opp.SalesOffice__c = testOppSalesOffice;
                opp.Program__c = testOppProgram;
                opp.SourceCodeAuto__c = testOppSourceCodeAuto;
                opportunities.add(opp);
                ob.build();
            }

            //when
            Test.startTest();
            insert opportunities;
            Test.stopTest();

            //then
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT Partner__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(sources[0].Name, opportunity.Partner__c,
                        'Expecting Opp Partner is the same as Related source Name');
            }
        }
    }

    @isTest
    static void when_OppIsInsertedAndMatchingSourceRecordExists_Expect_PartnerAndSourceCodeAutoFieldsArePopulated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 5;
            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            List<Opportunity> opportunities = new List<Opportunity>();
            String testAccMarket = picklistValuesHelper.market;
            String testOppSalesOffice = picklistValuesHelper.salesOffice;
            String testOppProgram = picklistValuesHelper.program;
            String testOppSourceCodeAuto = '12345678';

            Source__c source = new Source__c(
                    Name = 'Source Name',
                    Code__c = testOppSourceCodeAuto,
                    AvailableforExcelImport__c = FALSE,
                    AvailableforManualEntry__c = FALSE,
                    Market__c = testAccMarket
            );
            insert source;
            List<Source__c> sources = [SELECT Name, Code__c FROM Source__c WHERE Id = :source.Id];
            System.assertEquals(1, sources.size(), 'Checking if Source was added successfully');

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().getRecord();
            accPerson.Market__c = testAccMarket;
            insert accPerson;
            List<Account> accounts = [SELECT Market__c FROM Account WHERE Id = :accPerson.Id];

            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)ob.getRecord();
                opp.AccountId = accounts[0].Id;
                opp.Market__c = testAccMarket;
                opp.SalesOffice__c = testOppSalesOffice;
                opp.Program__c = testOppProgram;
                opp.Source__c = sources[0].Id;
                opportunities.add(opp);
                ob.build();
            }

            //when
            Test.startTest();
            insert opportunities;
            Test.stopTest();

            //then
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT Partner__c, SourceCodeAuto__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(sources[0].Name, opportunity.Partner__c,
                        'Expecting Opp Partner is the same as Related source Name');
                System.assertEquals(sources[0].Code__c, opportunity.SourceCodeAuto__c,
                        'Expecting Opp SourceCodeAuto is the same as Related source Code');
            }
        }
    }

    @isTest
    static void when_AccountNameIsChanged_Expect_RelatedOpportunitiesNameAreChanged() {

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id}, true, true);
        System.runAs(adminUser){

            //given
            Integer numberOfRecords = 5;
            String newFirstName = 'ChangedFirstName';
            String newLastName = 'ChangedLastName';
            String newOppName= newFirstName + ' ' + newLastName;

            List<Account> accounts = new List<Account>();
            List<Account> accountsToUpdate = new List<Account>();
            List<Opportunity> opportunities = new List<Opportunity>();

            for(Integer i = 0; i<numberOfRecords; i++){
                TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
                pab.setField('FirstName', 'TestFirstName' + i).setField('LastName', 'TestLastName' + i);
                Account testAccount = (Account)pab.getRecord();
                accounts.add(testAccount);
            }
            insert accounts;
            Set<Id> accIds = new Set<Id>();
            for(Account account : accounts){
                accIds.add(account.Id);
            }
            accounts = [SELECT Id FROM Account WHERE Id = :accIds];
            System.assertEquals(numberOfRecords, accounts.size(), 'Checking if accounts were added successfully');

            for(Integer i = 0; i<numberOfRecords; i++){
                Opportunity testOpp = (Opportunity)(new TestDataFactory.OpportunityBuilder()).getRecord();
                testOpp.AccountId = accounts[i].Id;
                opportunities.add(testOpp);
            }
            insert opportunities;
            System.assertEquals(numberOfRecords, opportunities.size(), 'Checking if accounts were added successfully');

            //when
            Test.startTest();
            for(Account account : accounts){
                account.FirstName = newFirstName;
                account.LastName = newLastName;
                accountsToUpdate.add(account);
            }
            update accountsToUpdate;
            Test.stopTest();

            //then
            List<Opportunity> changedOpportunities = [
                    SELECT Name
                    FROM Opportunity
                    WHERE Name =:newOppName
            ];
            System.assertEquals(numberOfRecords, changedOpportunities.size(),
                    'Expecting specific amount of opportunities matching criteria');
        }
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
	
    @isTest
    static void when_OppIsSetToInactive_Expect_DateOfDeactivationIsSet(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 3;
            Opportunity[] opportunities = new Opportunity[]{};

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(TRUE, opportunity.IsActive__c, 'Expecting added opp is active');
                System.assertEquals(null, opportunity.DateOfDeactivation__c, 'Expecting added opp is null');
                opportunity.IsActive__c = FALSE;
            }

            //when
            Test.startTest();
            update opportunities;
            Test.stopTest();

            //then
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(FALSE, opportunity.IsActive__c, 'Expecting added opp is not active');
                System.assertNotEquals(null, opportunity.DateOfDeactivation__c, 'Expecting Date of deactivation is not null');
                System.assert(opportunity.DateOfDeactivation__c >Datetime.now().addHours(-1));
            }
        }
    }

    @isTest
    static void when_OppIsSetActive_Expect_DateOfDeactivationIsSetToNull(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 3;
            Opportunity[] opportunities = new Opportunity[]{};

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opp.IsActive__c = FALSE;
                opp.DateOfDeactivation__c = Datetime.now()-1;
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);   
            }   
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];

            for(Opportunity opportunity : opportunities){
                System.assertEquals(FALSE, opportunity.IsActive__c, 'Expecting added opp is not active');
                System.assertNotEquals(null, opportunity.DateOfDeactivation__c, 'Expecting added opp is not null');
                opportunity.IsActive__c = TRUE;
            }

            //when
            Test.startTest();
            update opportunities;
            Test.stopTest();

            //then
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(TRUE, opportunity.IsActive__c);
                System.assertEquals(null, opportunity.DateOfDeactivation__c, 'Expecting Date of deactivation is null');
            }
        }
    }
    @isTest
    static void when_OppIsSetToInactive_Expect_DateOfDeactivationIsSet(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 3;
            Opportunity[] opportunities = new Opportunity[]{};

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(TRUE, opportunity.IsActive__c, 'Expecting added opp is active');
                System.assertEquals(null, opportunity.DateOfDeactivation__c, 'Expecting added opp is null');
                opportunity.IsActive__c = FALSE;
            }

            //when
            Test.startTest();
            update opportunities;
            Test.stopTest();

            //then
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(FALSE, opportunity.IsActive__c, 'Expecting added opp is not active');
                System.assertNotEquals(null, opportunity.DateOfDeactivation__c, 'Expecting Date of deactivation is not null');
                System.assert(opportunity.DateOfDeactivation__c >Datetime.now().addHours(-1));
            }
        }
    }

    @isTest
    static void when_OppIsSetActive_Expect_DateOfDeactivationIsSetToNull(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            Integer numOfOpps = 3;
            Opportunity[] opportunities = new Opportunity[]{};

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < numOfOpps; i++){
                Opportunity opp = (Opportunity)opportunityBuilder.withPersonAccount().getRecord();
                opp.IsActive__c = FALSE;
                opp.DateOfDeactivation__c = Datetime.now()-1;
                opportunities.add(opp);
                opportunityBuilder.build();
            }
            insert opportunities;
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opportunity : opportunities){
                oppIds.add(opportunity.Id);
            }
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];

            for(Opportunity opportunity : opportunities){
                System.assertEquals(FALSE, opportunity.IsActive__c, 'Expecting added opp is not active');
                System.assertNotEquals(null, opportunity.DateOfDeactivation__c, 'Expecting added opp is not null');
                opportunity.IsActive__c = TRUE;
            }

            //when
            Test.startTest();
            update opportunities;
            Test.stopTest();

            //then
            opportunities = [SELECT IsActive__c, DateOfDeactivation__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opportunity : opportunities){
                System.assertEquals(TRUE, opportunity.IsActive__c);
                System.assertEquals(null, opportunity.DateOfDeactivation__c, 'Expecting Date of deactivation is null');
            }
        }
    }
}
