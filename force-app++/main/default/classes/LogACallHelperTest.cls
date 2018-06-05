@isTest
private class LogACallHelperTest{
    @testSetup static void setup(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        system.runAs(tAdminUser) {
            LogACallHelper obj01 = new LogACallHelper();
            LogACallHelper.allReachedItems = new Set<String>();
            LogACallHelper.allNotReachedItems = new Set<String>();
            LogACallHelper.callTypes = new Set<String>();
            LogACallHelper.emailTypes = new Set<String>();
            LogACallHelper.taskTypes = new Set<String>();
            List<String> oppMarkets = new List<String>(FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c').keySet());
            List<String> accMarkets = new List<String>(FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Market__c').keySet());
            List<String> accLanguages = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Account.getSObjectType().getDescribe().getName(), 'Market__c', 'Language__c').get(accMarkets[0]).keySet());
            Map<String, String> accFieldMap = new Map<String, String>{
                    'Market__c' => accMarkets[0],
                    'Language__c' => accLanguages[0]
            };
            Account acc = TestDataFactory.createAccount('Sample Acc', accFieldMap, true);
            Map<String, String> oppFieldMap = new Map<String, String>{
                    'Market__c' => oppMarkets[0],
                    'StageName' => 'To Contact',
                    'CloseDate' => String.valueOf(Date.today())
            };
            TestDataFactory.createOpportunityForAccount(acc.Id, 'Sample Opp', oppFieldMap, true);
            List<String> leadMarkets = new List<String>(FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c').keySet());
            Map<String, String> leadFieldValues = new Map<String,String>{
                    'Market__c'=>leadMarkets[0]
            };
            Lead lead = TestDataFactory.createLead('LoganAction', 'Test', 'EF', '',leadFieldValues, true);
        }
    }

    static testMethod void testGetTaskSubType(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            LogACallHelper.getTaskSubType(Label.CallReached.toUpperCase());
            LogACallHelper.getTaskSubType(Label.SentEmail.toUpperCase());
            LogACallHelper.getTaskSubType(Label.SocialMediaSent.toUpperCase());
        }
        Test.stopTest();
    }
  static testMethod void testHandleLogAnActionForCallBack(){
      User tAdminUser = TestDataFactory.createAdminUser(True);
      TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
      Test.startTest();
      system.runAs(tAdminUser) {
          Opportunity opportunity = [SELECT Id,Market__c,OwnerId,Program__c FROM Opportunity LIMIT 1];
          List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(), 'Market__c', 'Program__c').get(opportunity.Market__c).keyset());
          Map<String, String> taskFieldMap = new Map<String, String>();
          taskFieldMap.put('SalesAction__c', Label.CallReached);
          taskFieldMap.put('ResultType__c', Label.CallBack);
          taskFieldMap.put('Program__c', programs[0]);
          taskFieldMap.put('CloseMainReason__c', '');
          taskFieldMap.put('FollowUpDate__c', String.valueOf(DateTime.now().addDays(2)));
          Task newTask = TestDataFactory.createTaskForSobject(opportunity.Id, taskFieldMap, false);
          Task systemCallTask = OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opportunity);
          insert systemCallTask;
          LogACallHelper.handleLogAnAction(opportunity.Id, newTask, DateTime.now(), programs[0]);
      }
      Test.stopTest();
  }
    static testMethod void testHandleLogAnActionForCallBackOnLead(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Lead lead = [SELECT Id,Market__c,OwnerId,Program__c FROM Lead LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Lead.getSObjectType().getDescribe().getName(), 'Market__c', 'Program__c').get(lead.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c', Label.CallReached);
            taskFieldMap.put('ResultType__c', Label.CallBack);
            taskFieldMap.put('Program__c', programs[0]);
            taskFieldMap.put('CloseMainReason__c', '');
            taskFieldMap.put('FollowUpDate__c', String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(lead.Id, taskFieldMap, false);
            //Task systemCallTask = LeadsHelper.createSystemCallTaskRecordForLead(lead);
            //insert systemCallTask;
            LogACallHelper.handleLogAnAction(lead.Id, newTask, DateTime.now(), programs[0]);
        }
        Test.stopTest();
    }
    static testMethod void testHandleLogAnActionForCallAppointment(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity opportunity = [SELECT Id,Market__c FROM Opportunity LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(), 'Market__c', 'Program__c').get(opportunity.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c', Label.CallReached);
            taskFieldMap.put('ResultType__c', Label.CallAppointment);
            taskFieldMap.put('Program__c', programs[0]);
            taskFieldMap.put('CloseMainReason__c', '');
            taskFieldMap.put('FollowUpDate__c', String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(opportunity.Id, taskFieldMap, false);
            LogACallHelper.handleLogAnAction(opportunity.Id, newTask, DateTime.now(), programs[0]);
        }
        Test.stopTest();
    }
    
    static testMethod void testHandleLogAnActionForVisit(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
             Opportunity opportunity = [SELECT Id,Market__c FROM Opportunity LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(),'Market__c','Program__c').get(opportunity.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c',Label.CallReached);
            taskFieldMap.put('ResultType__c',Label.Visit);
            taskFieldMap.put('Program__c',programs[0]);
            taskFieldMap.put('CloseMainReason__c','');
            taskFieldMap.put('FollowUpDate__c',String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(opportunity.Id,taskFieldMap,false);
            LogACallHelper.handleLogAnAction(opportunity.Id,newTask,DateTime.now(),programs[0]);
        }
        Test.stopTest();
    }

    static testMethod void testHandleLogAnActionForVisitOnLead(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Lead lead = [SELECT Id,Market__c,OwnerId,Program__c FROM Lead LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(),'Market__c','Program__c').get(lead.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c',Label.CallReached);
            taskFieldMap.put('ResultType__c',Label.Visit);
            taskFieldMap.put('Program__c',programs[0]);
            taskFieldMap.put('CloseMainReason__c','');
            taskFieldMap.put('FollowUpDate__c',String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(lead.Id,taskFieldMap,false);
            LogACallHelper.handleLogAnAction(lead.Id,newTask,DateTime.now(),programs[0]);
        }
        Test.stopTest();
    }
    
    static testMethod void testHandleLogAnActionForClose(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity opportunity = [SELECT Id,Market__c FROM Opportunity LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(), 'Market__c', 'Program__c').get(opportunity.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c', Label.CallReached);
            taskFieldMap.put('ResultType__c', Label.CloseOpp);
            taskFieldMap.put('Program__c', programs[0]);
            taskFieldMap.put('CloseMainReason__c', '');
            taskFieldMap.put('FollowUpDate__c', String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(opportunity.Id, taskFieldMap, false);
            LogACallHelper.handleLogAnAction(opportunity.Id, newTask, DateTime.now(), programs[0]);
        }
        Test.stopTest();
    }
    
    static testMethod void testHandleLogAnActionForChangeProgram(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id}, true, false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity opportunity = [SELECT Id,Market__c FROM Opportunity LIMIT 1];
            List<String> programs = new List<String>(FieldUtilityClass.getFieldDependenciesMap(Opportunity.getSObjectType().getDescribe().getName(),'Market__c','Program__c').get(opportunity.Market__c).keyset());
            Map<String, String> taskFieldMap = new Map<String, String>();
            taskFieldMap.put('SalesAction__c',Label.CallReached);
            taskFieldMap.put('ResultType__c',Label.ChangeProgram);
            taskFieldMap.put('Program__c',programs[0]);
            taskFieldMap.put('CloseMainReason__c','');
            taskFieldMap.put('FollowUpDate__c',String.valueOf(DateTime.now().addDays(2)));
            Task newTask = TestDataFactory.createTaskForSobject(opportunity.Id,taskFieldMap,false);
            LogACallHelper.handleLogAnAction(opportunity.Id,newTask,DateTime.now(),programs[0]);
        }
        Test.stopTest();
    }
}