({
	NavigateToQuote : function(component, event, helper) {
         
        var evt = $A.get("e.force:navigateToComponent");
        
        evt.setParams({
            componentDef: "c:QuoteSummaryComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                OpportunityID: component.get("v.OpportunityID"),

            }
        });
       
        evt.fire();
        
        console.log('PID'+component.get("v.recordId"));
        
		
	}
    
  
})