/**
 * Created by Arkadiusz Celej on 07.02.2018.
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

    calculateWeeksInMonth : function(component, date) {
        var monthWeekdayOffset = component.get('v.monthStartWeekday');
        var lastOfMonth = new Date(date.getFullYear(), date.getMonth()+1, 0).getDate();
        var lastWeekOffset = monthWeekdayOffset === 1 ? monthWeekdayOffset : 0;
        var numOfWeeks = Math.ceil( (monthWeekdayOffset + lastWeekOffset + lastOfMonth) / 7);

        return Array.apply(null, {length: numOfWeeks }).map(Function.call, Number);
    },

    setupDates: function(component) {
        var helper = this;
        var dates = []
        var year = component.get('v.year');
        var month = component.get('v.month')+1;
        var monthStartWeekday = component.get('v.monthStartWeekday');
        var numberOfDays = helper.getNumberOfDaysInCurrentMonth(component);
        var selectedDate = component.get('v.value');

        for(var i = 1 ; i < monthStartWeekday; i++){
            dates.push({
                day:""
            });
        }

        for(var i = 0; i < numberOfDays; i++){
            var formattedDate = helper.formatDate(year,month, i+1);
            var date = {
                day : i+1,
                isAvailable: true,
                isSelected: formattedDate == selectedDate,
            };
            dates.push(date);
        }

        var nextMonthDays = Math.ceil((dates.length) / 7 ) * 7 - (dates.length);
        for(var i = 0; i < nextMonthDays; i++){
            dates.push({
                day:"",
                isAvailable: false
            });
        }
        component.set('v.calendarPageItems', dates);
    },

    formatDate: function (y,m,d) {
        m = (m < 10) ? '0'+m : m;
        d = (d < 10) ? '0'+d : d;
        return y+'-'+m+'-'+d;
    },

    getNumberOfDaysInCurrentMonth: function(component){
        var d = component.get('v.calendarDate');
        return new Date(d.getFullYear(), d.getMonth()+1, 0).getDate();
    }
})