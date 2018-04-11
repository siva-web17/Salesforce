/**
 * Created by britenet-patrykzak on 05/03/2018.
 */

@isTest
private class ExceptionHandlerTest {

    @isTest
    static void When_errorLog_Expect_createErrorLog(){

        Account acc = new Account();
        String errorMessage = 'Test error Message';
        String stackTrace = 'Test Trace';
        String className = Account.class.getName();
        String NameOfMethod = 'testMethod';
        Id testId = acc.Id;

        Test.startTest();

        ExceptionHandler.errorLog(errorMessage,stackTrace,className,NameOfMethod,testId);
        List <ErrorLog__c> errLogList = [SELECT Name,Description__c FROM  ErrorLog__c];

        Test.stopTest();

        System.assertEquals(1,errLogList.size());
        System.assertEquals(errorMessage,errLogList[0].Description__c);
        System.assertEquals(Account.class.getName(),errLogList[0].Name);
    }

    @isTest
    static void When_errorLogAsync_Expect_createFutureErrorLog(){

        Account acc = new Account();
        String errorMessage = 'Test error Message';
        String stackTrace = 'Test Trace';
        String className = Account.class.getName();
        String NameOfMethod = 'testMethod';
        Id testId = acc.Id;

        Test.startTest();

        ExceptionHandler.errorLogAsync(errorMessage,stackTrace,className,NameOfMethod,testId);
        List <ErrorLog__c> errLogListBeforeFutureExecution = [SELECT Name,Description__c FROM  ErrorLog__c];

        Test.stopTest();

        List <ErrorLog__c> errLogListAfterFutureExecution = [SELECT Name,Description__c FROM  ErrorLog__c];
        System.assertEquals(0,errLogListBeforeFutureExecution.size());
        System.assertEquals(1,errLogListAfterFutureExecution.size());
        System.assertEquals(errorMessage,errLogListAfterFutureExecution[0].Description__c);
        System.assertEquals(Account.class.getName(),errLogListAfterFutureExecution[0].Name);
    }

    @isTest
    static void When_bulkLeadErrorAndLeadConvertedIsSuccess_Expect_doNotCreateBulkifiedErrorLog(){

        String className = 'Lead';
        String NameOfMethod = 'testMethod';
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Lead');
        Map<String,RecordType> recordtypeMap = RecordTypesSelector.getActiveRecTypesByDevName(convertType);
        Lead myLead = new Lead(LastName = 'Test Last Name', Company = 'Test Company', Market__c = 'NOO', FirstName = 'Test First Name');
        myLead.RecordTypeId = recordtypeMap.get('Company').Id;
        insert myLead;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(myLead.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        List<Database.LeadConvertResult> lcrl = new List<Database.LeadConvertResult>{lcr};

        Test.startTest();

        ExceptionHandler.bulkLeadError(lcrl,className,NameOfMethod);

        Test.stopTest();

        List <ErrorLog__c> errLogList = [SELECT Name,Description__c FROM  ErrorLog__c];
        System.assert(lcr.isSuccess());
        System.assertEquals(0,errLogList.size());
    }

    @isTest
    static void When_BulkErrorIsThrown_Expect_BulkErrorLogIsCreated(){

        Opportunity[] opportunities = new Opportunity[]{};
        Account[] accounts = new Account[]{};
        Integer numberOfRecords = 5;

        for(Integer i = 0; i<numberOfRecords; i++){
            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();
            pab.setField('FirstName', 'TestFirstName').setField('LastName', 'TestLastName');
            pab.setField('Market__c', picklistValuesHelper.market);
            pab.setField('PersonBirthdate', System.today().addYears(-50));
            Account testAccount = (Account)pab.getRecord();
            accounts.add(testAccount);
        }

        insert accounts;
        accounts = [SELECT Id FROM Account];

        for(Integer i = 0; i<numberOfRecords; i++){
            Opportunity testOpp = (Opportunity)(new TestDataFactory.OpportunityBuilder()).getRecord();
            testOpp.AccountId = accounts[i].Id;
            opportunities.add(testOpp);
        }
        insert opportunities;

        opportunities[0].StageName='ThereIsNoStageNameLikeThis';
        opportunities[numberOfRecords-1].StageName='ThereIsAlsoNoStageNameLikeThis';

        Test.startTest();

        Database.SaveResult[] srList = Database.update(opportunities, false);
        Database.Error[] errors = new Database.Error[]{};

        for(Database.SaveResult saveResult : srList){
            if(!saveResult.isSuccess()){
                for(Database.Error err : saveResult.getErrors()){
                    errors.add(err);
                }
            }
        }
        ExceptionHandler.bulkError(errors,'ExceptionHandlerTest', 'When_BulkErrorIsThrown_Expect_BulkErrorLogIsCreated');
        Test.stopTest();

        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>([
                SELECT Name, MethodName__c, Description__c
                FROM ErrorLog__c]);

        System.assertEquals(numberOfRecords, [SELECT COUNT() From Opportunity]);
        System.assertEquals(2, [SELECT COUNT() From ErrorLog__c]);
        for(ErrorLog__c errorLog : errorLogs){
            System.assertEquals('ExceptionHandlerTest', errorLog.Name);
            System.assertEquals('When_BulkErrorIsThrown_Expect_BulkErrorLogIsCreated', errorLog.MethodName__c);
            System.assertEquals('Please do not update the Stage of the Opportunity. Only automatic Stage Movements are allowed.',
                    errorLog.Description__c);
        }
    }
}