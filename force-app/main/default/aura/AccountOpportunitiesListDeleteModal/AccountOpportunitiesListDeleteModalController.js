({
   removeComponent: function(component, event, helper) {
      console.log('AccountOpportunitiesListDeleteModalController removeComponent')
      component.destroy();
   },

   handleDelete: function(component, event, helper) {
      console.log('AccountOpportunitiesListDeleteModalController handleDelete')
      helper.deleteRecord(component);
   },
})