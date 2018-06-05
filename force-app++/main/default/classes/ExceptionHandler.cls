public class ExceptionHandler{
    public static void errorLog(String errMessage, String trace, String className, String methodName, Id id) {
        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>();
        ErrorLog__c err = new ErrorLog__c(
                Id__c = id,
                Name = className,
                MethodName__c = methodName,
                Description__c = errMessage,
                StackTrace__c = trace
        );
        errorLogs.add(err);
        SObjectUnitOfWork.createBulkErrorLog(errorLogs);
    }

    @future
    public static void errorLogAsync(String errMessage, String trace, String className, String methodName, Id id) {
        errorLog(errMessage, trace, className, methodName, id);
    }
}