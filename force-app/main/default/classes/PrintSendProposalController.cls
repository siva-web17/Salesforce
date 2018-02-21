/**
 * Created by Arkadiusz Celej on 18.02.2018.
 */

public with sharing class PrintSendProposalController {

    public Id cartId {get;set;}
    public Id proposalId {get;set;}

    public PrintSendProposalController(){
        cartId = ApexPages.currentPage().getParameters().get('id');
        proposalId = ApexPages.currentPage().getParameters().get('retId');
    }


    @AuraEnabled
    public static Boolean repriceCart(String cartId){
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO priceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        priceRequestDO.cartId = cartId;
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(priceRequestDO);
        return result.isPricePending;
    }

    @AuraEnabled
    public static Boolean finalizeCart(String cartId){
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
        request.CartId = cartId;
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
        return response.IsSuccess;
    }

    //TODO Prepare correct selector with proper conditions
    @AuraEnabled
    public static Apttus__APTS_Template__c[] getTemplates(){
        return [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = TRUE ORDER BY Name];
    }

    @AuraEnabled
    public static Apttus_Proposal__Proposal__c getProposalRecord(Id queryByProposalId){
        return [SELECT Id, Apttus_Proposal__Account__r.PersonEmail, Apttus_Proposal__Opportunity__c FROM Apttus_Proposal__Proposal__c WHERE Id =:queryByProposalId];
    }

    @AuraEnabled
    public static String printTemplate(String templateId, String proposalId, String opportunityId){
        String accessLevel = 'Read only';
        String docFormat = 'PDF';
        String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() +'/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        String apiSessionId = UserInfo.getSessionId();
        String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(templateId, proposalId, accessLevel, docFormat, apiSessionId, apiServerURL);
        cloneAttachmentToOpportunity(opportunityId, generatedDocId);
        return generatedDocId;
    }

    public static void cloneAttachmentToOpportunity(String opportunityId, String attachmentId){
        Attachment pdf = [SELECT Id, name, body from attachment where Id=:attachmentId];
        Attachment oppAtt = pdf.clone();
        oppAtt.ParentId = opportunityId;
        insert oppAtt;
    }

    @AuraEnabled
    public static void sendMailMethod(String email ,String subject ,String body, String attachmentId, Id opportunityId){

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(email);
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName(UserInfo.getName());
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setWhatId(opportunityId);
        mail.setSaveAsActivity(true);

        Attachment pdf = [SELECT Id, name, body from attachment where Id=:attachmentId];
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(pdf.Name);
        efa.setBody(pdf.body);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        mails.add(mail);
        Messaging.sendEmail(mails);
    }
}