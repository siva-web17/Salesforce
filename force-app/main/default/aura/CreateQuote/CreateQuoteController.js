({
	CallPoseidonPQ : function(component, event, helper) {
         var action = component.get("c.openPoseidonToCreateQuote");
         action.setParams({
                    "recordId": component.get("v.recordId")
                });
         action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        debugger;
                       /* var xhr = new XMLHttpRequest();
                         var url = 'http://localhost.1234/PriceQuote/Create';
                        xhr.open("POST", url, true);
                        xhr.setRequestHeader("Content-type", "application/json");
                        xhr.onreadystatechange = function () {
                            if (xhr.readyState === 4 && xhr.status === 200) {
                                var json = JSON.parse(xhr.responseText);
                                console.log(json);
                            }
                        };
                         var data = JSON.stringify(response.getReturnValue());
                        xhr.send(data);*/
                          var xhr = new XMLHttpRequest();
                                                           var url = 'http://localhost.1234/PriceQuote/Create';
                                                         xhr.open("POST", url, true);

                                                          xhr.setRequestHeader("Content-type", "application/json");

                                                            var data = JSON.stringify({
                          "lastname": "Norway",
                          "firstname": "QuoteAccount",
                          "ParentEmail__c": null,
                          "Program__c": "ILS",
                          "Id": "0066E0000047tYUQAY",
                          "Gender__c": "Male",
                          "Email2__c": null,
                          "Email__c": "arjun@ef.com",
                          "Language__c": "NO",
                          "SalesOffice__c": "NOO",
                          "Market__c": "NOO"
                        });
                                                           xhr.send(data);
                        /*if(response.getReturnValue()===''){

                            $A.get("e.force:closeQuickAction").fire();

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Success!",
                                type: "success",
                                message: "Please Create Quote in Poseidon."
                            });
                            toastEvent.fire();
                        }
                        else if (response.getReturnValue().includes(",")){
                            var cmpTarget = component.find('error');
                                    $A.util.addClass(cmpTarget, 'changeMe');
                            component.set("v.ErrorMessage"
                            ,"<span ><strong>"
                            +$A.get("$Label.c.MandatoryFields")+
                            "</strong> </br> </br> "+response.getReturnValue()+"</span>");
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Failure!",
                                type: "error",
                                message: $A.get("$Label.c.MandatoryFields"),
                                duration:10000
                            });
                            toastEvent.fire();
                        }
                        else{
                             $A.get("e.force:closeQuickAction").fire();
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                             title: "Failure!",
                             type: "error",
                             message: response.getReturnValue(),
                             duration:5000
                             });
                             toastEvent.fire();
                        }*/
                    }
                    else if (state === "INCOMPLETE") {
                    }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                      title: "Failure!",
                                      type: "Failure",
                                      message: errors[0].message
                                      });
                                      toastEvent.fire();
                                }
                            } else {
                               var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                     title: "Failure!",
                                     type: "Failure",
                                     message: errors[0].message
                                     });
                                     toastEvent.fire();
                            }
                        }
                });
                $A.enqueueAction(action);
	}
})