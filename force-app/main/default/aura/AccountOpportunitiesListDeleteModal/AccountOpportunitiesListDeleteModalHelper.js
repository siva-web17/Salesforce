({
   deleteRecord: function(component) {
      console.log('AccountOpportunitiesListDeleteModalHelper handleDelete');

      var action = component.get('c.deleteOpportunity');
      action.setParams({
         "opportunityId": component.get('v.recordId')
      })

      action.setCallback(this, $A.getCallback(function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            component.destroy();
            this.showSuccessToast("Opportunity was deleted successfully")
            var appEvent = $A.get("e.c:RecordIsDeletedEvent");
            appEvent.fire();
            console.log('Event is fired');
         } else if (state === "ERROR") {
            this.showServerSideError(response.getError()[0].message);
         }
      }));
      $A.enqueueAction(action);
   },

   showSuccessToast: function(message) {
      this.showToastMessage("success", message, "SUCCESS:", "dismissible");
   },

   showServerSideError: function(message) {
      this.showToastMessage("error", message,
                  "ERROR:", "sticky");
   },

   showToastMessage: function(toastType, message, title, mode) {
      console.log('JP_SubscriptionListItemHelper showToastMessage');
      var toastEvent = $A.get("e.force:showToast");
      if (toastType == 'error' || toastType == 'warning'
                  || toastType == 'success' || toastType == 'other'
                  || toastType == 'info') {
         toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": toastType
         })
         toastEvent.fire();
      } else {
         console.log('ERROR in showToastMessage: bad toastType: ' + toastType
                     + 'available values are: error/warning/success/other');
      }
   },
})