({
    doInit: function(cmp, event, helper) {
        //debugger;
     helper.getOrgURL(cmp, event);
        helper.getConfigId(cmp, event);
		 var action = cmp.get("c.Preview");
         action.setParams({
            "rcrdId": cmp.get("v.recordId"),
         });
          action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state == "SUCCESS") {
              //set response value in wrapperList attribute on component.
              var json_text = JSON.stringify(response.getReturnValue());
              console.log(json_text);
              cmp.set('v.wrapperList', response.getReturnValue());
            }
          });
          $A.enqueueAction(action);
    },
    
    navigateToBooking : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BookingSummaryComponent",
            componentAttributes: {
                QuoteId: component.get("v.recordId")
            }
        });
        evt.fire();    
	},
    
    goBack: function(component, event, helper){
        debugger;
        var evt=$A.get("e.force:navigateToURL");
        //alert(component.get("v.OrgUrl"));
        //evt.setParams({"url":"https://bookingsummary--apttusplay.cs89.my.salesforce.com/apex/Apttus_Config2__Cart"}); configRequestId=a340E0000004vbJQAQ&cartStatus=New&id=a2N0E0000006hH7UAI&
        var sUrl1='';
        if(component.get("v.ConfigIdList").length >1)
        {
            sUrl1=component.get("v.OrgUrl")+'/apex/Apttus_Config2__Cart?id='+component.get("v.ConfigIdList")[0]+'&configRequestId='+component.get("v.ConfigIdList")[1]+'&flow=NGDefault';
        }
    
        ///apex/Apttus_Config2__Cart?id=a2N0E0000009mRWUAY&configRequestId=a340E000000CvXMQA0&flow=NGDefault
        //var sUrl1='https://bookingsummary--apttusplay--apttus-qpconfig.cs89.visual.force.com/apex/ProposalConfiguration?flow=NGDefault&id='+component.get("v.recordId");
        //var sUrl='https://bookingsummary--apttusplay--apttus-config2.cs89.visual.force.com/apex/Apttus_QPConfig__ProposalConfiguration?id='+component.get("v.recordId");
       	var str = '&&flow=NGDefault';
         //var sUrl = sUrl1.concat(str);
        //alert(sUrl1);
        //window.parent.location =sUrl1;
        evt.setParams({"url":sUrl1});
        
       //evt.setParams({"url":"https://www.google.com"});
        
        evt.fire();
        
        console.log('IN URL Testing');    
    }

})