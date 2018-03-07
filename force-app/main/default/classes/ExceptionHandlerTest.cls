/**
 * Created by britenet-patrykzak on 05/03/2018.
 */

@isTest
private class ExceptionHandlerTest {

    static testmethod void When_errorLog_Expect_createErrorLog(){

        Account acc = new Account();
        String errorMessage = 'Test error Message';
        String stacktrace = 'Test Trace';
        String className = Account.class.getName();
        String NameOfMethod = 'testMethod';
        Id testId = acc.Id;

        Test.startTest();

        ExceptionHandler.errorLog(errorMessage,stacktrace,className,NameOfMethod,testId);
        List <ErrorLog__c> errLogList = [SELECT Name,Description__c FROM  ErrorLog__c];

        Test.stopTest();

        System.assertEquals(1,errLogList.size());
        System.assertEquals('Test error Message',errLogList[0].Description__c);
        System.assertEquals(Account.class.getName(),errLogList[0].Name);
    }

    static testmethod void When_errorLogAsync_Expect_createFutureErrorLog(){

        Account acc = new Account();
        String errorMessage = 'Test error Message';
        String stacktrace = 'Test Trace';
        String className = Account.class.getName();
        String NameOfMethod = 'testMethod';
        Id testId = acc.Id;

        Test.startTest();

        ExceptionHandler.errorLogAsync(errorMessage,stacktrace,className,NameOfMethod,testId);
        List <ErrorLog__c> errLogListBeforeFutureExecution = [SELECT Name,Description__c FROM  ErrorLog__c];

        Test.stopTest();

        List <ErrorLog__c> errLogListAfterFutureExecution = [SELECT Name,Description__c FROM  ErrorLog__c];
        System.assertEquals(0,errLogListBeforeFutureExecution.size());
        System.assertEquals(1,errLogListAfterFutureExecution.size());
        System.assertEquals('Test error Message',errLogListAfterFutureExecution[0].Description__c);
        System.assertEquals(Account.class.getName(),errLogListAfterFutureExecution[0].Name);
    }

    static testmethod void When_bulkLeadErrorAndLeadConvertedIsSuccess_Expect_doNotCreateBulkifiedErrorLog(){

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
}