/**
 * Created by Arkadiusz Celej on 31.01.2018.
 */
({
    createDatesQuantityCalendar : function (component) {
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
        var helper = this;
        $A.createComponent(
            datePickerComponentName,
            params,
            function (selectorComponent, status, error) {
                console.log('createing selector');
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(selectorComponent);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log(error);
                    // helper.handleErrors(error);
                }
            }
        );
    },

    updateCourseDatesAndQuantity:function (component, newStartDate, newQuantity, newEndDate) {
        var course = component.get('v.courseItem');
        course.Apttus_Config2__StartDate__c = newStartDate;
        course.Apttus_Config2__EndDate__c = newEndDate;
        course.Apttus_Config2__Quantity__c = newQuantity;
        course.Apttus_Config2__ExtendedQuantity__c = newQuantity;
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
                var errors = response.getError();
                var message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = errors[0].message;
                }
                this.handleErrors(message);
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
                courseStartDate = this.addDays(courseStartDate, startDatesSettings.StartDateOffSet__c);
                courseEndDate = this.addDays(courseEndDate, startDatesSettings.EndDateOffSet__c);
                items[i].Apttus_Config2__StartDate__c = this.formatDate(courseStartDate.getFullYear(), courseStartDate.getMonth()+1, courseStartDate.getDate());
                items[i].Apttus_Config2__EndDate__c = this.formatDate(courseEndDate.getFullYear(), courseEndDate.getMonth()+1, courseEndDate.getDate());
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
        var dateDays = date.getDate();
        date.setDate(dateDays+days);
        return date;
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