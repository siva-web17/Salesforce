/**
 * Created by britenet-patrykzak on 28/05/2018.
 */

public with sharing class SandboxEmailInvalidatorSandboxPostCopy implements SandboxPostCopy{

    public void runApexClass(SandboxContext context){
        List<String> leadEmailFieldsToInvalidate = new List<String>{'Email','Email2__c','ParentEmail__c'};
        List<String> AccountEmailFieldsToInvalidate = new List<String>{'PersonEmail','InvoiceEmail__c','Email2__c','ParentEmail__c'};

        SandboxEmailInvalidatorBatch LeadInvalidator = new SandboxEmailInvalidatorBatch(leadEmailFieldsToInvalidate,'Lead');
        SandboxEmailInvalidatorBatch AccountInvalidator = new SandboxEmailInvalidatorBatch(AccountEmailFieldsToInvalidate,'Account');

        Database.executeBatch(LeadInvalidator);
        Database.executeBatch(AccountInvalidator);
    }

}