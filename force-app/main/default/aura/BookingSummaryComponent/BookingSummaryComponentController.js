({
    doInit: function(component, event, helper) {
        var action = component.get("c.dataBind");
        action.setParams({
            recordId: component.get("v.RecordId")
        });
        action.setCallback(this, function(response) {
            console.log(response);
            var state = response.getState();
            if (state == "SUCCESS") {
                var json_text = JSON.stringify(response.getReturnValue());
                component.set("v.wrapperList", response.getReturnValue());
                var u = component.get("v.wrapperList");
                if (!u.personAcc.PersonMailingStreet > 0) {
                    component.set("v.wrapperList.personAcc.PersonMailingStreet", '');
                }
                component.set("v.pickGender", u.personAcc.Gender__c);
                var arrayGenderMapKeys = [];
                var result = u.GenderPickList;
                var p = component.get("v.pickGender");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arrayGenderMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.GenderList", arrayGenderMapKeys);
                component.set("v.selectedSalesOffice", u.opp.SalesOffice__c);
                var arraySalesMapKeys = [];
                var result = u.SalesOfficePickList;
                var p = component.get("v.selectedSalesOffice");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arraySalesMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.SalesOfficeList", arraySalesMapKeys);
                component.set("v.selectedCountry", u.personAcc.PersonMailingCountry);
                var arrayMailingCountryMapKeys = [];
                var result = u.MailingCountryPickList;
                var p = component.get("v.selectedCountry");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arrayMailingCountryMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.MaillingCountryList", arrayMailingCountryMapKeys);
                component.set("v.selectedBirthCountry", u.personAcc.BirthCountry__c);

                var arrayBirthCountryMapKeys = [];
                var result = u.BirthCountryPickList;
                var p = component.get("v.selectedBirthCountry");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arrayBirthCountryMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.BirthCountryList", arrayBirthCountryMapKeys);
                component.set("v.selectedNationality", u.personAcc.Nationality__c);
                var arrayNationMapKeys = [];
                var result = u.NationalityPickList;
                var p = component.get("v.selectedNationality");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arrayNationMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.NationalityList", arrayNationMapKeys);
                //------------------------------------------------------------
                var otherNation = u.personAcc.OtherNationalities__c;
                var PleaseSelectOtherPicklist = $A.get("$Label.c.PleaseSelect");
                if (otherNation) {
                    var SelectedNation = otherNation.split(";");
                    var AllNationalitiesList = u.OtherNationalityPickList;
                    var SelectedLabelsOther = [];
                    for (var i = 0; i < SelectedNation.length; i++) {
                        if (AllNationalitiesList.hasOwnProperty(SelectedNation[i])) {
                            SelectedLabelsOther.push(AllNationalitiesList[SelectedNation[i]]);
                        }
                    }
                    if (SelectedNation.length > 0) {
                        component.set("v.OtherNationalityTextInfo", SelectedLabelsOther.toString());
                    } else {
                        component.set("v.OtherNationalityTextInfo", PleaseSelectOtherPicklist);
                    }
                } else {
                    component.set("v.OtherNationalityTextInfo", PleaseSelectOtherPicklist);
                }

                component.set("v.selectedOtherNationalityNameMulti", otherNation != null ? otherNation.split(";") : "");
                component.set("v.OtherNationalityList", u.OtherNationalityPickList);
                //---------------------------------------------------------------
                component.set("v.selectedPassportType", u.personAcc.PassportType__c);
                var arrayPassportMapKeys = [];
                var result = u.PassportPickList;
                var p = component.get("v.selectedPassportType");
                var isSelected = false;
                for (var key in result) {
                    if (p == key || p == result[key]) {
                        isSelected = true;
                    }
                    arrayPassportMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                    isSelected = false;
                }
                component.set("v.PassportList", arrayPassportMapKeys);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                var ErrorMessage = $A.get('$Label.c.IfInactiveOpportunityAndClickCreateBooking');

                toastEvent.setParams({
                    title: "Failure!",
                    type: "error",
                    message: ErrorMessage,
                });
                toastEvent.fire();
                window.setTimeout(
                    $A.getCallback(function() {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            recordId: component.get("v.RecordId")
                        });
                        navEvt.fire();
                    }),
                    2000
                );
            }
            component.set("v.rendering",false);
        });
        $A.enqueueAction(action);

    },

    navigateToSObject: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get("v.RecordId")
        });
        navEvt.fire();
    },

    pathWayforward: function(component, event, helper) {
        var whichOne = event.getSource().getLocalId();
    },
    moveNext: function(cmp, event, helper) {
        var setGender = cmp.get("v.pickGender");
        cmp.set("v.wrapperList.personAcc.Gender__c", setGender);
        if(setGender == 'Other'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                type: "error",
                message: "Please select valid gender."
            });
            toastEvent.fire();
            return false;
        }
        var setCountry = cmp.get("v.selectedCountry");
        cmp.set("v.wrapperList.personAcc.PersonMailingCountry", setCountry);

        var path_1_Fields = cmp.find("path_1_Fields").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);

        if (path_1_Fields) {
            var whichOne = event.getSource().getLocalId();

            if (whichOne == "next1") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                $A.util.removeClass(finishBooking, "slds-button_brand");
                //helper.accountData(cmp, event, helper);
            } else if (whichOne == "next2") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                // $A.util.removeClass(finishBooking, "slds-button_brand");
            } else if (whichOne == "next4") {
                var currentHeader = cmp.find("header-3");
                var nextHeader = cmp.find("header-4");
                var CurrentPanel = cmp.find("path-content-3");
                var nextPanel = cmp.find("path-content-4");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Enable Button
                // $A.util.addClass(finishBooking, "slds-button_brand");
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                type: "error",
                message: "Please fill your information correctly."
            });
            toastEvent.fire();
        }

        //$A.enqueueAction(cmp.get('c.submit'));
    },
    moveNext2: function(cmp, event, helper) {
        var path_2_Fields = cmp.find("path_2_Fields").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);

        if (path_2_Fields) {
            var whichOne = event.getSource().getLocalId();
            //console.log(whichOne);
            if (whichOne == "next1") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                $A.util.removeClass(finishBooking, "slds-button_brand");
            } else if (whichOne == "next2") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                $A.util.removeClass(finishBooking, "slds-button_brand");
            } else if (whichOne == "next3") {
                var currentHeader = cmp.find("header-3");
                var nextHeader = cmp.find("header-4");
                var CurrentPanel = cmp.find("path-content-3");
                var nextPanel = cmp.find("path-content-4");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Enable Button
                // $A.util.addClass(finishBooking, "slds-button_brand");
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                type: "error",
                message: "Please fill your information correctly."
            });
            toastEvent.fire();
        }
        //$A.enqueueAction(cmp.get('c.submit'));
    },
    moveNext3: function(cmp, event, helper) {
        var selectedOtherNationalityNameMulti = cmp.get("v.selectedOtherNationalityNameMulti");
        var selectedValues = "";
        for (var i = 0; i < selectedOtherNationalityNameMulti.length; i++) {
            selectedValues = selectedValues + selectedOtherNationalityNameMulti[i] + ";";
        }
        selectedValues = selectedValues.slice(0, -1);
        cmp.set("v.wrapperList.personAcc.OtherNationalities__c", selectedValues);

        var setPassport = cmp.get("v.selectedPassportType");
        cmp.set("v.wrapperList.personAcc.PassportType__c", setPassport);

        var setOther = cmp.get("v.selectedNationality");
        cmp.set("v.wrapperList.personAcc.Nationality__c", setOther);

        var setBirthCountry = cmp.get("v.selectedBirthCountry");
        cmp.set("v.wrapperList.personAcc.BirthCountry__c", setBirthCountry);

        var path_3_Fields = cmp.find("path_3_Fields").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);

        if (path_3_Fields) {
            var whichOne = event.getSource().getLocalId();
            if (whichOne == "next1") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                $A.util.removeClass(finishBooking, "slds-button_brand");
            } else if (whichOne == "next2") {
                var currentHeader = cmp.find("header-1");
                var nextHeader = cmp.find("header-3");
                var CurrentPanel = cmp.find("path-content-1");
                var nextPanel = cmp.find("path-content-3");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Disable Button
                $A.util.removeClass(finishBooking, "slds-button_brand");
            } else if (whichOne == "next4") {
                var currentHeader = cmp.find("header-3");
                var nextHeader = cmp.find("header-4");
                var CurrentPanel = cmp.find("path-content-3");
                var nextPanel = cmp.find("path-content-4");
                var finishBooking = cmp.find("finishBooking");
                //For Next Header
                $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
                $A.util.removeClass(nextHeader, "slds-is-incomplete");
                //For Current header
                $A.util.addClass(currentHeader, "slds-is-complete");
                $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
                //PanelCurrent
                $A.util.addClass(CurrentPanel, "slds-hide");
                $A.util.removeClass(CurrentPanel, "slds-show");
                //PanelCurrent
                $A.util.addClass(nextPanel, "slds-show");
                $A.util.removeClass(nextPanel, "slds-hide");
                //Enable Button
                $A.util.addClass(finishBooking, "slds-button_brand");
                helper.insertRecord(cmp, event);
                cmp.set("v.isFinishBooking", true);
                cmp.set("v.DisableFinishBooking", true);
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                type: "error",
                message: "Please fill your information correctly."
            });
            toastEvent.fire();
        }
    },
    moveNext4: function(cmp, event, helper) {
        var setChannel = cmp.get("v.selectedBookingChannel");
        cmp.set("v.wrapperList.Quote.BookingChannel__c", setChannel);

        var setBooking = cmp.get("v.selectedBookingType");
        cmp.set("v.wrapperList.Quote.BookingType__c", setBooking);

        var setCurrency = cmp.get("v.selectedCurrency");
        cmp.set("v.wrapperList.Quote.CurrencyIsoCode", setCurrency);

        //helper.insertRecord(cmp, event);
        cmp.set("v.isFinishBooking", true);
        var path_4_Fields = cmp.find("path_4_Fields").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);

        if (path_4_Fields) {
            var whichOne = event.getSource().getLocalId();
            console.log(whichOne);
            if (whichOne == "next4") {
                helper.insertRecord(cmp, event);
                cmp.set("v.isFinishBooking", true);
                cmp.set("v.DisableFinishBooking", true);
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                type: "error",
                message: "Please fill your information correctly."
            });
            toastEvent.fire();
        }
        //		$A.enqueueAction(cmp.get('c.submit'));
    },
    movePrev: function(cmp, event, helper) {
        var whichOne = event.getSource().getLocalId();
        console.log(whichOne);
        if (whichOne == "prev2") {
            var currentHeader = cmp.find("header-3");
            var prevHeader = cmp.find("header-1");
            var CurrentPanel = cmp.find("path-content-3");
            var prevPanel = cmp.find("path-content-1");
            var finishBooking = cmp.find("finishBooking");
            //For Prev Header
            $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
            $A.util.removeClass(prevHeader, "slds-is-complete");
            //For Current header
            $A.util.addClass(currentHeader, "slds-is-incomplete");
            $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
            //   //PanelCurrent
            $A.util.addClass(CurrentPanel, "slds-hide");
            $A.util.removeClass(CurrentPanel, "slds-show");
            //PanelCurrent
            $A.util.addClass(prevPanel, "slds-show");
            $A.util.removeClass(prevPanel, "slds-hide");
            //Disable Button
            $A.util.removeClass(finishBooking, "slds-button_brand");
        } else if (whichOne == "prev3") {
            var currentHeader = cmp.find("header-3");
            var prevHeader = cmp.find("header-1");
            var CurrentPanel = cmp.find("path-content-3");
            var prevPanel = cmp.find("path-content-1");
            var finishBooking = cmp.find("finishBooking");
            //For Prev Header
            $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
            $A.util.removeClass(prevHeader, "slds-is-complete");
            //For Current header
            $A.util.addClass(currentHeader, "slds-is-incomplete");
            $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
            //   //PanelCurrent
            $A.util.addClass(CurrentPanel, "slds-hide");
            $A.util.removeClass(CurrentPanel, "slds-show");
            //PanelCurrent
            $A.util.addClass(prevPanel, "slds-show");
            $A.util.removeClass(prevPanel, "slds-hide");
            //Disable Button
            $A.util.removeClass(finishBooking, "slds-button_brand");
        } else if (whichOne == "prev4") {
            var currentHeader = cmp.find("header-4");
            var prevHeader = cmp.find("header-3");
            var CurrentPanel = cmp.find("path-content-4");
            var prevPanel = cmp.find("path-content-3");
            var finishBooking = cmp.find("finishBooking");
            //For Prev Header
            $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
            $A.util.removeClass(prevHeader, "slds-is-complete");
            //For Current header
            $A.util.addClass(currentHeader, "slds-is-incomplete");
            $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
            //   //PanelCurrent
            $A.util.addClass(CurrentPanel, "slds-hide");
            $A.util.removeClass(CurrentPanel, "slds-show");
            //PanelCurrent
            $A.util.addClass(prevPanel, "slds-show");
            $A.util.removeClass(prevPanel, "slds-hide");
            //Enable Button
            $A.util.removeClass(finishBooking, "slds-button_brand");
        } else if (whichOne == "prev5") {
            var currentHeader = cmp.find("header-5");
            var prevHeader = cmp.find("header-4");
            var CurrentPanel = cmp.find("path-content-5");
            var prevPanel = cmp.find("path-content-4");
            var finishBooking = cmp.find("finishBooking");
            //For Prev Header
            $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
            $A.util.removeClass(prevHeader, "slds-is-complete");
            //For Current header
            $A.util.addClass(currentHeader, "slds-is-incomplete");
            $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
            //   //PanelCurrent
            $A.util.addClass(CurrentPanel, "slds-hide");
            $A.util.removeClass(CurrentPanel, "slds-show");
            //PanelCurrent
            $A.util.addClass(prevPanel, "slds-show");
            $A.util.removeClass(prevPanel, "slds-hide");
            //Enable Button
            $A.util.removeClass(finishBooking, "slds-button_brand");
            $A.util.removeClass(finishBooking, "slds-button_brand");
        }
    },
    preValidateSubmit: function(cmp, event, helper) {
        $A.util.removeClass(finishBooking, "slds-button_brand");
        var finishBooking = cmp.find("finishBooking");
        var path_4_Fields = cmp.find("path_4_Fields").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);
        if (path_4_Fields) {
            $A.util.addClass(finishBooking, "slds-button_brand");
        } else {
            $A.util.removeClass(finishBooking, "slds-button_brand");
        }
    },
    onClick: function(cmp, evt, helper) {
        var allValid = cmp.find("field").reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if (allValid) {
            alert("All form entries look valid. Ready to submit!");
        } else {
            alert("Please update the invalid form entries and try again.");
        }
    },

    onClickTest: function(component, event, helper) {
        var inputCmp = component.find("path_1_Fields");
        console.log(event.getSource().get("v.name"));
    },
    valueChangeValidation: function(component, event, helper) {
        var inputField = component.find("inputField");
        var value = component.get("v.value");
        if (value != "foo") {
            inputField.set("v.validity", { valid: false, badInput: true });
        }
    },
    validateDate: function(cmp, event, helper) {
        var currentAge = moment().diff(cmp.get("v.wrapperList.personAcc.PersonBirthdate"), "years", false);
        if (cmp.get("v.wrapperList.personAcc.PersonBirthdate") != null) {
            if (!moment(cmp.get("v.wrapperList.personAcc.PersonBirthdate")).isBefore(new Date()) && !moment(cmp.get("v.selectedActionDate")).isSame(moment().format("YYYY-MM-DD"))) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    type: "error",
                    message: "Future date cannot be selected"
                });
                toastEvent.fire();
            } else {
                cmp.set("v.wrapperList.age", currentAge);
            }
        }
    }
});