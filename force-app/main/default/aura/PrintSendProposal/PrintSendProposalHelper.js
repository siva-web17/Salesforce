/**
 * Created by Arkadiusz Celej on 18.02.2018.
 */
({
    reprice: function (component, helper) {
        var action = component.get('c.repriceCart');
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
                        helper.finalize(component, helper);
                    }
                } else if (state === "ERROR") {
                    var message = 'Unknown error';
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            message = errors[0].message;
                        }
                    }
                    component.set('v.errorMessage', message);
                } else {
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
                        var message = 'Unknown error';
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                message = errors[0].message;
                            }
                        }
                        component.set('v.errorMessage', message);
                    }
                    helper.hideSpinner(component);
                } else if (state === "ERROR") {
                    alert('error')
                } else {
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
                } else if (state === "ERROR") {
                    var message = 'Unknown error';
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            message = errors[0].message;
                        }
                    }
                    component.set('v.errorMessage', message);
                } else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    print: function (component, helper) {
        helper.showSpinner(component);
        var action = component.get('c.printTemplate');
        action.setParams({
            templateId : component.get('v.selectedTemplateId'),
            proposalId : component.get('v.proposalId'),
            opportunityId : component.get('v.proposal.Apttus_Proposal__Opportunity__c')
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var generatedPDF = response.getReturnValue();
                    component.set('v.generatedPDF', generatedPDF);
                    component.set('v.viewGeneretadPDFUrl', '/servlet/servlet.FileDownload?file='+generatedPDF.id);
                    helper.hideSpinner(component);
                } else if (state === "ERROR") {
                    var message = 'Unknown error';
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            message = errors[0].message;
                        }
                    }
                    component.set('v.errorMessage', message);
                } else {
                    // Handle other reponse states
                }
                helper.hideSpinner(component);
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
                    } else if (state === "ERROR") {
                        var message = 'Unknown error';
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                message = errors[0].message;
                            }
                        }
                        component.set('v.errorMessage', message);
                    } else {
                        // Handle other reponse states
                    }
                }
            );
            $A.enqueueAction(action);
        },

    sendHelper: function(component, email, subject, body, attachmentIds, opportunityId, proposalId) {
        var helper = this;
        helper.showSpinner(component);

        var action = component.get("c.sendMailMethod");
        action.setParams({
            'email': email,
            'subject': subject,
            'body': body,
            'attachmentIds': attachmentIds,
            'opportunityId': opportunityId,
            'proposalId' : proposalId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.mailStatus", true);
                component.set('v.successMessage', 'Email sent');
                component.set('v.errorMessage', '');
            } else if (state === "ERROR") {
                var message = 'Unknown error';
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                }
                component.set('v.errorMessage', message);
            } else {
                // Handle other reponse states
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

    uploadHelper: function(component, event) {
        this.showSpinner(component);

        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]
        var file = fileInput[0];

        if (file.size > self.MAX_FILE_SIZE) {
            this.hideSpinner(component);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }

        var _this = this;
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method
            _this.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadProcess: function(component, file, fileContents) {
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },


    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var _this = this;
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.proposal.Apttus_Proposal__Opportunity__c"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });

        // set call back
        action.setCallback(this, function(response) {
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    var attachedFiles = component.get('v.attachedFiles');
                    attachedFiles.push({
                        name : file.name,
                        id : attachId,
                        downloadUrl : '/servlet/servlet.FileDownload?file='+attachId
                    });
                    component.set('v.attachedFiles', attachedFiles);
                    _this.hideSpinner(component);
                }
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})