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
        helper.showSpinner(component);
        helper.print(component, helper);
    },
    sendMail: function(component, event, helper) {
        var email = component.get("v.email");
        var subject = component.get("v.subject");
        var body = component.get("v.body");
        var attachemntId = component.get("v.generetadPDFId");
        var opportunityId = component.get('v.proposal.Apttus_Proposal__Opportunity__c');
        if ($A.util.isEmpty(email) || !email.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, email, subject, body, attachemntId, opportunityId);
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
})