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
}