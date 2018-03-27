({
   editRecord: function(component) {

      var editRecordEvent = $A.get("e.force:editRecord");
      editRecordEvent.setParams({
         "recordId": component.get("v.row.Opportunity.Id")
      });
      editRecordEvent.fire();
   },

   goToRecord: function(component) {

      var goToRecordEvent = $A.get("e.force:navigateToSObject");
      goToRecordEvent.setParams({
         "recordId": component.get("v.row.Opportunity.Id"),
      });
      goToRecordEvent.fire();
   },

   deleteRecord: function(component) {

      $A.createComponent("c:ConfirmRecordDeleteModal", {
         "recordId": component.get("v.row.Opportunity.Id"),

      }, function(newcomponent) {
         var body = component.get("v.body");
         body.push(newcomponent);
         component.set("v.body", body);
      });
   },
})