({
	accountData: function(cmp, event, helper) {},

	insertRecord: function(cmp, event) {
		var action = cmp.get('c.createRecord');
		var fwrapperLst = cmp.get('v.wrapperList');
		//alert(JSON.stringify(fwrapperLst));
		action.setParams({
			wrapperData: JSON.stringify(fwrapperLst),
			isFinishBooking: cmp.get('v.isFinishBooking'),
			QuoteId: cmp.get('v.QuoteId'),
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				// alert("From server: " + response.getReturnValue());
				if (response.getReturnValue() === true) {
					var toastEvent = $A.get('e.force:showToast');
                    var bookingSummarySuccess = $A.get('$Label.c.bookingSummarySuccess');
					toastEvent.setParams({
						title: 'Success!',
						type: 'success',
						message: bookingSummarySuccess,
					});
					toastEvent.fire();
					//Add navigation to detail view here
					//
					window.setTimeout(
						$A.getCallback(function() { 
							var navEvt = $A.get('e.force:navigateToSObject');
							navEvt.setParams({
								recordId: cmp.get('v.wrapperList.opp.Id'),
							});
							navEvt.fire();
						}),
						5000
					);
				} else {
					var toastEvent = $A.get('e.force:showToast');
                    var SaveFailed = $A.get('$Label.c.SaveFailed');
					toastEvent.setParams({
						title: 'Failure!',
						type: 'Failure',
						message: SaveFailed,
					});
					toastEvent.fire();
				}
			} else if (state === 'INCOMPLETE') {
			} else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log('Error message: ' + errors[0].message);
					}
				} else {
					console.log('Unknown error');
				}
			}
		});
		$A.enqueueAction(action);
	},
});