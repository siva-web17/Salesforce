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
              var getSummary = cmp.get("c.getSummaryData");
                debugger;
              getSummary.setParams({
                            "rcrdId": cmp.get("v.recordId"),
                         });
              getSummary.setCallback(this, function(response) {
                  var state = response.getState();
                  console.log(JSON.stringify(response.getReturnValue()));
                  if (state == "SUCCESS") {
                     cmp.set('v.summaryData', response.getReturnValue());
                  }
              });
              $A.enqueueAction(getSummary);
            }
          });
          $A.enqueueAction(action);
    },

    navigateToBooking : function(component, event, helper) {
        helper.insertQLI(component,event);
	},

    goBack: function(component, event, helper){
        debugger;
        var evt=$A.get("e.force:navigateToURL");
        var sUrl1='';
        if(component.get("v.ConfigIdList").length >1)
        {
            sUrl1=component.get("v.OrgUrl")+'/apex/Apttus_Config2__Cart?id='+component.get("v.ConfigIdList")[0]+'&configRequestId='+component.get("v.ConfigIdList")[1]+'&flow=NGDefault';
        }

       	var str = '&&flow=NGDefault';
        evt.setParams({"url":sUrl1});

       //evt.setParams({"url":"https://www.google.com"});

        evt.fire();

        console.log('IN URL Testing');
    }

})