({
	accountData : function(cmp,event,helper) {
       
    },
    
    /*fetchPicklistValues: function(component, controllerField, dependentField) {
      // call the server side function  
      var action = component.get("c.getDependentOptionsImpl");
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
 
      action.setParams({
         'objApiName': component.get("v.objInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      action.setCallback(this, function(response) {
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.depnedentFieldMap", StoreResponse);
 
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
            }
 
            //set the controller field value for ui:inputSelect  
            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
            }
 
            for (var i = 0; i < listOfkeys.length; i++) {
               ControllerField.push({
                  class: "optionClass",
                  label: listOfkeys[i],
                  value: listOfkeys[i]
               });
            }
            // set the ControllerField variable values to country(controller picklist field)
            component.find('mailCountry').set("v.options", ControllerField);
         }
      });
      $A.enqueueAction(action);
   },*/

    insertRecord : function(cmp,event) {
        debugger; 
        var quoteid = cmp.get("v.QuoteId");
        console.log('quoteid========> ' +quoteid);
        //alert('enter');
        var action = cmp.get("c.createRecord");
        //var fname = cmp.find("path_1_Field").get("v.value");
        //console.log('fname=======>' +fname);
        //cmp.set("v.wrapperList.personAcc.FirstName",fname);
        var fwrapperLst = cmp.get("v.wrapperList");
        //alert('Alert in insert method');
        action.setParams({
            "wrapperData": JSON.stringify(fwrapperLst),
            "isFinishBooking":cmp.get("v.isFinishBooking")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // alert("From server: " + response.getReturnValue());
                if(response.getReturnValue()===true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        type: "success",
                        message: "The record has been updated successfully."
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Failure!",
                        type: "Failure",
                        message: "Unable to save."
                    });
                    toastEvent.fire();
                }
                
                
                
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }  
})