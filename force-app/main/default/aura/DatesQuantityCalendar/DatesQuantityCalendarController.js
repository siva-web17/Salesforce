/**
 * Created by Arkadiusz Celej on 29.01.2018.
 */
({
    doInit : function(component, event, helper){
        var now = new Date();
        var selectedDate = component.get('v.startDate');
        if(selectedDate){
            now = new Date(selectedDate);
        }
        helper.setupCalendar(component, new Date(now.getFullYear(), now.getMonth(), 1));
        helper.loadAvailableStartDates(component);
    },

    setupDates: function (component, event, helper) {
        helper.setupDates(component);
    },

    refreshAvailableDates: function(component, event, helper){
        if(event.getParam("value")){
            helper.loadAvailableStartDates(component);
        }
    },

    previousMonth : function (component, event, helper) {
        var date = component.get('v.calendarDate');
        date.setMonth(date.getMonth() - 1);
        helper.setupCalendar(component, date);
        helper.setupDates(component);
    },

    nextMonth : function (component, event, helper) {
        var date = component.get('v.calendarDate');
        date.setMonth(date.getMonth() + 1);
        helper.setupCalendar(component, date);
        helper.setupDates(component);
    },

    previousYear : function (component, event, helper) {
        var date = component.get('v.calendarDate');
        date.setFullYear(date.getFullYear() - 1);
        helper.setupCalendar(component, date);
        helper.setupDates(component);
    },

    nextYear : function (component, event, helper) {
        var date = component.get('v.calendarDate');
        date.setFullYear(date.getFullYear() + 1);
        helper.setupCalendar(component, date);
        helper.setupDates(component);
    },


    onDaySelected: function (component,event, helper) {
        var selectedDay = event.currentTarget.dataset.day;
        var year = component.get('v.year');
        var month = component.get('v.month')+1;
        var formattedDate = helper.formatDate(year, month, selectedDay);
        component.set('v.startDate', formattedDate);
        helper.setupDates(component);
    },

    updateEndDate: function(component, event, helper){
        var start = component.get('v.startDate');
        var quantity = component.get('v.quantity');
        var endDate = new Date(start);
        endDate.setDate(endDate.getDate()+ 7*quantity - 3);
        component.set('v.endDate', helper.formatDate(endDate.getFullYear(), endDate.getMonth()+1, endDate.getDate()));
        helper.setupDates(component);
    },

    onApply: function(component, event, helper){
        var evt = component.getEvent("datesQuantitySelectedEvent");

        var params = {
            "startDate" : component.get('v.startDate'),
            "endDate" : component.get('v.endDate'),
            "weeks" : component.get('v.quantity')
        };
        evt.setParams(params);
        evt.fire();
        component.destroy();
    },

    close: function (component, event, helper) {
        component.destroy();
    }
})