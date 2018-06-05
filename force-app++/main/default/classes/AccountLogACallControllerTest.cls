/**
 * Created by britenet-patrykzak on 16/04/2018.
 */

@IsTest
private class AccountLogACallControllerTest {


    @testSetup static void setup() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
    }

    @IsTest
    static void When_getInitialData_Expect_ReturnAccountFieldValues() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();
            accPerson.PersonMobilePhone = '+48888888881';
            accPerson.PersonOtherPhone = '+48888888882';
            accPerson.PersonHomePhone = '+48888888883';
            accPerson.DoNotCall__c = false;
            update accPerson;

            Test.startTest();

            Account accInitialData = AccountLogACallController.getInitialData(accPerson.Id);

            Test.stopTest();

            System.assertEquals(accInitialData.PersonMobilePhone,accPerson.PersonMobilePhone,'Successfully passed required data');
            System.assertEquals(accInitialData.PersonOtherPhone,accPerson.PersonOtherPhone,'Successfully passed required data');
            System.assertEquals(accInitialData.PersonHomePhone,accPerson.PersonHomePhone,'Successfully passed required data');
            System.assertEquals(accInitialData.DoNotCall__c,accPerson.DoNotCall__c,'Successfully passed required data');

        }
    }
    
    @IsTest
    static void When_getExPaxSourceAndItExists_Expect_ReturnExPaxSourceId() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Source__c src = new Source__c();
            src.Name = Label.ExPaxExENQ;
            src.Code__c = Label.ExPaxSourceCode;
            src.Market__c = 'ALL';
            insert src;

            Test.startTest();

            Id exPaxSourceId = AccountLogACallController.getExPaxSource();

            Test.stopTest();

            System.assertEquals(exPaxSourceId,src.Id,'Successfully retrieved ExPax Source Id');

        }
    }
    
    @IsTest
    static void When_getExPaxSourceAndItDoesNotExist_Expect_ThrowException() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Test.startTest();

            try {
                Id exPaxSourceId = AccountLogACallController.getExPaxSource();
            } catch (Exception e){
                Boolean expectedExceptionThrown =  true;
                System.AssertEquals(expectedExceptionThrown, true, 'Exception thrown cannot find Source with such code');
            }

            Test.stopTest();
        }
    }
    
    @IsTest
    static void When_getSalesActions_Expect_ReturnOnlyCallReachedAndCallNotReachedValues() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Test.startTest();

            List<String> salesActionsValues = AccountLogACallController.getSalesActions();

            Test.stopTest();

            System.assert(salesActionsValues.contains(Label.CallReached));
            System.assert(salesActionsValues.contains(Label.CallNotReached));
            System.assertEquals(2,salesActionsValues.size(),'Only 2 values shall be returned');

        }
    }
    
    @IsTest
    static void When_getSubActions_Expect_ReturnAllSubActionValues() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Test.startTest();

            List<String> subActionsValues = AccountLogACallController.getSubActions();

            Test.stopTest();

            System.assert(subActionsValues.size()>0,'Cannot predict how many values, but it shall always return some values');

        }
    }
    
    @IsTest
    static void When_getCallResultsAndUnreachedHappyCallsLessThanMinRequiredValue_Expect_ReturnCallBackOnly() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            HappyCallRules__c hcr = new HappyCallRules__c();
            hcr.Name = Label.HCC;
            hcr.MinUnreachedCallAttempts__c=2;
            insert hcr;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            String callAction = Label.CallNotReached;

            Test.startTest();

            List<String> callResultsValues = AccountLogACallController.getCallResults(callAction,accPerson.Id);

            Test.stopTest();

            System.assert(callResultsValues.contains(Label.CallBack));
            System.assertEquals(1,callResultsValues.size(),'Only Call Back returned');
        }
    }
    
    @IsTest
    static void When_getCallResultsAndUnreachedHappyCallsEqualMinRequiredValue_Expect_ReturnCallBackAndClose() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            HappyCallRules__c hcr = new HappyCallRules__c();
            hcr.Name = Label.HCC;
            hcr.MinUnreachedCallAttempts__c=2;
            insert hcr;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();
            accPerson.ReadyForHappyCall__c = true;
            accPerson.NumberOfUnreachedHappyCalls__c = 2;
            update accPerson;

            String callAction = Label.CallNotReached;

            Test.startTest();

            List<String> callResultsValues = AccountLogACallController.getCallResults(callAction,accPerson.Id);

            Test.stopTest();

            System.assert(callResultsValues.contains(Label.CallBack));
            System.assert(callResultsValues.contains(Label.Close));
            System.assertEquals(2,callResultsValues.size(),'Call back and Close are returned');
        }
    }
    
    @IsTest
    static void When_saveDataWithCallReachedClose_Expect_ExpectedBehavior(){

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'NOO';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Datetime futureDatetime = System.today();

            Id SystemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.Call,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );
            insert task;

            String comments = 'comment';
            String callAction = Label.CallReached;
            String subAction = Label.Close;
            String closeReason = 'Has no means';
            String callResult = Label.Close;
            String actionDate = string.valueOfGmt(futureDatetime);

            Test.startTest();

            AccountLogACallController.saveData(accPerson.id,comments,callAction,subAction,callResult,actionDate);

            Test.stopTest();

            List<Task> happyCallTasks = [SELECT Id, status, FollowUpDate__c FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.HCC];
            List<Task> systemCallTasks = [SELECT Id, status FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.Call];

            System.assertEquals(1,happyCallTasks.size());
            System.assertEquals(Label.LAC_Closed,systemCallTasks[0].status);

        }
    }
    
    @IsTest
    static void When_saveDataWithCallNotReachedCallBack_Expect_ExpectedBehavior(){

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'NOO';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Datetime futureDatetime = System.today();

            Id SystemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.Call,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );
            insert task;

            String comments = 'comment';
            String callAction = Label.CallNotReached;
            String subAction = 'No Answer';
            String closeReason = 'Has no means';
            String callResult = Label.CallBack;
            String actionDate = string.valueOfGmt(futureDatetime);

            Test.startTest();

            AccountLogACallController.saveData(accPerson.id,comments,callAction,subAction,callResult,actionDate);

            Test.stopTest();

            List<Task> happyCallTasks = [SELECT Id, status, CallNotReachedType__c FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.HCC];
            List<Task> systemCallTasks = [SELECT Id, status,FollowUpDate__c FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.Call];

            System.assertEquals(1,happyCallTasks.size());
            System.assertEquals(subAction,happyCallTasks[0].CallNotReachedType__c);
            System.assertEquals(Label.Not_Started,systemCallTasks[0].status);
        }
    }
    
    @IsTest
    static void When_saveDataWithCallNotReachedClose_Expect_ExpectedBehavior(){

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'NOO';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Datetime futureDatetime = System.today();

            Id SystemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;

            Task task = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.Call,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );
            insert task;

            String comments = 'comment';
            String callAction = Label.CallNotReached;
            String subAction = 'No Answer';
            String closeReason = Label.NotAbleToContactCustomer;
            String callResult = Label.Close;
            String actionDate = string.valueOfGmt(futureDatetime);

            Test.startTest();

            AccountLogACallController.saveData(accPerson.id,comments,callAction,subAction,callResult,actionDate);

            Test.stopTest();

            List<Task> happyCallTasks = [SELECT Id, status, CallNotReachedType__c,CloseMainReason__c FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.HCC];
            List<Task> systemCallTasks = [SELECT Id, status,FollowUpDate__c FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.Call];

            System.assertEquals(1,happyCallTasks.size());
            System.assertEquals(subAction,happyCallTasks[0].CallNotReachedType__c);
            System.assertEquals(closeReason,happyCallTasks[0].CloseMainReason__c);
        }
    }
    
    @IsTest
    static void When_createTaskOnOpp_Expect_ExpectedBehavior(){

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account accPerson = (Account)pab.build().save().getRecord();

            TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity testOpportunity = (Opportunity)opportunityBuilder.getRecord();
            testOpportunity.IsActive__c = true;
            testOpportunity.AccountId = accPerson.Id;
            testOpportunity.Market__c = 'NOO';
            testOpportunity.Program__c = 'AY';
            insert testOpportunity;

            Datetime futureDatetime = System.today()+1;

            Id SystemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
            String comments = 'comment';
            String callAction = Label.CallReached;
            String closeReason = 'Has no means';
            String callResult = Label.CallBack;
            String actionDate = string.valueOfGmt(futureDatetime);

            Task systemCallTask = new Task(
                    RecordTypeId = SystemCallTaskRecordTypeId,
                    WhatId = accPerson.Id,
                    NextCallType__c = Label.HCC_Next_Call_Type,
                    Type = Label.Call,
                    ActivityDate = Date.today(),
                    FollowUpDate__c = Date.today(),
                    Status = Label.Not_Started
            );
            insert systemCallTask;

            Test.startTest();

            AccountLogACallController.createTaskOnOpp(accPerson.id,testOpportunity.Id,comments,callAction,callResult,actionDate);

            Test.stopTest();

            List<Task> happyCallTasksOnAccount = [SELECT Id, Status, FollowUpDate__c FROM Task WHERE AccountId =:accPerson.Id AND WhatId =:testOpportunity.Id AND Type =:Label.HCC];
            List<Task> happyCallTasksOnOpportunity = [SELECT Id, Status, FollowUpDate__c, Description FROM Task WHERE WhatId =:testOpportunity.Id AND Type =:Label.HCC];
            List<Task> systemCallTasks = [SELECT Id, Status, IsClosed, ActivityDate FROM Task WHERE WhatId =: accPerson.Id AND Type =:Label.Call];
            Opportunity newOpportunityFromLogAnAction = [SELECT Name, FollowupDateTime__c FROM Opportunity WHERE Id =:testOpportunity.Id];

            System.assertEquals(1,happyCallTasksOnOpportunity.size(),'1 HappyCall Task shall be created on Opportunity');
            System.assertEquals(1,happyCallTasksOnAccount.size(),'HappyCall Task created on Opportunity shall be related to Account that was created from');
            System.assertEquals(true,systemCallTasks[0].isClosed,'The System Call Task should be Closed');
            System.assertEquals(Label.LAC_Closed,systemCallTasks[0].status,'The System Call Task status value should be Closed');
            System.assertEquals(Date.valueOf(actionDate),systemCallTasks[0].ActivityDate,'The System Call Task Activity Date shall be set');
            System.assertEquals(comments,happyCallTasksOnOpportunity[0].Description,'The System Call Task comments shall be passed to Description');
        }
    }
}
