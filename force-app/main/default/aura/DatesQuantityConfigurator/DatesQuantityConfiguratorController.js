/**
 * Created by Arkadiusz Celej on 30.01.2018.
 */
({
    doInit: function (component, event, helper) {
        helper.getCartItems(component, component.get('v.cartId'));
    },

    saveCartLineItems: function (component, event, helper) {
        var changedLineItemsByLineNumber = component.get('v.changedLineItemsByLineNumber');
        helper.saveCartItems(component, changedLineItemsByLineNumber);
    },

    onItemsChange: function (component, event, helper) {
        var changedLineItemsByLineNumber = component.get('v.changedLineItemsByLineNumber');
        var eventItems = event.getParam('items');
        var eventLineNumber = event.getParam('lineNumber');
        changedLineItemsByLineNumber[eventLineNumber] = eventItems;
        component.set('v.changedLineItemsByLineNumber', changedLineItemsByLineNumber);
    },

    back:function (component, event, helper) {
        window.location.href = component.get('v.backToCartUrl');
    },

    clearError: function (component, event, helper) {
        component.set('v.errorMessage','');
    }
})