/**
 * Created by britenet-patrykzak on 28/05/2018.
 */

public without sharing class SandboxEmailInvalidatorBatch implements Database.Batchable<SObject>{

    private List<String> emailFieldsToInvalidate;
    private String recordToProcess;
    private String instanceNameFromUserInfo = UserInfo.getUserName().substringAfterLast('.');
    private String strQuery;

    public SandboxEmailInvalidatorBatch(List<String> emailFieldsToInvalidate, String recordToProcess){

        this.emailFieldsToInvalidate = emailFieldsToInvalidate;
        this.recordToProcess = recordToProcess;

        this.strQuery = 'SELECT ' + String.join(emailFieldsToInvalidate,',') + ' FROM ' + recordToProcess;

        if(recordToProcess.equalsIgnoreCase('Account')){
            strQuery += ' WHERE isPersonAccount = True';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(strQuery);
    }


    public void execute(Database.BatchableContext context,List<sObject> scope){
        try{
            for(sObject record : scope){
                process(record);
            }
            Update scope;
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'SandboxEmailInvalidatorBatch', 'execute', null);
        }
    }

    public void finish(Database.BatchableContext bc){
    }

    public void process(SObject record){
        for(String field : emailFieldsToInvalidate) {
            String fieldValue = (String)record.get(field);
            if(String.isNotEmpty(fieldValue) && !field.contains(instanceNameFromUserInfo)){
                record.put(field, record.get(field) + '.' + instanceNameFromUserInfo);
            }
        }
    }
}