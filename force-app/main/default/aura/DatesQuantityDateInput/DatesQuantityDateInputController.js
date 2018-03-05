/**
 * Created by Arkadiusz Celej on 07.02.2018.
 */
({
    doInit : function(component, event, helper){
        var value = component.get('v.value');
        if(value){
            helper.setupCalendar(component, new Date(value));
        }else{
            helper.setupCalendar(component, new Date());
        }
        helper.setupDates(component);
    },

    toggle: function (component) {
        component.set('v.visible', !component.get('v.visible'));
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
        component.set('v.value', formattedDate);
        component.set('v.visible', false);
        helper.setupDates(component);
    },
})