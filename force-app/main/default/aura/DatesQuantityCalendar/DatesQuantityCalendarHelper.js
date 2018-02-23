/**
 * Created by Arkadiusz Celej on 29.01.2018.
 */
({
    setupCalendar : function(component, date){
        component.set('v.calendarDate', date);
        component.set('v.year', date.getFullYear());
        component.set('v.month', date.getMonth());
        component.set('v.day', date.getDate());
        component.set('v.monthName', component.get('v.monthNames')[date.getMonth()]);
        component.set('v.monthStartWeekday', date.getDay() || 7);
        component.set('v.weeksInMonth', this.calculateWeeksInMonth(component,date));
    },

    setupDates: function(component) {
        var helper = this;
        var dates = []
        var year = component.get('v.year');
        var month = component.get('v.month')+1;
        var onlyBeginner = component.get('v.showOnlyBeginner');
        var monthStartWeekday =component.get('v.monthStartWeekday');
        var numberOfDays = helper.getNumberOfDaysInCurrentMonth(component);
        var availableDatesMap = helper.mapAvailableDates(component);
        var selectedDate = component.get('v.startDate');
        var endDate = component.get('v.endDate');

        for(var i = 1 ; i < monthStartWeekday; i++){
            dates.push({
                day:"",
                isAvailable: false,
                isPreferred: false,
            });
        }

        for(var i = 0; i < numberOfDays; i++){
            var formattedDate = helper.formatDate(year,month, i+1);
            var date = {
                day : i+1,
                isAvailable: false,
                isPreferred: false,
                isSelected: false,
                isEndDate: formattedDate == endDate
            };
            if(availableDatesMap.hasOwnProperty(formattedDate)){
                if(onlyBeginner){
                    if(availableDatesMap[formattedDate].Is_Beginner__c) {
                        date['isAvailable'] = true;
                        date['isPreferred'] = availableDatesMap[formattedDate].Is_Preferred__c;
                        date['isSelected'] = selectedDate == availableDatesMap[formattedDate].StartDate__c;
                    }
                }else{
                    date['isAvailable'] = true;
                    date['isPreferred'] = availableDatesMap[formattedDate].Is_Preferred__c;
                    date['isSelected'] = selectedDate == availableDatesMap[formattedDate].StartDate__c;
                }
            }
            dates.push(date);
        }

        var nextMonthDays = Math.ceil((dates.length) / 7 ) * 7 - (dates.length);
        for(var i = 0; i < nextMonthDays; i++){
            dates.push({
                day:"",
                isAvailable: false,
                isPreferred: false,
            });
        }
        component.set('v.calendarPageItems', dates);
    },

    formatDate: function (y,m,d) {
        m = (m < 10) ? '0'+m : m;
        d = (d < 10) ? '0'+d : d;
        return y+'-'+m+'-'+d;
    },

    calculateWeeksInMonth : function(component, date) {
        var monthWeekdayOffset = component.get('v.monthStartWeekday');
        var lastOfMonth = new Date(date.getFullYear(), date.getMonth()+1, 0).getDate();
        var lastWeekOffset = monthWeekdayOffset === 1 ? monthWeekdayOffset : 0;
        var numOfWeeks = Math.ceil( (monthWeekdayOffset + lastWeekOffset + lastOfMonth) / 7);

        return Array.apply(null, {length: numOfWeeks }).map(Function.call, Number);
    },
    calculateDaysInMonth : function(component, date) {
        var numOfDays = new Date(date.getFullYear(), date.getMonth()+1, 0).getDate();
        return Array.apply(null, {length: numOfDays}).map(Function.call, Number);
    },

    buildDate : function (component, selectedDay) {
        var year = component.get('v.year');
        var month = component.get('v.month');
        var monthNumber = 0;
        component.get('v.monthNames').forEach(function(monthName, idx){
            if(month === monthName){
                monthNumber = idx;
            }
        });
        return new Date(year, monthNumber, selectedDay,0,0,0,0);
    },

    mapAvailableDates : function(component){
        var mapped = {};
        var available = component.get('v.availableDates');
        available.forEach(function (value){
            mapped[value.StartDate__c] = value;
        });
        return mapped;
    },

    loadAvailableStartDates: function (component) {
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
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = errors[0].message;
                }
                alert(message)
            }
            else {
                // Handle other reponse states
            }
        });

        $A.enqueueAction(action);
    },

    getNumberOfDaysInCurrentMonth: function(component){
        var d = component.get('v.calendarDate');
        return new Date(d.getFullYear(), d.getMonth()+1, 0).getDate();
    }
})