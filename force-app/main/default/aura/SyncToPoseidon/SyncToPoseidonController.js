({
	CallComplicatedBooking : function(component, event, helper) {

	    debugger;

        console.log('PID'+component.get("v.recordId"));
         var action = component.get("c.SyncComplicatedBookingToPoseidon");
         action.setParams({
                    "AccountId": component.get("v.recordId")
                });
         action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                       // alert("From server: " + response.getReturnValue());
                        if(response.getReturnValue()===''){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Success!",
                                type: "info",
                                message: "The record has been Sent To Poseidon."
                            });
                            toastEvent.fire();
                                           /* window.setTimeout(
                                $A.getCallback(function() {
                                  var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                  "recordId": component.get("v.recordId")
                                });
                                navEvt.fire();
                                }), 5000
                            );*/
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Failure!",
                                type: "error",
                                message: response.getReturnValue(),
                                duration:10000
                            });
                            toastEvent.fire();
                        }
                    }
                    else if (state === "INCOMPLETE") {
                    }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                      title: "Failure!",
                                      type: "Failure",
                                      message: errors[0].message
                                      });
                                      toastEvent.fire();
                                }
                            } else {
                               var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                     title: "Failure!",
                                     type: "Failure",
                                     message: errors[0].message
                                     });
                                     toastEvent.fire();
                            }
                        }
                });
                $A.enqueueAction(action);


	}


})