({

    loadAvailableStartDates: function (component, helper) {
        var item = component.get('v.lineItem');
        var action = component.get('c.getAvailableStartDates');
        action.setParams({
            "item" : item
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set('v.availableDates', returnValue);
                var c = returnValue;
                for(var i = 0 ; i < 5; i++){
                    c = c.concat(returnValue)
                }
                console.log('v.availableDates',returnValue);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = errors[0].message;
                }
                helper.handleErrors(message);
            }
            else {
                // Handle other reponse states
            }
        });

        $A.enqueueAction(action);
    },

    formatDate: function (y,m,d) {
        m = (m < 10) ? '0'+(m+1) : m+1;
        return y+'-'+m+'-'+d;
    },
    fireStartDatesSelectedEvent: function (component) {
        var evt = component.getEvent("datesQuantitySelectedEvent");
        evt.setParams({
            "startDate" : component.get('v.startDate'),
            "endDate" : component.get('v.endDate'),
            "weeks" : component.get('v.quantity')
        });
        evt.fire();
    },

    handleErrors : function(errors) {
        // Configure error toast
        var toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})