/**
 * Created by Arkadiusz Celej on 30.01.2018.
 */
({
    doInit: function(component, event, helper){
        helper.findCourseItem(component);
        var calendarVisible = component.get('v.calendarVisible');
        if(calendarVisible){
            helper.createDatesQuantityCalendar(component);
        }
        helper.loadAvailableStartDateSettings(component);
    },

    showCalendar: function (component, event, helper) {
        helper.createDatesQuantityCalendar(component);
    },

    handleSelectedDatesEvent: function (component, event, helper) {
        var startDate = event.getParam('startDate');
        var endDate = event.getParam('endDate');
        var quantity = event.getParam('weeks');

        helper.updateCourseDatesAndQuantity(component, startDate, quantity, endDate);
    },

    onCourseItemStartDateChange : function (component, event, helper) {
        helper.updateArticleDates(component);
    },

    onCourseItemQuantityChange : function (component, event, helper) {
        var courseItem = component.get('v.courseItem');
        courseItem.Apttus_Config2__EndDate__c = helper.calculateCourseEndDate(courseItem.Apttus_Config2__StartDate__c, courseItem.Apttus_Config2__Quantity__c);
        component.set('v.courseItem', courseItem);
        helper.updateArticleDates(component);
    },

    onArticleQuantityChange: function (component, event, helper) {
        var items = component.get('v.items');
        var startDateSetting = component.get('v.startDateSettings');
        for(var i = 0; i < items.length; i++){
            helper.recalculateEndDate(items[i], startDateSetting);
        }
        component.set('v.items', items);
    },

    onItemsChange: function (component, event, helper) {
        var event = component.getEvent('itemsChangedEvent');
        var courseItem = component.get('v.courseItem');
        var items = component.get('v.items');
        console.log('items changed');
        event.setParams({
            'items' : items.concat(courseItem),
            'lineNumber' : courseItem.Apttus_Config2__LineNumber__c
        });
        event.fire();
    }
})