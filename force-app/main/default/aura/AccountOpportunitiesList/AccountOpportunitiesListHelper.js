({
   getOpportunitiesList: function(cmp) {

      var action = cmp.get('c.getOpportunities');
      action.setParams({
         "accountId": cmp.get('v.recordId')
      })

      action.setCallback(this, $A.getCallback(function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            cmp.set('v.opportunitiesList', response.getReturnValue());
            cmp.set('v.opportunitiesCount', response.getReturnValue().length);
         } else if (state === "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "mode": "dismissible",
               "title": title,
               "message": message,
               "type": toastType
            })
            toastEvent.fire();
         }
      }));
      $A.enqueueAction(action);
   },

   refreshOpportunitiesRecord: function(component, event) {
      this.getOpportunitiesList(component)
   },
})