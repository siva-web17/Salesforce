({
   getRecordType: function(component) {

        var action = component.get('c.getSObjectType');
        action.setParams({
            "recordId": component.get('v.recordId')
        })

        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.objectType', response.getReturnValue());
            }else if (state === "ERROR") {
                this.showServerSideError(response.getError()[0].message);
            }
        }));
        $A.enqueueAction(action);
   },

   deleteRecord: function(component) {

      var action = component.get('c.deleteRecord');
      action.setParams({
         "recordId": component.get('v.recordId')
      })

      action.setCallback(this, $A.getCallback(function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            component.destroy();
            var staticLabel = $A.get("$Label.c.RecordDeletedSuccessfully");
            this.showSuccessToast(staticLabel);
            var appEvent = $A.get("e.c:RecordIsDeletedEvent");
            appEvent.fire();
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
      }
   },
})