({
    doInit: function(component,helper,event) {  
        debugger;
       var action = component.get("c.PseudonymiseAccount"); 
       action.setParams({
        recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                
                       // alert("From server: " + response.getReturnValue());
                        if(response.getReturnValue()===''){
                            $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Success!",
                                type: "success",
                                message: "The record has been pseudonymised successfully!!!"
                            });
                            toastEvent.fire();
                                        
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
                            debugger;
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                      title: "Failure!",
                                      type: "error",
                                      message: errors[0].message, duration:10000
                                      });
                                      toastEvent.fire();
                                }
                            } else {
                               var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                     title: "Failure!",
                                     type: "error",
                                     message: errors[0].message
                                     });
                                     toastEvent.fire();
                            }
                        }
                });
                $A.enqueueAction(action);


	}
})