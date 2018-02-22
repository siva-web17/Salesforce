/**
 * Created by Arkadiusz Celej on 18.02.2018.
 */
({
    reprice: function (component, helper) {
        var action = component.get('c.repriceCart');
        console.log('repizing');
        action.setParams({
            cartId : component.get('v.cartId')
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var hasPendingItems = response.getReturnValue();
                    if(hasPendingItems){
                        helper.reprice(component, helper);
                    }else{
                        console.log('reprice done');
                        helper.finalize(component, helper);
                    }
                }
                else if (state === "ERROR") {
                    alert('error')
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    finalize: function (component, helper) {
        var action = component.get('c.finalizeCart');
        action.setParams({
            cartId : component.get('v.cartId')
        })
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var isSuccess = response.getReturnValue();
                    if(isSuccess){
                        component.set('v.finalizationDone', true);
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": "Cart could not be finalized"
                        });
                        toastEvent.fire();
                    }
                    helper.hideSpinner(component);
                }
                else if (state === "ERROR") {
                    alert('error')
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    showSpinner: function (component) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    hideSpinner: function (component) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },

    loadTemplates: function (component) {
        var action = component.get('c.getTemplates');
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var templates = response.getReturnValue();
                    component.set('v.templates', templates);
                }
                else if (state === "ERROR") {
                    alert('error')
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    print: function (component, helper) {
        var action = component.get('c.printTemplate');
        action.setParams({
            templateId : component.get('v.selectedTemplateId'),
            proposalId : component.get('v.proposalId'),
            opportunityId : component.get('v.proposal.Apttus_Proposal__Opportunity__c')
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var printedPDFId = response.getReturnValue();
                    component.set('v.generetadPDFId', printedPDFId);
                    component.set('v.viewGeneretadPDFUrl', '/servlet/servlet.FileDownload?file='+printedPDFId);
                    helper.hideSpinner(component);
                }
                else if (state === "ERROR") {
                    alert('error')
                }
                else {
                    // Handle other reponse states
                }
            }
        );
        $A.enqueueAction(action);
    },

    proposalRecord: function (component, helper) {
            var action = component.get('c.getProposalRecord');
            action.setParams({
                queryByProposalId : component.get('v.proposalId')
            });
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var proposalObject = response.getReturnValue();
                        component.set('v.proposal', proposalObject);
                    }
                    else if (state === "ERROR") {
                        alert(component.get('v.proposalId'))
                    }
                    else {
                        // Handle other reponse states
                    }
                }
            );
            $A.enqueueAction(action);
        },

    sendHelper: function(component, email, subject, body, attachmentId, opportunityId) {
        var action = component.get("c.sendMailMethod");
        action.setParams({
            'email': email,
            'subject': subject,
            'body': body,
            'attachmentId': attachmentId,
            'opportunityId': opportunityId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.mailStatus", true);
            }

        });
        $A.enqueueAction(action);
    },
})