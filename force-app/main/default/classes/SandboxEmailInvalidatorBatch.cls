/**
 * Created by britenet-patrykzak on 28/05/2018.
 */

public without sharing class SandboxEmailInvalidatorBatch implements Database.Batchable<SObject>{

    private List<String> emailFieldsToInvalidate;
    private String objectName;
    private Boolean isSandbox = ExternalRouter.getOrganizationDetails().IsSandbox;
    private String instanceNameFromUserInfo = UserInfo.getUserName().substringAfterLast('.');
    private String strQuery;
    private List<String> queryConditions;

    public SandboxEmailInvalidatorBatch(List<String> emailFieldsToInvalidate, String objectName, List<String> queryConditions){
        if(!isSandbox){
            throw new AuraHandledException('To be executed only on Sandbox instances!');
        }
        this.emailFieldsToInvalidate = emailFieldsToInvalidate;
        this.objectName = objectName;
        this.queryConditions = queryConditions;

        this.strQuery = 'SELECT ' + String.join(emailFieldsToInvalidate,',') + ' FROM ' + objectName;

        if(queryConditions.size()>0){
            strQuery += ' WHERE ' + String.join(queryConditions, ' AND ');
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