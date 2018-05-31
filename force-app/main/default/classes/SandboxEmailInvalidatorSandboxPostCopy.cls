/**
 * Created by britenet-patrykzak on 28/05/2018.
 */

public with sharing class SandboxEmailInvalidatorSandboxPostCopy implements SandboxPostCopy{

    public void runApexClass(SandboxContext context){
        List<String> leadEmailFieldsToInvalidate = new List<String>{'Email','Email2__c','ParentEmail__c'};
        List<String> accountEmailFieldsToInvalidate = new List<String>{'PersonEmail','InvoiceEmail__c','Email2__c','ParentEmail__c'};

        List<String> leadQueryConditions = new List<String>{};
        List<String> accountQueryConditions = new List<String>{'isPersonAccount = True'};

        SandboxEmailInvalidatorBatchException leadInvalidator = new SandboxEmailInvalidatorBatchException(leadEmailFieldsToInvalidate,'Lead',leadQueryConditions);
        SandboxEmailInvalidatorBatchException accountInvalidator = new SandboxEmailInvalidatorBatchException(accountEmailFieldsToInvalidate,'Account',accountQueryConditions);

        Database.executeBatch(leadInvalidator);
        Database.executeBatch(accountInvalidator);
    }

}