({
	helperMethod : function() {
		
	},

    insertQLI : function(cmp,event) {
        //alert('enter');

        var action = cmp.get("c.saveTempData");
        var saveData = cmp.get("v.summaryData");


        action.setParams({
            "summaryData": JSON.stringify(saveData),
            "rcrdId":cmp.get("v.recordId")
		});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                if (response.getReturnValue() === true) {
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Success!',
						type: 'success',
					});
					toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

            }
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:BookingSummaryComponent",
                componentAttributes: {
                    QuoteId: cmp.get("v.recordId")
                }
            });
            evt.fire();
        });
        $A.enqueueAction(action);
    },
    getOrgURL : function(cmp,event) {
        //alert('enter');

        var action = cmp.get("c.getCurrentOrgUrl");
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               cmp.set('v.OrgUrl', response.getReturnValue());
                           }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getConfigId : function(cmp,event) {
        //alert('enter');
        
        var action = cmp.get("c.getConfigIds");
       action.setParams({
            "quoteId": cmp.get("v.recordId")
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               cmp.set('v.ConfigIdList', response.getReturnValue());
                           }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})