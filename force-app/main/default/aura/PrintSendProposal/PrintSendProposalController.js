/**
 * Created by Arkadiusz Celej on 18.02.2018.
 */
({
    doInit: function (component, event, helper) {
        helper.reprice(component, helper);
        helper.loadTemplates(component);
        helper.proposalRecord(component);
    },

    onTemplateSelection: function (component, event, helper) {
        var templateId = event.currentTarget.dataset.templateid;
        component.set('v.selectedTemplateId', templateId);
        helper.print(component, helper);
    },

    sendMail: function(component, event, helper) {
        var email = component.get("v.email");
        var subject = component.get("v.subject");
        var body = component.get("v.body");
        var attachmentIds = [];
        var generatedPDF = component.get("v.generatedPDF");
        var proposalId = component.get('v.proposalId');
        if(generatedPDF && generatedPDF.id){
            attachmentIds.push(generatedPDF.id);
        }
        var uploadedAttachemnts = component.get('v.attachedFiles');
        for(var i = 0 ; i < uploadedAttachemnts.length; i++){
            attachmentIds.push(uploadedAttachemnts[i].id);
        }
        var opportunityId = component.get('v.proposal.Apttus_Proposal__Opportunity__c');
        if ($A.util.isEmpty(body)) {
            component.set('v.errorMessage', 'Email body cannot be blank');
        } else {
            helper.sendHelper(component, email, subject, body, attachmentIds, opportunityId, proposalId);
        }
    },
    goToOpportunityRecord: function(component, event, helper){
        var urlEvent = $A.get('e.force:navigateToSObject');
        var opportunityId = component.get('v.proposal.Apttus_Proposal__Opportunity__c');
        urlEvent.setParams({
            "recordId": opportunityId
        });
        urlEvent.fire();
    },
    initValues: function(component){
        var proposal = component.get('v.proposal');
        console.log(proposal);
        if (proposal && proposal.Apttus_Proposal__Account__r){
            component.set('v.email', proposal.Apttus_Proposal__Account__r.PersonEmail);
        }
    },

    clearError: function (component, event, helper) {
        component.set('v.errorMessage','');
    },

    clearSuccess: function (component, event, helper) {
        component.set('v.successMessage','');
    },

    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            component.set('v.errorMessage', 'Please Select a Valid File');
        }
    },

    back:function (component, event, helper) {
        window.location.href = component.get('v.backToCartUrl');
    }
})