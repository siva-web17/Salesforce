({
    doInit: function(component, event, helper) {
        var action = component.get("c.ValidateAccountforPseudonymis");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            if (state === "ERROR") {
                $A.get("e.force:closeQuickAction").fire();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var staticLabel = $A.get("$Label.c.AlreadyPseudonymised");
                        var displayType = "error";
                        var displayTitle = "Failure!";
                        if (staticLabel === errors[0].message) {
                            displayTitle = "Warning!";
                            displayType = "warning"
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: displayTitle,
                            type: displayType,
                            message: errors[0].message,
                            duration: 10000
                        });
                        toastEvent.fire()
                    }
                    component.set("v.Spinner", false);
                }
            }
        });
        $A.enqueueAction(action)
    },
    process: function(component, event, helper) {
        component.set("v.Spinner", true)
        var action = component.get("c.PseudonymiseAccount");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();
            if (state === "SUCCESS") {
                if (response.getReturnValue() === "") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        type: "success",
                        message: "The record has been pseudonymised successfully!!!"
                    });
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire()
                    component.set("v.Spinner", false);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Failure!",
                        type: "error",
                        message: response.getReturnValue(),
                        duration: 10000
                    });
                    toastEvent.fire()
                    component.set("v.Spinner", false);
                }
            } else if (state === "INCOMPLETE") {} else if (state === "ERROR") {

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var staticLabel = $A.get("$Label.c.AlreadyPseudonymised");
                        var displayType = "error";
                        var displayTitle = "Failure!";
                        if (staticLabel === errors[0].message) {
                            displayTitle = "Warning!";
                            displayType = "warning"
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: displayTitle,
                            type: displayType,
                            message: errors[0].message,
                            duration: 10000
                        });
                        toastEvent.fire()
                    }
                    component.set("v.Spinner", false);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Failure!",
                        type: "error",
                        message: errors[0].message
                    });
                    toastEvent.fire()
                    component.set("v.Spinner", false);
                }
            }
        });
        $A.enqueueAction(action)
    }
})