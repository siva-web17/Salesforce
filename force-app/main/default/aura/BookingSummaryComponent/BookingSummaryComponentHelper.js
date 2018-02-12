({
	accountData: function(cmp, event, helper) {},

	insertRecord: function(cmp, event) {
		var action = cmp.get('c.createRecord');
		//var fname = cmp.find("path_1_Field").get("v.value");
		//console.log('fname=======>' +fname);
		//cmp.set("v.wrapperList.personAcc.FirstName",fname);
		var fwrapperLst = cmp.get('v.wrapperList');
		//alert(JSON.stringify(fwrapperLst));
		action.setParams({
			wrapperData: JSON.stringify(fwrapperLst),
			isFinishBooking: cmp.get('v.isFinishBooking'),
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				// alert("From server: " + response.getReturnValue());
				if (response.getReturnValue() === true) {
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Success!',
						type: 'success',
						message: 'The record has been updated successfully.',
					});
					toastEvent.fire();
				} else {
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Failure!',
						type: 'Failure',
						message: 'Unable to save.',
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