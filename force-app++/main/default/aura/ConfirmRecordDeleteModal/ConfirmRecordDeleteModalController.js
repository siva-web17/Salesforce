({
   init: function(component, event, helper) {
      helper.getRecordType(component);
   },

   removeComponent: function(component, event, helper) {
      component.destroy();
   },

   handleDelete: function(component, event, helper) {
      helper.deleteRecord(component);
   },
})