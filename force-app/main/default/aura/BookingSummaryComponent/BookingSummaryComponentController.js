({
	doInit: function(component, event, helper) {
		var quoteid = component.get('v.QuoteId');
		var Oppid = component.get('v.OpportunityID');
		var action = component.get('c.dataBind');
		action.setParams({
			QuoteId: component.get('v.QuoteId'),
		});

		action.setCallback(this, function(response) {
			//store state of response
			var state = response.getState();

			if (state == 'SUCCESS') {
				//set response value in wrapperList attribute on component.
				var json_text = JSON.stringify(response.getReturnValue());
				console.log(json_text);
				component.set('v.wrapperList', response.getReturnValue());
				var u = component.get('v.wrapperList');
				component.set('v.pickGender', u.personAcc.Gender__c);
				var arrayGenderMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.GenderPickList;
				var p = component.get('v.pickGender');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayGenderMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				component.set('v.GenderList', arrayGenderMapKeys);
				//console.log('SalesMadeBy====> ' +component.get('u.Quote.SalesMadeby__r.Name'));

				component.set('v.selectedSalesOffice', u.opp.SalesOffice__c);
				var arraySalesMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.SalesOfficePickList;
				var p = component.get('v.selectedSalesOffice');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arraySalesMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.SalesOfficeList', arraySalesMapKeys);

				component.set('v.selectedCountry', u.personAcc.PersonMailingCountry);
				var arrayMailingCountryMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.MailingCountryPickList;
				var p = component.get('v.selectedCountry');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayMailingCountryMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.MaillingCountryList', arrayMailingCountryMapKeys);

                component.set('v.selectedBirthCountry', u.personAcc.BirthCountry__c);
                				var arrayBirthCountryMapKeys = [];
                				//Store the response of apex controller (return map)
                				var result = u.BirthCountryPickList;
                				var p = component.get('v.selectedBirthCountry');
                				//Set the store response[map] to component attribute, which name is map and type is map.
                				//component.set('v.companyMap', result);
                				var isSelected = false;
                				for (var key in result) {
                					//arrayMapKeys.push(key);
                					if (p == key || p == result[key]) {
                						isSelected = true;
                					}
                					arrayBirthCountryMapKeys.push({ value: result[key], key: key, Selected: isSelected });
                					isSelected = false;
                				}
                				//Set the list of keys.
                				component.set('v.BirthCountryList', arrayBirthCountryMapKeys);

				//component.set('v.selectedState',u.personAcc.PersonMailingState);
				component.set('v.selectedNationality', u.personAcc.Nationality__c);
				var arrayNationMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.NationalityPickList;
				var p = component.get('v.selectedNationality');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayNationMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.NationalityList', arrayNationMapKeys);

				component.set('v.selectedOtherNationality', u.personAcc.OtherNationalities__c);
				var arrayOtherNationMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.OtherNationalityPickList;
				var p = component.get('v.selectedOtherNationality');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayOtherNationMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.OtherNationalityList', arrayOtherNationMapKeys);

				component.set('v.selectedPassportType', u.personAcc.PassportType__c);
				var arrayPassportMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.PassportPickList;
				var p = component.get('v.selectedPassportType');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayPassportMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.PassportList', arrayPassportMapKeys);

				component.set('v.selectedBookingChannel', u.Quote.BookingChannel__c);
				var arrayBookingChannelMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.BookingChannelPickList;
				var p = component.get('v.selectedBookingChannel');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayBookingChannelMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.BookingChannelList', arrayBookingChannelMapKeys);

				component.set('v.selectedBookingType', u.Quote.BookingType__c);
				var arrayBookingTypeMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.BookingTypePickList;
				var p = component.get('v.selectedBookingType');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayBookingTypeMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}

				//Set the list of keys.
				component.set('v.BookingTypeList', arrayBookingTypeMapKeys);

				component.set('v.selectedCurrency', u.Quote.CurrencyIsoCode);
				var arrayCurrencyMapKeys = [];
				//Store the response of apex controller (return map)
				var result = u.CurrencyPickList;
				var p = component.get('v.selectedCurrency');
				//Set the store response[map] to component attribute, which name is map and type is map.
				//component.set('v.companyMap', result);
				var isSelected = false;
				for (var key in result) {
					//arrayMapKeys.push(key);
					if (p == key || p == result[key]) {
						isSelected = true;
					}
					arrayCurrencyMapKeys.push({ value: result[key], key: key, Selected: isSelected });
					isSelected = false;
				}
				//Set the list of keys.
				component.set('v.CurrencyList', arrayCurrencyMapKeys);
			}
		});
		$A.enqueueAction(action);
	},

	pathWayforward: function(component, event, helper) {
		// console.log(event.currentTarget);
		// console.log(event.target.getAttribute("data-path"));
		// var getPath = event.target.getAttribute("data-path");
		// var toggleText = component.find("path-content-1");
		// $A.util.toggleClass(toggleText, "panel-display-none");
		var whichOne = event.getSource().getLocalId();
	},
	moveNext: function(cmp, event, helper) {
		var setGender = cmp.get('v.pickGender');
		cmp.set('v.wrapperList.personAcc.Gender__c', setGender);

		var setCountry = cmp.get('v.selectedCountry');
		cmp.set('v.wrapperList.personAcc.PersonMailingCountry', setCountry);

		var age = cmp.get('v.wrapperList.personAcc.age__c');
		//alert(age);
		var fetchAgeID = cmp.find('ageField');
		//alert(fetchAgeID);
		var fetchdob = cmp.get('v.wrapperList.personAcc.PersonBirthdate');
		//alert(fetchdob);
		var fetchDOBID = cmp.find('dob');
		//alert(fetchDOBID);
		var today = new Date();
		var dd = today.getDate();
		var mm = today.getMonth() + 1; //January is 0!
		var yyyy = today.getFullYear();
		if (dd < 10) {
			dd = '0' + dd;
		}
		if (mm < 10) {
			mm = '0' + mm;
		}
		today = yyyy + '-' + mm + '-' + dd;
		//alert(today);
		if (fetchdob > today) {
			fetchDOBID.set('v.errors', [{ message: 'DOB cannot be future date: ' + fetchdob }]);
		} else if (age < 0) {
			fetchAgeID.set('v.errors', [{ message: 'Age cannot negative: ' + age }]);
		} else {
			var path_1_Fields = cmp.find('path_1_Fields').reduce(function(validSoFar, inputCmp) {
				inputCmp.showHelpMessageIfInvalid();
				return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
			}, true);
			//alert('%%%%%%%%%%%%%'+path_1_Fields);
		}
		if (path_1_Fields) {
			var whichOne = event.getSource().getLocalId();

			//alert(whichOne);
			if (whichOne == 'next1') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				$A.util.removeClass(finishBooking, 'slds-button_brand');
				helper.accountData(cmp, event, helper);
			} else if (whichOne == 'next2') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				// $A.util.removeClass(finishBooking, "slds-button_brand");
			} else if (whichOne == 'next3') {
				var currentHeader = cmp.find('header-3');
				var nextHeader = cmp.find('header-4');
				var CurrentPanel = cmp.find('path-content-3');
				var nextPanel = cmp.find('path-content-4');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Enable Button
				// $A.util.addClass(finishBooking, "slds-button_brand");
			}
		} else {
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				title: 'Error!',
				type: 'error',
				message: 'Please fill your information correctly.',
			});
			toastEvent.fire();
		}

		//$A.enqueueAction(cmp.get('c.submit'));
	},
	moveNext2: function(cmp, event, helper) {
		var path_2_Fields = cmp.find('path_2_Fields').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
		}, true);

		if (path_2_Fields) {
			var whichOne = event.getSource().getLocalId();
			//console.log(whichOne);
			if (whichOne == 'next1') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				$A.util.removeClass(finishBooking, 'slds-button_brand');
			} else if (whichOne == 'next2') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				$A.util.removeClass(finishBooking, 'slds-button_brand');
			} else if (whichOne == 'next3') {
				var currentHeader = cmp.find('header-3');
				var nextHeader = cmp.find('header-4');
				var CurrentPanel = cmp.find('path-content-3');
				var nextPanel = cmp.find('path-content-4');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Enable Button
				// $A.util.addClass(finishBooking, "slds-button_brand");
			}
		} else {
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				title: 'Error!',
				type: 'error',
				message: 'Please fill your information correctly.',
			});
			toastEvent.fire();
		}
		//$A.enqueueAction(cmp.get('c.submit'));
	},
	moveNext3: function(cmp, event, helper) {
		var setNation = cmp.get('v.selectedOtherNationality');
		cmp.set('v.wrapperList.personAcc.OtherNationalities__c', setNation);

		var setPassport = cmp.get('v.selectedPassportType');
		cmp.set('v.wrapperList.personAcc.PassportType__c', setPassport);
		var setOther = cmp.get('v.selectedNationality');
		cmp.set('v.wrapperList.personAcc.Nationality__c', setOther);

		var path_3_Fields = cmp.find('path_3_Fields').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
		}, true);

		if (path_3_Fields) {
			var whichOne = event.getSource().getLocalId();
			//console.log(whichOne);
			if (whichOne == 'next1') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				$A.util.removeClass(finishBooking, 'slds-button_brand');
			} else if (whichOne == 'next2') {
				var currentHeader = cmp.find('header-1');
				var nextHeader = cmp.find('header-3');
				var CurrentPanel = cmp.find('path-content-1');
				var nextPanel = cmp.find('path-content-3');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Disable Button
				$A.util.removeClass(finishBooking, 'slds-button_brand');
			} else if (whichOne == 'next3') {
				var currentHeader = cmp.find('header-3');
				var nextHeader = cmp.find('header-4');
				var CurrentPanel = cmp.find('path-content-3');
				var nextPanel = cmp.find('path-content-4');
				var finishBooking = cmp.find('finishBooking');
				//For Next Header
				$A.util.addClass(nextHeader, 'slds-is-current slds-is-active');
				$A.util.removeClass(nextHeader, 'slds-is-incomplete');
				//For Current header
				$A.util.addClass(currentHeader, 'slds-is-complete');
				$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
				//PanelCurrent
				$A.util.addClass(CurrentPanel, 'slds-hide');
				$A.util.removeClass(CurrentPanel, 'slds-show');
				//PanelCurrent
				$A.util.addClass(nextPanel, 'slds-show');
				$A.util.removeClass(nextPanel, 'slds-hide');
				//Enable Button
				$A.util.addClass(finishBooking, 'slds-button_brand');
			}
		} else {
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				title: 'Error!',
				type: 'error',
				message: 'Please fill your information correctly.',
			});
			toastEvent.fire();
		}
		//$A.enqueueAction(cmp.get('c.submit'));
	},
	moveNext4: function(cmp, event, helper) {
		var setChannel = cmp.get('v.selectedBookingChannel');
		cmp.set('v.wrapperList.Quote.BookingChannel__c', setChannel);

		var setBooking = cmp.get('v.selectedBookingType');
		cmp.set('v.wrapperList.Quote.BookingType__c', setBooking);

		var setSales = cmp.get('v.selectedSalesOffice');
		cmp.set('v.wrapperList.opp.SalesOffice__c', setSales);

		var setCurrency = cmp.get('v.selectedCurrency');
		cmp.set('v.wrapperList.Quote.CurrencyIsoCode', setCurrency);

		//helper.insertRecord(cmp, event);
        cmp.set('v.isFinishBooking', true);

		var path_4_Fields = cmp.find('path_4_Fields').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
		}, true);

		if (path_4_Fields) {
			var whichOne = event.getSource().getLocalId();
			console.log(whichOne);
			if (whichOne == 'next4') {
				helper.insertRecord(cmp, event);
				cmp.set('v.isFinishBooking', true);
			}
		} else {
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				title: 'Error!',
				type: 'error',
				message: 'Please fill your information correctly.',
			});
			toastEvent.fire();
		}
		//		$A.enqueueAction(cmp.get('c.submit'));
	},
	movePrev: function(cmp, event, helper) {
		var whichOne = event.getSource().getLocalId();
		console.log(whichOne);
		if (whichOne == 'prev2') {
			var currentHeader = cmp.find('header-3');
			var prevHeader = cmp.find('header-1');
			var CurrentPanel = cmp.find('path-content-3');
			var prevPanel = cmp.find('path-content-1');
			var finishBooking = cmp.find('finishBooking');
			//For Prev Header
			$A.util.addClass(prevHeader, 'slds-is-current slds-is-active');
			$A.util.removeClass(prevHeader, 'slds-is-complete');
			//For Current header
			$A.util.addClass(currentHeader, 'slds-is-incomplete');
			$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
			//   //PanelCurrent
			$A.util.addClass(CurrentPanel, 'slds-hide');
			$A.util.removeClass(CurrentPanel, 'slds-show');
			//PanelCurrent
			$A.util.addClass(prevPanel, 'slds-show');
			$A.util.removeClass(prevPanel, 'slds-hide');
			//Disable Button
			$A.util.removeClass(finishBooking, 'slds-button_brand');
		} else if (whichOne == 'prev3') {
			var currentHeader = cmp.find('header-3');
			var prevHeader = cmp.find('header-1');
			var CurrentPanel = cmp.find('path-content-3');
			var prevPanel = cmp.find('path-content-1');
			var finishBooking = cmp.find('finishBooking');
			//For Prev Header
			$A.util.addClass(prevHeader, 'slds-is-current slds-is-active');
			$A.util.removeClass(prevHeader, 'slds-is-complete');
			//For Current header
			$A.util.addClass(currentHeader, 'slds-is-incomplete');
			$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
			//   //PanelCurrent
			$A.util.addClass(CurrentPanel, 'slds-hide');
			$A.util.removeClass(CurrentPanel, 'slds-show');
			//PanelCurrent
			$A.util.addClass(prevPanel, 'slds-show');
			$A.util.removeClass(prevPanel, 'slds-hide');
			//Disable Button
			$A.util.removeClass(finishBooking, 'slds-button_brand');
		} else if (whichOne == 'prev4') {
			var currentHeader = cmp.find('header-4');
			var prevHeader = cmp.find('header-3');
			var CurrentPanel = cmp.find('path-content-4');
			var prevPanel = cmp.find('path-content-3');
			var finishBooking = cmp.find('finishBooking');
			//For Prev Header
			$A.util.addClass(prevHeader, 'slds-is-current slds-is-active');
			$A.util.removeClass(prevHeader, 'slds-is-complete');
			//For Current header
			$A.util.addClass(currentHeader, 'slds-is-incomplete');
			$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
			//   //PanelCurrent
			$A.util.addClass(CurrentPanel, 'slds-hide');
			$A.util.removeClass(CurrentPanel, 'slds-show');
			//PanelCurrent
			$A.util.addClass(prevPanel, 'slds-show');
			$A.util.removeClass(prevPanel, 'slds-hide');
			//Enable Button
			$A.util.removeClass(finishBooking, 'slds-button_brand');
		} else if (whichOne == 'prev5') {
			var currentHeader = cmp.find('header-5');
			var prevHeader = cmp.find('header-4');
			var CurrentPanel = cmp.find('path-content-5');
			var prevPanel = cmp.find('path-content-4');
			var finishBooking = cmp.find('finishBooking');
			//For Prev Header
			$A.util.addClass(prevHeader, 'slds-is-current slds-is-active');
			$A.util.removeClass(prevHeader, 'slds-is-complete');
			//For Current header
			$A.util.addClass(currentHeader, 'slds-is-incomplete');
			$A.util.removeClass(currentHeader, 'slds-is-current slds-is-active');
			//   //PanelCurrent
			$A.util.addClass(CurrentPanel, 'slds-hide');
			$A.util.removeClass(CurrentPanel, 'slds-show');
			//PanelCurrent
			$A.util.addClass(prevPanel, 'slds-show');
			$A.util.removeClass(prevPanel, 'slds-hide');
			//Enable Button
			$A.util.removeClass(finishBooking, 'slds-button_brand');
			$A.util.removeClass(finishBooking, 'slds-button_brand');
		}
	},
	preValidateSubmit: function(cmp, event, helper) {
		$A.util.removeClass(finishBooking, 'slds-button_brand');
		var finishBooking = cmp.find('finishBooking');
		var path_4_Fields = cmp.find('path_4_Fields').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
		}, true);
		if (path_4_Fields) {
			$A.util.addClass(finishBooking, 'slds-button_brand');
		} else {
			$A.util.removeClass(finishBooking, 'slds-button_brand');
		}
	},
	onClick: function(cmp, evt, helper) {
		var allValid = cmp.find('field').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && inputCmp.get('v.validity').valid;
		}, true);
		if (allValid) {
			alert('All form entries look valid. Ready to submit!');
		} else {
			alert('Please update the invalid form entries and try again.');
		}
	},

