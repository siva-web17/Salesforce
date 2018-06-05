@isTest(SeeAllData=false)


private class DCLeadImportTest {

    @isTest
    static void testrule12() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();
            
            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('dfdgvf','testlastname','ffdf','dfgff','001234','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule13() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('gfgbf','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','ertret@email.com','ertgre@email.com','testregion',system.today().adddays(-2));
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule17() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',True, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testNoDupe() {

        system.runAs(TestDataFactory.createUserRecord()) {
            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            system.debug('myLeadidis>>>'+newlead.id);
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',True, system.today(), system.today().adddays(-400));
            insert  newaccount1;
      
             system.debug('myaccountidis>>>'+newaccount1.id);
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            duplicateIncomingLeads.clear();
            objectData.put('001P', duplicateIncomingLeads);
           
            test.startTest();
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            test.stopTest();
        }
    }  
    
        
    @isTest
    static void testrule19() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
            
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenarioone() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','9723445332','9723445332','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
            
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenariotwo() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','97655656565','9833455433','9723445332','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
            
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenariothree() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','7744666333','9833455433','77644433554','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
            
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenarioFour() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','7744666333','77644433554','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    

    @isTest
    static void testforphonescenarioFive() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','77448765544','7744666333','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenariosix() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','9954777444','9845566433','77644433554','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenarioseven() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','98885677644','9954777444','77644433554','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforphonescenarioeight() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','98885677644','66666664655','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testforEmailscenarioone() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','7744666333','77644433554','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testforEmailscenarioTwo() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','Secondstudent2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','7744666333','77644433554','testtritonid','testemail1@email.com','student1@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testforEmailscenarioThree() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','Secondstudent2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','7744666333','77644433554','testtritonid','Secondstudent2@email.com','testemail@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testforEmailscenarioFour() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','Secondstudent2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','fghfh','teststreet','001245','876556778','7744666333','77644433554','testtritonid','testemail@email.com','Secondstudent2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);            
            Test.stopTest();
        }
    }
 
    
    @isTest
    static void testrule6() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','fgfg','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule7() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','002100','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule8() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','ghtyii',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule9() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','hjuuyu',system.today().adddays(-2));
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule20() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','123','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('tyuyrttry','testlastname','tyutuy','yutyubhg','698874','9723445332','7744666333','9954777444','456','student1@email.com','student2@email.com','gyutuyj',system.today());
            newlead1.InsertTime__c=system.now()-1;
            insert  newlead1;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('xyz','testlastname','fghfh','teststreet123','001245','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','rtrfg',false, system.today(), system.today().adddays(-400));
            insert  newaccount1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            List<Object> duplicateAccount = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dupcheck.dc3SearchResult dataSet2 = new dupcheck.dc3SearchResult();
            dataSet2.objectData = (Sobject) newaccount1;
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            //duplicateAccount.add(dataSet2);
            objectData.put('00Q', duplicateIncomingLeads);
            
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule21() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','235645','0012456378','9875641235','2345698741','testtritonid','student1@email.com','student2@email.com','ghgfh',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule25() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','ghjtyj','560048','0012589634','0012456357','0234517856','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule26() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','ytutu','tytuygh','023145','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','hjkyu',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule27() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','560048','@@#$%6745@','@@#$%6745@','@@#$%6745@','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule28() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','testcity','teststreet','560048','0012456358','0235896478','0365896478','testtritonid','yuyuy@ef.com','tyrygh@gmty.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule31() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','ghghuy','testcity','gytygh','032563','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule32() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','tytuyyiu','tyutuy','tyutyu','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule33() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','tyutu','gyutuyt','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today().adddays(-2));
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule36() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('tyututyu','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','yutuytu',system.today().adddays(-3));
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule37() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');
            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertAnotherSetOfLeadRecord('testfirstname','testlastname','tyutuyy','teststreet','560048','0123569874','0214589632','9874563254','testtritonid','student1@email.com','student2@email.com','tyutu',system.today().adddays(-2));
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testForEmailMatch() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');
            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);
            Test.stopTest();
             }
    }

    @isTest
    static void testForAccountAddress() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();
            
            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','testcity','','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',false,system.today(),system.today());
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
                     
            insert objOpp;          
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule29() {

        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            lead newlead1 = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','streettest','560048','9723445332','7744666333','9954777444','testtritonid','EmailTest@email.com','Email2test@email.com','testregion',system.today());
            newlead1.InsertTime__c=datetime.now()-1;
            insert  newlead1;
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newlead1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('00Q', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testrule29foraccount() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','testcity','streettest','560048','9723445332','7744666333','9954777444','testtritonid','testemmail1@email.com','testemail2@email.com','testregion',false,system.today(),system.today());
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
           
            insert objOpp; 
            objOpp.LastAutomationUpdateDateTime__c = system.now();  
            objOpp.stagename ='Follow Up';
            update objOpp;       
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    
    @isTest
    static void testForAccountstreet() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',false,system.today(),system.today());
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
                      
            insert objOpp; 
            objOpp.LastAutomationUpdateDateTime__c = system.now();  
            objOpp.stagename ='Follow Up';
            update objOpp;       
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    

    @isTest
    static void testForAccountPostalCode() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','testcity','teststreet','664553','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',false,system.today(),system.today());
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
          
            insert objOpp; 
            objOpp.LastAutomationUpdateDateTime__c = system.now();  
            objOpp.stagename ='Follow Up';
            update objOpp;       
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }
    

    @isTest
    static void testForAccountforSalesClosed() {
        system.runAs(TestDataFactory.createUserRecord()) {

            Test.startTest();

            List<LeadAccountMapping__c> newLeads1 = Test.loadData(LeadAccountMapping__c.sObjectType, 'File_LeadAccountMapping');
            List<MergeRuleConfig__c> LeadswithRules1 = Test.loadData(MergeRuleConfig__c.sObjectType, 'File_LeadMergeRuleConfig');

            lead newlead = DCTestDataUtil.DynamicinsertNewLeadRecords('testfirstname','testlastname','testcity','teststreet','560048','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',system.today());
            newlead.InsertTime__c=system.now();
            insert newlead;
            Account newaccount1 = DCTestDataUtil.DynamicinsertAnotherSetOfaccountRecord('testfirstname','testlastname','testcity','teststreet','664553','9723445332','7744666333','9954777444','testtritonid','student1@email.com','student2@email.com','testregion',false,system.today(),system.today());
            insert  newaccount1;
            opportunity objOpp = createOpportunityForAccount(newaccount1.id,'sample name',null,false,'DEB','MLY',system.today(),'Follow Up');
            insert objOpp; 
            objOpp.LastAutomationUpdateDateTime__c = system.now();  
            objOpp.stagename = label.salesclosed;
            update objopp;          
             
            Map<String, Object> objectData = new Map<String, Object>();
            List<Object> duplicateIncomingLeads = new List<Object>();
            dupcheck.dc3SearchResult dataSet1 = new dupcheck.dc3SearchResult();
            dataSet1.objectData = (Sobject) newaccount1;
            duplicateIncomingLeads.add(dataSet1);
            objectData.put('001P', duplicateIncomingLeads);
            DCSearchPlugin.processResults('ON_UPLOAD;', newlead.id, objectData);

            Test.stopTest();
        }
    }

    public static Opportunity createOpportunityForAccount(String strAccountId,String strOpportunityName, Map<String, String> mFieldNameToVal, boolean doInsert,string market,string program,date closeDate,string stageName) {
        Opportunity tOpp = new Opportunity();
        tOpp.name = strOpportunityName;
        tOpp.AccountId= strAccountId;
        topp.IsActive__c = true;
        tOpp.Market__c= market;
        tOpp.Program__c= program;
        tOpp.closeDate = closeDate ;
        tOpp.StageName = stageName;
        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Opportunity.fields.getMap();

        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)
                    tOpp.put(strFieldName, Date.valueOf(strVal) );
               /*else if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.DateTime)

                    tOpp.put(strFieldName, DateTime.valueOf(strVal) );*/
                else
                    tOpp.put(strFieldName, strVal);
            }
        }
        if (doInsert)
            insert tOpp;
        return tOpp;
    }



     
    
}