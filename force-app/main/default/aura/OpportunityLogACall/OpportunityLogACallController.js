/**
 * Created by aneesh.bhat on 04-Sep-17.
 */
({
	doInit: function(component, event, helper) {
		var currentYear = new Date().getFullYear();
		component.set('v.DateTimeTemp', moment(new Date(), 'DD-MM-YYYY').add(1, 'days').format('YYYY-MM-DD') + 'T00:00');
		var years = [];
		years.push(currentYear.toString());
		for (var year = 0; year < 2; year++) {
			years.push((++currentYear).toString());
		}
		//	  component.set('v.selectedActionDate', new Date().toISOString());
		component.set('v.years', years);
		var salesAction = component.get('c.getSalesActions');
		salesAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var salesActions = JSON.parse(res.getReturnValue());
					if (salesActions.length > 0) {
						// component.set('v.selectedActionType', salesActions[0]);
					}
					component.set('v.salesAction', salesActions);
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(salesAction);
		helper.getFirstContactStatus(component);
		component.set('v.find_lead_or_opp', component.get('v.recordId').slice(0, 3));
		var likelihoodToBookAction = component.get('c.getLikelihoodToBookOptions');
		likelihoodToBookAction.setParams({
			recordId: component.get('v.recordId'),
		});
		likelihoodToBookAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var likelihoodToBookOptions = JSON.parse(res.getReturnValue());
					component.set('v.likelihoodToBook', likelihoodToBookOptions);
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(likelihoodToBookAction);

		var hearAboutEFAction = component.get('c.getHearAboutUsOptions');
		hearAboutEFAction.setParams({
			recordId: component.get('v.recordId'),
		});
		hearAboutEFAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var hearAboutEFOptions = JSON.parse(res.getReturnValue());
					component.set('v.hearAboutEF', hearAboutEFOptions);
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(hearAboutEFAction);

		var destinationsAction = component.get('c.getDestinations');
		destinationsAction.setParams({
			recordId: component.get('v.recordId'),
		});
		destinationsAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					component.set('v.destinations', res.getReturnValue());
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(destinationsAction);

		var durationAction = component.get('c.getDurations');
		durationAction.setParams({
			recordId: component.get('v.recordId'),
		});
		durationAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					component.set('v.durations', res.getReturnValue());
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(durationAction);

		var closeReasonsAction = component.get('c.getCloseReasons');
		closeReasonsAction.setParams({
			recordId: component.get('v.recordId'),
		});
		closeReasonsAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var closeReasons = JSON.parse(res.getReturnValue());
					component.set('v.closeReasons', closeReasons);
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(closeReasonsAction);

		var subActionsAction = component.get('c.getSubActions');
		subActionsAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var subActions = JSON.parse(res.getReturnValue());
					component.set('v.subActions', subActions);
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(subActionsAction);

		var bookOnDateAction = component.get('c.getInitialData');
		bookOnDateAction.setParams({
			recordId: component.get('v.recordId'),
		});
		bookOnDateAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var data = JSON.parse(res.getReturnValue());
					component.set('v.selectedLikelihoodToBook', data.LikelihoodToBook);
					component.set('v.hearAboutEFValue', data.HearAboutUs);
					component.set('v.destinationsSelected', data.Destinations);
					component.set('v.durationsSelected', data.Duration);
					component.set('v.yearSelected', data.WhenYear);
					component.set('v.monthSelected', data.WhenMonth);
					component.set('v.bookOnDate', data.CloseDate);
					component.set('v.isActiveUser', data.IsActive);
					component.set('v.DateTimeTemp', moment(new Date(), 'DD-MM-YYYY').add(1, 'days').format('YYYY-MM-DD') + 'T00:00');
					component.set('v.selectedActionDate', component.get('v.DateTimeTemp'));
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(bookOnDateAction);
        debugger;
		var getProgramsAction = component.get('c.getProgramsForChange');
		getProgramsAction.setParams({
			recordId: component.get('v.recordId'),
		});
		getProgramsAction.setCallback(this, function(res) {
            debugger;
			switch (res.getState()) {
				case 'SUCCESS':
					component.set('v.programs', res.getReturnValue());
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(getProgramsAction);
	},
	onSalesActionChanged: function(component, event, helper) {
		component.set('v.selectedSubActionType', '');
		component.set('v.saveText', 'Save Action');
		if (component.get('v.selectedActionType') === 'Call Reached' && component.get('v.recordId').startsWith('00Q')) {
			component.set('v.saveText', 'Save and Create Opportunity');
		}
		var callResultAction = component.get('c.getCallResults');
		callResultAction.setParams({
			callAction: component.get('v.selectedActionType'),
		});
		callResultAction.setCallback(this, function(res) {
			switch (res.getState()) {
				case 'SUCCESS':
					var callResults = JSON.parse(res.getReturnValue());
					component.set('v.callResults', callResults);
					component.set('v.selectedCallResult', 'Select');
					break;
				case 'INCOMPLETE':
					break;
				case 'ERROR':
					break;
			}
		});
		$A.enqueueAction(callResultAction);
	},
	onSaveClicked: function(component, event, helper) {
		var loaderComp = component.find('loaderComp');
		$A.util.addClass(loaderComp, 'customLoaderTrue');
		var comments = component.find('comments').get('v.value');
		var required = component.find('required').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch && !inputCmp.get('v.validity').typeMismatch;
		}, true);

		if (!required) {
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				title: 'Error!',
				type: 'error',
				message: 'Please fill your information correctly.',
			});
			toastEvent.fire();
			$A.util.removeClass(loaderComp, 'customLoaderTrue');
		} else {
			if (!helper.validateFields(component)) {
				var saveDataAction = component.get('c.saveData');
				var bookOnDateValue = component.get('v.bookOnDate');
				var validateBookOnDate = bookOnDateValue == '' || bookOnDateValue == null ? true : moment(bookOnDateValue).isValid() ? true : false;
				// var validateActionDateTimeDate = moment(component.get('v.selectedActionDate')).isValid();
				if (validateBookOnDate) {
					saveDataAction.setParams({
						callAction: component.get('v.selectedActionType') === 'Select' ? '' : component.get('v.selectedActionType'),
						subAction: component.get('v.selectedSubActionType') === 'Select' ? '' : component.get('v.selectedSubActionType'),
						callResult: component.get('v.selectedCallResult') === 'Select' ? '' : component.get('v.selectedCallResult'),
						actionDateTime: component.get('v.selectedActionDate') === 'Select' ? '' : new Date(component.get('v.selectedActionDate')).toISOString(),
						closeReason: component.get('v.selectedCloseReason') === 'Select' ? '' : component.get('v.selectedCloseReason'),
						recordId: component.get('v.recordId'),
						comments: comments,
						program: component.get('v.changedProgram') === 'Select' ? '' : component.get('v.changedProgram'),
						visitDatetime: component.get('v.selectedVisitDate') === 'Select' ? '' : new Date(component.get('v.selectedVisitDate')).toISOString(),
						likelihoodToBook: component.get('v.selectedLikelihoodToBook'),
						hearAboutUs: component.get('v.hearAboutEFValue'),
						destination: component.get('v.destinationsSelected'),
						duration: component.get('v.durationsSelected'),
						whenYear: component.get('v.yearSelected'),
						whenMonth: component.get('v.monthSelected'),
						bookOn: bookOnDateValue == '' || bookOnDateValue == null ? null : new Date(bookOnDateValue).toISOString(),
					});
					// new moment ().format("YYYY-MM-DD")
					saveDataAction.setCallback(this, function(res) {
						var responseValue = JSON.parse(res.getReturnValue()).ResponseCode;
						var innerBody = {
							value: JSON.parse(res.getReturnValue()).ErrorMessage,
						};
						switch (responseValue) { //res.getState()
							case 'SUCCESS':
								var response = JSON.parse(res.getReturnValue());
								if (typeof response.Result !== 'undefined' && response.Result !== null) {
									var navEvt = $A.get('e.force:navigateToSObject');
									navEvt.setParams({
										recordId: response.Result.Id,
										slideDevName: 'related',
									});
									navEvt.fire();
									$A.util.removeClass(loaderComp, 'customLoaderTrue');
								} else {
									var toastEvent = $A.get('e.force:showToast');
									toastEvent.setParams({
										title: 'Success!',
										type: 'success',
										message: 'Data saved successfully',
									});
									toastEvent.fire();
									component.set('v.readOnlyToggle', false);
									component.set('v.isCustomerReached', true);
									//$A.util.removeClass(loaderComp, 'customLoaderTrue');
								}
								document.location.reload(true);
								break;
							case 'INCOMPLETE':
								$A.util.removeClass(loaderComp, 'customLoaderTrue');
								//document.location.reload(true)
								break;
							case 'ERROR':
								$A.util.removeClass(loaderComp, 'customLoaderTrue');
								break;
							case 'FAILURE':
								var modalBody;
								$A.createComponent('ui:outputText', innerBody, function(content, status) {
									if (status === 'SUCCESS') {
										modalBody = content;
										component.find('overlayLib').showCustomModal({
											header: 'ERROR',
											body: modalBody,
											showCloseButton: true,
											cssClass: 'mymodal',
										});
									}
								});
								$A.util.removeClass(loaderComp, 'customLoaderTrue');
								break;
						}
					});
					$A.enqueueAction(saveDataAction);
				} else {
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Error!',
						type: 'error',
						message: 'Please fill your information correctly.',
					});
					toastEvent.fire();
					$A.util.removeClass(loaderComp, 'customLoaderTrue');
				}
			}
		}
	},
	onEdit: function(component, event, helper) {
		component.set('v.readOnlyToggle', true);
	},
	validateDatePast: function(component, event, helper) {
		var dtToday = new Date();
		var month = dtToday.getMonth() + 1;
		var day = dtToday.getDate();
		var year = dtToday.getFullYear();
		if (month < 10) month = '0' + month.toString();
		if (day < 10) day = '0' + day.toString();
		var maxDate = year + '-' + month + '-' + day;
		// alert(maxDate);
		//$('.pastdatesdisable').attr('min', maxDate);
	},
	preValidateWillBookOn: function(cmp, event, helper) {
		var preValidateWillBookOn = cmp.find('requiredBookOnDate').reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && !inputCmp.get('v.validity').badInput;
		}, true);
		if (preValidateWillBookOn) {
			cmp.set('v.temporaryDataWillBookOn', true);
			if (cmp.get('v.bookOnDate') != null) {
				if (!moment(cmp.get('v.bookOnDate')).isAfter(new Date()) && !moment(cmp.get('v.bookOnDate')).isSame(moment().format('YYYY-MM-DD'))) {
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Error!',
						type: 'error',
						message: 'Past date cannot be selected',
					});
					toastEvent.fire();
					cmp.set('v.bookOnDate', moment(new Date()).add(6, 'M').format('YYYY-MM-DD'));
				}
			}
		} else {
			cmp.set('v.temporaryDataWillBookOn', false);
		}
	},
	openModel: function(component, event, helper) {
		component.set('v.isOpen', true);
	},
	closeModel: function(component, event, helper) {
		component.set('v.isOpen', false);
	},
	handleShowModal: function(component, evt, helper) {
		var modalBody;
		var innerBody = {
			value: 'Error text',
		};
		$A.createComponent('ui:outputText', innerBody, function(content, status) {
			if (status === 'SUCCESS') {
				modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: 'ERROR',
					body: modalBody,
					showCloseButton: true,
					cssClass: 'mymodal',
				});
			}
		});
	},
	pastDateValidation: function(cmp, evt, helper) {
		if (cmp.get('v.selectedActionDate') != null) {
			if ( (!moment(cmp.get('v.selectedActionDate')).isAfter(new Date())) && (!moment(cmp.get('v.selectedActionDate')).isSame(moment().format('YYYY-MM-DD'))) ) {
				var toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					title: 'Error!',
					type: 'error',
					message: 'Past date cannot be selected',
				});
				toastEvent.fire();
				cmp.set('v.selectedActionDate', moment(new Date(), 'DD-MM-YYYY').add(1, 'days').format('YYYY-MM-DD') + 'T00:00');
			}
		}
	},
});