// Refactoring by Shiva 22-1-2018
({
    getFirstContactStatus: function(component) {
        var getFirstContactStatus = component.get('c.isCustomerReached');
        getFirstContactStatus.setParams({ recordId: component.get('v.recordId'), });
        getFirstContactStatus.setCallback(this, function(res) {
            switch (res.getState()) {
                case 'SUCCESS':
                    component.set('v.isCustomerReached', res.getReturnValue());
                    break;
                case 'INCOMPLETE':
                    break;
                case 'ERROR':
                    break
            }
        });
        $A.enqueueAction(getFirstContactStatus)
    }
})