//    submit: function(cmp, event, helper) {
//    	    debugger;
//
//    		helper.insertRecord(cmp, event);
//    		cmp.set('v.isFinishBooking', false);
//    		// cmp.set('v.isFinishBooking',true);
//    		// alert(cmp.get("v.isFinishBooking"));
//    		//var toastEvent = $A.get("e.force:showToast");
//    		//toastEvent.setParams({
//    		//title: "Success!",
//    		//type: "success",
//    		//message: "The record has been updated successfully."
//    		//});
//    		//toastEvent.fire();
//    	},
//
//    	finishBooking: function(cmp, event, helper) {
//    		helper.insertRecord(cmp, event);
//    		cmp.set('v.isFinishBooking', true);
//    		// alert(cmp.get("v.isFinishBooking"));
//    		//var toastEvent = $A.get("e.force:showToast");
//    		//toastEvent.setParams({
//    		//title: "Success!",
//    		//type: "success",
//    		//message: "The record has been updated successfully."
//    		//});
//    		//toastEvent.fire();
//    	},

	onClickTest: function(component, event, helper) {
		var inputCmp = component.find('path_1_Fields');
		console.log(event.getSource().get('v.name'));

		// if (isNaN(event.getSource().get("v.name"))) {
		// 	inputCmp.set("v.errors", [{ message: "Input not a number: " + value }]);
		//   } else {
		// 	inputCmp.set("v.errors", null);
		//   }
	},
	valueChangeValidation: function(component, event, helper) {
		var inputField = component.find('inputField');
		var value = component.get('v.value');
		if (value != 'foo') {
			inputField.set('v.validity', { valid: false, badInput: true });
		}
	},
});

/* 
  slds-is-current slds-is-active
  slds-is-complete
  
  <aura:attribute name="whichButton" type="String" />
	  <p>You clicked: {!v.whichButton}</p>
  // Salesforce 
  cmp.set("v.whichButton", whichOne);
  onchange="{!c.onClickTest }"
  */