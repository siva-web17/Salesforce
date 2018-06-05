({
   init: function(cmp, event, helper) {
      helper.getOpportunitiesList(cmp);
   },

   handleChangeRecord: function(component, event, helper) {
      helper.refreshOpportunitiesRecord(component, event);
   },
})