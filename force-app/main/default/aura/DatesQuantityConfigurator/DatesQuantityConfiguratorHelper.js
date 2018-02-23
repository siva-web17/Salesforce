/**
 * Created by Arkadiusz Celej on 30.01.2018.
 */
({
    getCartItems : function(component, cartId){
        var action = component.get('c.getCartLineItems');
        action.setParams({
            'cartId': cartId
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set('v.lineItemsByItemNumber', returnValue);
                    this.createDatesQuantityConfiguratorItems(component, returnValue);
                }
                else if (state === "ERROR") {
                    var errors = response.getError()
                    var message = 'Unknown error';
                    if(errors && Array.isArray(errors) && errors.length > 0){
                        message = errors[0].message;
                    }
                    this.handleErrors(message);
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    toggleSpinner : function (component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, "slds-hide");
    },

    showSpinner: function (component) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    },

    saveCartItems: function(component, changedLineItemsByLineNumber){
        this.showSpinner(component);
        var lineItems = [];
        for(var key in changedLineItemsByLineNumber) {
            if(changedLineItemsByLineNumber[key] && changedLineItemsByLineNumber[key].length > 0){
                lineItems = lineItems.concat(changedLineItemsByLineNumber[key]);
            }
        }
        var action = component.get('c.saveLineItems');
        action.setParams({
            'cartId': component.get('v.cartId'),
            'lineItems': lineItems,
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.repriceCartItems(component);
                }
                else if (state === "ERROR") {
                    var errors = response.getError()
                    var message = 'Unknown error';
                    if(errors && Array.isArray(errors) && errors.length > 0){
                        message = errors[0].message;
                    }
                    this.handleErrors(message);
                    this.hideSpinner(component);
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    repriceCartItems: function (component) {
        this.showSpinner(component);
        var action = component.get('c.repriceCart');
        action.setParams({
            'cartId': component.get('v.cartId'),
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var pendingSize = response.getReturnValue();
                    if(pendingSize > 0){
                        this.repriceCartItems(component);
                        this.showSpinner(component);
                    }else{
                        window.location.href = component.get('v.backToCartUrl');
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError()
                    var message = 'Unknown error';
                    if(errors && Array.isArray(errors) && errors.length > 0){
                        message = errors[0].message;
                    }
                    this.handleErrors(message);
                    this.hideSpinner(component);
                }
                else {
                    // Handle other reponse states
                }
            }
        );

        $A.enqueueAction(action);
    },

    createDatesQuantityConfiguratorItems : function (component, mappedItems) {
        console.log('congifItems',mappedItems);
        var numberOfCourses = Object.keys(mappedItems).length;
        var lineNumber = 0;
        for(var key in mappedItems){
            lineNumber++;
            var items = mappedItems[key];
            if(items && items.length > 0) {
                $A.createComponent(
                    "c:DatesQuantityConfiguratorItem",
                    {
                        "items": items,
                        "calendarVisible" : numberOfCourses == 1,
                        "lineNumber": lineNumber
                    },
                    function (configurator, status, error) {
                        if (status === "SUCCESS") {
                            var body = component.get("v.body");
                            body.push(configurator);
                            component.set("v.body", body);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }
                        else if (status === "ERROR") {
                            console.log(error);
                            this.handleErrors(error);
                        }
                    }
                );
            }
        }
    },

    navigateBackToCart: function (component, event, helper) {

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