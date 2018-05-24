({
    doInit: function(component,helper,event) {         
       var action = component.get("c.PseudonymiseAccount"); 
       action.setParams({
        recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
                    var state = response.getState();
                    $A.get("e.force:closeQuickAction").fire();
                    if (state === "SUCCESS") {
                
                       // alert("From server: " + response.getReturnValue());
                        if(response.getReturnValue()===''){
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Success!",
                                type: "success",
                                message: "The record has been pseudonymised successfully!!!"
                            });
                            toastEvent.fire();
                            $A.get('e.force:refreshView').fire();                                      
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
                                    var staticLabel = $A.get("$Label.c.AlreadyPseudonymised");
                                    var displayType='error';
                                    var displayTitle='Failure!';
                                    if(staticLabel === errors[0].message)
                                    {
                                        displayTitle='Warning!';
                                        displayType='warning';
                                    }
                                    var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                      title: displayTitle,
                                      type: displayType,
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
	},
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})