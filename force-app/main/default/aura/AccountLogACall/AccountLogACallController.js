/**
 * Created by britenet-patrykzak on 29/03/2018.
 */
({
    doInit: function(component, event, helper) {

        component.set(
            "v.DateTimeTemp",
            moment(new Date())
            .add(1, "days").set('hour',0).set('minute',0)
            .format()
        );

        component.set(
            "v.accountCloseDate",
            moment(new Date(), "DD-MM-YYYY")
            .add(2, "months")
            .format("YYYY-MM-DD") + "T00:00"
        );

        var toastEvent = $A.get("e.force:showToast");
        var salesAction = component.get("c.getSalesActions");
        salesAction.setCallback(this, function(res) {
            switch (res.getState()) {
                case "SUCCESS":
                    var salesActions = res.getReturnValue();
                    component.set("v.salesAction", salesActions);
                    break;
                case "INCOMPLETE":
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(salesAction);

        var subActionsAction = component.get("c.getSubActions");
        subActionsAction.setCallback(this, function(res) {
            switch (res.getState()) {
                case "SUCCESS":
                    var subActions = res.getReturnValue();
                    component.set("v.subActions", subActions);
                    break;
                case "INCOMPLETE":
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(subActionsAction);

        var getSourceId = component.get("c.getExPaxSource");
        getSourceId.setCallback(this, function(res) {
            switch (res.getState()) {
                case "SUCCESS":
                    var sourceId = res.getReturnValue();
                    component.set("v.ExPaxSourceId", sourceId);
                    break;
                case "INCOMPLETE":
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(getSourceId);

        var bookOnDateAction = component.get("c.getInitialData");
        bookOnDateAction.setParams({ recordId: component.get("v.recordId") });
        bookOnDateAction.setCallback(this, function(res) {
            switch (res.getState()) {
                case "SUCCESS":
                    var data = res.getReturnValue();
                    console.log('Data!!' + data);
                    if (data != null) {
                        component.set('v.account',data);
                        component.set("v.isActiveUser", data.IsActive);
                        component.set("v.doNotCall", data.DoNotCall);
                        var phoneNumberCounter = 0;
                        if (data.PersonOtherPhone) {
                            phoneNumberCounter++;
                            component.set("v.displayOtherPhone", ('Other' + ': ' + data.PersonOtherPhone));
                            var initialCommunication = ['Other', data.PersonOtherPhone];
                            component.set("v.selectedDisplayNumber", initialCommunication);
                        }
                        if (data.PersonHomePhone) {
                            phoneNumberCounter++;
                            component.set("v.displayPhone", ('Home' + ': ' + data.PersonHomePhone));
                            var initialCommunication = ['Home', data.PersonHomePhone];
                            component.set("v.selectedDisplayNumber", initialCommunication);
                        }
                        if (data.PersonMobilePhone) {
                            phoneNumberCounter++;
                            component.set("v.displayMobilePhone", ('Mobile' + ': ' + data.PersonMobilePhone));
                            var initialCommunication = ['Mobile', data.PersonMobilePhone];
                            component.set("v.selectedDisplayNumber", initialCommunication);
                        }
                        component.set("v.phoneNumberCounter", phoneNumberCounter);
                    }
                    break;
                case "INCOMPLETE":
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(bookOnDateAction);
    },


    onSalesActionChanged: function(component, event, helper) {
        var LAC_SAVE_ACTION = $A.get("$Label.c.LAC_SAVE_ACTION");
        var LAC_SACO = $A.get("$Label.c.LAC_SACO");
        component.set("v.selectedSubActionType", "");
        component.set("v.saveText", LAC_SAVE_ACTION);
        var LAC_Call_Reached = $A.get("$Label.c.LAC_Call_Reached");
        var LAC_Select = $A.get("$Label.c.LAC_Select");
        if (component.get("v.selectedActionType") === LAC_Call_Reached && component.get("v.recordId").startsWith("00Q")) {
            component.set("v.saveText", LAC_SACO);
        }
        var callResultAction = component.get("c.getCallResults");
        callResultAction.setParams({
            callAction: component.get("v.selectedActionType"),
            recordId: component.get("v.recordId")
        });
        callResultAction.setCallback(this, function(res) {
            switch (res.getState()) {
                case "SUCCESS":
                    var callResults = res.getReturnValue();
                    component.set("v.callResults", callResults);
                    component.set("v.selectedCallResult", LAC_Select);
                    break;
                case "INCOMPLETE":
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(callResultAction);
    },


    onSaveClicked: function(component, event, Helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var actionType = component.get('v.selectedActionType');
        var callResult = component.get('v.selectedCallResult');
        var validatedBtn = event.currentTarget.dataset.save;
        var toastEvent = $A.get("e.force:showToast");

        var required = component.find("required").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, !0);

        if (!required) {
            $A.util.addClass(spinner, "slds-hide");
            var LAC_FILL_VALID_INFO = $A.get("$Label.c.LAC_FILL_VALID_INFO");
            toastEvent.setParams({
                title: "Error",
                type: "error",
                message: LAC_FILL_VALID_INFO
            });
            toastEvent.fire();

        } else {
            var saveDataAction = component.get("c.saveData");
            saveDataAction.setParams({
                AccountId: component.get("v.recordId"),
                comments: component.get("v.commentsValue"),
                callAction: component.get("v.selectedActionType"),
                subAction: component.get("v.selectedSubActionType"),
                callResult: component.get("v.selectedCallResult"),
                actionDate: moment(component.get('v.selectedActionDate'),moment.ISO_8601)
            });
            saveDataAction.setCallback(this, function(res) {
                var responseValue = res.getState();

                switch (responseValue) {

                case "SUCCESS":
                    toastEvent.setParams({
                        "message": "The record has been updated successfully.",
                        "type": "Success"
                    });
                    toastEvent.fire();

                    if (validatedBtn == "saveAndClose") {
                        $A.util.addClass(spinner, "slds-hide");
                        var urlEvent = $A.get("e.force:navigateToURL");
                        var LAC_ActionScreenURL = $A.get("$Label.c.LAC_ActionScreenURL");
                        urlEvent.setParams({ url: LAC_ActionScreenURL });
                        urlEvent.fire();
                    } else {
                        setTimeout(function(){
                           document.location.reload(true);
                        }, 1000);
                    }
                    break;

                case "ERROR":
                    $A.util.addClass(spinner, "slds-hide");
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    break;
                }
            });
            $A.enqueueAction(saveDataAction);
        }
    },

    pastDateValidation: function(component, evt, helper) {
        var todayDate = moment(new Date(), "DD-MM-YYYY").add(1, "days").format("YYYY-MM-DD") + "T00:00"
        if (component.get("v.selectedActionDate") != null) {
            if (!moment(component.get("v.selectedActionDate")).isAfter(moment().format("YYYY-MM-DD HH:mm")) && !moment(component.get("v.selectedActionDate")).isSame(moment().format("YYYY-MM-DD HH:mm"))) {
                var toastEvent = $A.get("e.force:showToast");
                var LAC_ERROR_PAST_MSG = $A.get("$Label.c.LAC_ERROR_PAST_MSG");
                toastEvent.setParams({
                    title: "Error",
                    type: "error",
                    message: LAC_ERROR_PAST_MSG
                });
                toastEvent.fire();
                component.set("v.selectedActionDate", todayDate);
            }
        }
    },

    navigateToActionScreen: function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var LAC_ActionScreenURL = $A.get("$Label.c.LAC_ActionScreenURL");
        urlEvent.setParams({ url: LAC_ActionScreenURL });
        urlEvent.fire();
    },

    handleMenuSelect: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value").split(':');
        component.set("v.selectedDisplayNumber", selectedMenuItemValue);
    },

    oppModalSubmitForm: function(component,event,helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    oppModalOnError: function(component){
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    programChanged: function(component,event){
        component.set("v.required1",component.find("requiredProgram").get("v.value"));
    },

    officeChanged: function(component,event){
        component.set("v.required2",component.find("requiredOffice").get("v.value"));

    },


    oppModalOnSuccess: function(component,event,helper){
        var spinner = component.find("mySpinner");
        var newOppParams = event.getParams().response;
        var newOppProgram = JSON.stringify(newOppParams.fields.Program__c.value);

        var action = component.get("c.createTaskOnOpp");
        var toastEvent = $A.get("e.force:showToast");

            action.setParams({
                accountId: component.get('v.recordId'),
                oppId: newOppParams.id,
                comments: component.get("v.commentsValue"),
                callAction: component.get("v.selectedActionType"),
                callResult: component.get("v.selectedCallResult"),
                actionDate: moment(component.get('v.selectedActionDate'),moment.ISO_8601)
            });

            action.setCallback(this, function(res) {
            var responseValue = res.getState();
            switch (responseValue) {
                case "SUCCESS":
                    toastEvent.setParams({
                       "message": "The record has been created successfully.",
                       "type": "Success"
                    });
                    toastEvent.fire();
                    setTimeout(function(){
                        $A.util.addClass(spinner, "slds-hide");
                        var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": newOppParams.id,
                              "slideDevName": "related"
                            });
                            navEvt.fire();
                    }, 1000);
                    break;
                case "ERROR":
                    var errors = res.getError();
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        "type": "error"
                    });
                    console.log(errors[0].message)
                    toastEvent.fire();
                    $A.util.addClass(spinner, "slds-hide");
                    break;
            }
        });
        $A.enqueueAction(action);
    }
})