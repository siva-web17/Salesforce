/**
 * Created by Arkadiusz Celej on 31.01.2018.
 */
({
    createDatesQuantityCalendar : function (component) {
        var helper = this;
        var item = component.get('v.courseItem');
        var datePickerComponentName = 'c:DatesQuantityCalendar';
        var params = {
                "lineItem": item,
                "startDate": item.Apttus_Config2__StartDate__c,
                "quantity": item.Apttus_Config2__Quantity__c
            };
        if(item && item.Apttus_Config2__OptionId__r && item.Apttus_Config2__OptionId__r.APTS_AY_Course_Type__c){
            datePickerComponentName = 'c:DatesQuantityCalendarAY';
        }
        $A.createComponent(
            datePickerComponentName,
            params,
            function (selectorComponent, status, error) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(selectorComponent);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    component.set('v.errorMessage', error);
                }
            }
        );
    },

    updateCourseDatesAndQuantity:function (component, newStartDate, newQuantity, newEndDate) {
        var course = component.get('v.courseItem');
        course.Apttus_Config2__StartDate__c = newStartDate;
        course.Apttus_Config2__Quantity__c = newQuantity;
        course.Apttus_Config2__ExtendedQuantity__c = newQuantity;
        if(newEndDate) {
            course.Apttus_Config2__EndDate__c = newEndDate;
        }
        component.set('v.courseItem', course);
        this.updateArticleDates(component);
    },

    calculateCourseEndDate: function (startDate, quantity) {
        startDate = new Date(startDate);
        var courseDays = (quantity * 7) - 3;
        var endDate = this.addDays(startDate, courseDays);;
        return this.formatDate(endDate.getFullYear(), endDate.getMonth() + 1, endDate.getDate());
    },

    formatDate: function (y,m,d) {
        m = (m < 10) ? '0'+m : m;
        d = (d < 10) ? '0'+d : d;
        return y+'-'+m+'-'+d;
    },

    findCourseItem : function(component){
        var items = component.get('v.items');
        for(var i = 0; Array.isArray(items) && i < items.length; i++){
            if(items[i].APTS_Product_Type__c == 'Course'){
                var course = items.splice(i, 1)[0];
                component.set('v.courseItem', course);
                component.set('v.items', items);
                break;
            }
        }
    },

    loadAvailableStartDateSettings:function (component) {
        var helper = this;
        var action = component.get('c.getAvailableStartDateSettings');
        action.setParams({
            'item' : component.get('v.courseItem')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue.length > 0) {
                    component.set('v.startDateSettings', returnValue[0]);
                }
            }
            else if (state === "ERROR") {
                helper.handleErrors(response.getError());
            }
            else {
                // Handle other reponse states
            }
        });

        $A.enqueueAction(action);
    },

    updateArticleDates: function (component) {
        var startDatesSettings = component.get('v.startDateSettings');
        var courseItem = component.get('v.courseItem');
        var items = component.get('v.items');

        if(!courseItem.Apttus_Config2__StartDate__c || !courseItem.Apttus_Config2__EndDate__c || !courseItem.Apttus_Config2__Quantity__c || !startDatesSettings){
            return;
        }
        var courseStartDate = new Date(courseItem.Apttus_Config2__StartDate__c);
        var courseEndDate = new Date(courseItem.Apttus_Config2__EndDate__c);
        var courseQuantity = courseItem.Apttus_Config2__Quantity__c;

        for(var i = 0 ; i < items.length; i++){
            if(items[i].Apttus_Config2__Uom__c == $A.get("$Label.c.LineItemUOMWeek")){
                var startDate = this.addDays(courseStartDate, startDatesSettings.StartDateOffSet__c);
                var endDate = this.addDays(courseEndDate, startDatesSettings.EndDateOffSet__c);
                items[i].Apttus_Config2__StartDate__c = this.formatDate(startDate.getFullYear(), startDate.getMonth()+1, startDate.getDate());
                items[i].Apttus_Config2__EndDate__c = this.formatDate(endDate.getFullYear(), endDate.getMonth()+1, endDate.getDate());
                items[i].Apttus_Config2__Quantity__c = courseQuantity;
            }
        }
        component.set('v.items',items);
    },

    recalculateEndDate: function (item, startDateSetting) {
        var startDate = new Date(item.Apttus_Config2__StartDate__c);
        // startDate = this.addDays(startDate)
        var quantity = item.Apttus_Config2__Quantity__c;
        var endDate = this.addDays(startDate, 7*quantity);
        item.Apttus_Config2__EndDate__c = this.formatDate(endDate.getFullYear(), endDate.getMonth()+1, endDate.getDate());
        return item;
    },

    addDays: function(date, days){
        var result = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        var dateDays = date.getDate();
        result.setDate(dateDays+days);
        return result;
    },

    handleErrors : function(errors) {
        var message = 'Unknown error';
        if (errors) {
            if (errors[0] && errors[0].message) {
                message = errors[0].message;
            }
        }
        component.set('v.errorMessage', message);
    }
})