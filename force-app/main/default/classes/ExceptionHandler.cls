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

    public static void bulkLeadError( List<Database.LeadConvertResult> erroredLeads,String className,String methodName){
        List<ErrorLog__c> errList = new List<ErrorLog__c>();
        for(Database.LeadConvertResult convertedLead: erroredLeads){
            if(!convertedLead.isSuccess()){
                for (Database.Error error : convertedLead.getErrors()) {
                    ErrorLog__c err = new ErrorLog__c();
                    err.ID__c = convertedLead.getLeadId();
                    err.Name = className;
                    err.MethodName__c = methodName;
                    err.Description__c = error.getMessage();
                    err.StackTrace__c = '';
                    errList.add(err);
                }
            }
        }
        SObjectUnitOfWork.createBulkErrorLog(errList);
    }

    public static void bulkError(Database.Error[] errors, String className, String methodName){

        List<ErrorLog__c> errList = new List<ErrorLog__c>();

        for(Database.Error error : errors){
            ErrorLog__c err = new ErrorLog__c();
            err.Name = className;
            err.MethodName__c = methodName;
            err.Description__c = error.getMessage();
            err.StackTrace__c = String.join(error.getFields(),',');
            errList.add(err);
        }
        SObjectUnitOfWork.createBulkErrorLog(errList);
    }
}