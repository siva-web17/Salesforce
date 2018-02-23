({
    doInit: function (component, event, helper) {
        helper.loadAvailableStartDates(component, helper);
    },

    close: function (component, event, helper) {
        component.destroy();
    },

    onSelectStartDate:function (component, event, helper) {
        console.log('v.startDate', event.currentTarget.dataset.startdate);
        console.log('v.endDate', event.currentTarget.dataset.enddate);
        console.log('v.quantity', event.currentTarget.dataset.quantity);
        component.set('v.startDate', event.currentTarget.dataset.startdate);
        component.set('v.endDate', event.currentTarget.dataset.enddate);
        component.set('v.quantity', event.currentTarget.dataset.quantity);
        helper.fireStartDatesSelectedEvent(component);
        component.destroy();
    }
})