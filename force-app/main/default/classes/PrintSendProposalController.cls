/**
 * Created by Arkadiusz Celej on 18.02.2018.
 */

public with sharing class PrintSendProposalController {

    public Id cartId {get;set;}
    public Id proposalId {get;set;}
    public String backCartUrl{ get; set; }

    public PrintSendProposalController(){
        cartId = ApexPages.currentPage().getParameters().get('id');
        proposalId = ApexPages.currentPage().getParameters().get('retId');
        String configId2 = ApexPages.currentPage().getParameters().get('id');
        String configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        String cartStatus = ApexPages.currentPage().getParameters().get('cartStatus');
        String cartFlow = ApexPages.currentPage().getParameters().get('flow');
        backCartUrl = Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId;
        if(cartStatus != NULL){
            backCartUrl = backCartUrl +'&cartStatus=' + cartStatus;
        }
        if(cartFlow != NULL){
            backCartUrl = backCartUrl + '&flow=' +cartFlow;
        }
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

    @AuraEnabled
    public static Apttus__APTS_Template__c[] getTemplates(){
        return [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = TRUE ORDER BY Name];
    }

    @AuraEnabled
    public static Apttus_Proposal__Proposal__c getProposalRecord(Id queryByProposalId){
        Apttus_Proposal__Proposal__c[] proposals = QuoteProposalsSelector.getSelectedQuoteByID(new List<Id>{queryByProposalId});
        return proposals.size() > 0 ? proposals[0] : null;
    }

    @AuraEnabled
    public static AttachmentWrapper printTemplate(String templateId, String proposalId, String opportunityId){
        try {
            String accessLevel = 'Read only';
            String docFormat = 'PDF';
            String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
            String apiSessionId = UserInfo.getSessionId();
            String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(templateId, proposalId, accessLevel, docFormat, apiSessionId, apiServerURL);
            Attachment opportunityAttachment = cloneAttachmentToOpportunity(opportunityId, generatedDocId);
            passLatestAttachmentIdToProposal(proposalId, opportunityAttachment.Id);
            return new AttachmentWrapper(opportunityAttachment);
        }catch (Exception ex){
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(), 'PrintSendProposalController', 'printTemplate', proposalId);
            throw new AuraException(ex.getMessage());
        }
    }

    public static void passLatestAttachmentIdToProposal(String proposalId, String attachmentId){
        try{
            update new Apttus_Proposal__Proposal__c(Id = proposalId, LatestGeneratedProposal__c = attachmentId);
        }catch (Exception ex){
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(), 'PrintSendProposalController', 'passLatestAttachmentIdToProposal', proposalId);
            throw new AuraException(ex.getMessage());
        }
    }

    public static Attachment cloneAttachmentToOpportunity(String opportunityId, String attachmentId){
        Attachment pdf = [SELECT Id, name, body from attachment where Id=:attachmentId];
        Attachment oppAtt = pdf.clone();
        oppAtt.Name = 'Quote.pdf';
        oppAtt.ParentId = opportunityId;
        insert oppAtt;
        return oppAtt;
    }

    @AuraEnabled
    public static void sendMailMethod(String email ,String subject ,String body, List<String> attachmentIds, Id opportunityId){
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

        List<Messaging.EmailFileAttachment> attachmentsToSend = new List<Messaging.EmailFileAttachment>();
        Map<Id, Attachment> attachments = new Map<Id, Attachment>([SELECT Id, name, body FROM Attachment WHERE Id IN :attachmentIds]);
        for(String attId : attachmentIds) {
            if(attachments.containsKey(attId)){
                Attachment a = attachments.get(attId);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(a.Name);
                efa.setBody(a.body);
                attachmentsToSend.add(efa);
            }
        }
        mail.setFileAttachments(attachmentsToSend);

        mails.add(mail);
        try{
            Messaging.sendEmail(mails);
        }catch (Exception ex){
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(), 'PrintSendProposalController', 'sendMailMethod', opportunityId);
            throw new AuraException(ex.getMessage());
        }
    }


    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;

        insert oAttachment;
        return oAttachment.Id;
    }

    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = [
                SELECT Id, Body
                FROM Attachment
                WHERE Id =: fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }

    public class AttachmentWrapper{
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;

        public AttachmentWrapper(Attachment att){
            this.id = att.Id;
            this.name = att.name;
        }
    }

    public class AuraException extends Exception{}
}