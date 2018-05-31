({
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    saveClick: function(component, event, helper) {
        helper.process(component, event, helper);
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true)
    },
    hideSpinner: function(component, event, helper) {
        component.set("v.Spinner", false)
    },
    cancelClick: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    }
});