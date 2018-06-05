({
	NavigateToQuote : function(component, event, helper) {
            debugger;
            var evt = $A.get("e.force:navigateToComponent");

            evt.setParams({
                componentDef: "c:BookingSummaryComponent",
                componentAttributes: {
                    RecordId: component.get("v.recordId")
                }
            });

            evt.fire();

            console.log('PID'+component.get("v.recordId"));


    	}


})