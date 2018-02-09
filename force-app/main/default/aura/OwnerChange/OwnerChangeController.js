({

     doInit:function(component, event, helper){
         debugger;
           // var recordId = component.get(v.recordId) ;
           var action=component.get("c.GetRecordOwnerDetails");
             action.setParams({
                    	'Id' : component.get("v.recordId")
                	});
           action.setCallback(this, function(response) {
                      var state = response.getState();

                      if (component.isValid() && state === "SUCCESS") {
                          debugger;

                          var ownerRecord = JSON.parse(response.getReturnValue());
                          component.set("v.ParentRecord",ownerRecord);
                          component.set('v.ownerName',ownerRecord.Owner.Name);
                         // message='Owner Changed to'+
                          component.set("v.ownerURL", "#/sObject/" + ownerRecord.OwnerId + "/view");


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
                  },

//                  NavigateToOwnerInfo:function(component,helper,event)
//                  {
//
//                      var LeadObject=component.get("v.ParentRecord");
//                      console.log('reached');
//                      debugger;
//                       var navEvt = $A.get("e.force:navigateToSObject");
//                          navEvt.setParams({
//                            "recordId": LeadObject.OwnerId
//                          });
//                          component.set("v.ownerURL", "#/sObject/" + LeadObject.OwnerId + "/view");
//                          navEvt.fire();
//                          event.preventDefault();
//                  },
                  MouseOverForOwnerName:function(component,helper,event)
                  {
                      var container=component.find("Tooltip");
                      $A.util.toggleClass(container, "slds-hide");
                  },

                  MouseOutForOwnerName:function(component,helper,event)
                    {
                       var container=component.find("Tooltip");
                       $A.util.toggleClass(container, "slds-hide");
                    },


                  OpenChangeOwnerlookUpComponent:function(component,helper,event)
                  {

                      var container=component.find("ModalPopUp");
                      $A.util.toggleClass(container, "slds-hide");
                  },


                  OnOwnerChanged:function(component,event,helper){
                      debugger;

                      var ownerRec=event.getParam('value');
                      component.set('v.OwnerRecord',ownerRec);
                     component.set('v.ownerName',ownerRec.Name);
                     component.set("v.ownerURL", "#/sObject/" + ownerRec.Id + "/view");
                       var action=component.get("c.ChangeOwner");
                                  action.setParams({
                                         	'UserId' : ownerRec.Id ,
                                         	'RecordId':component.get("v.recordId"),
                                         	'ObjectName': component.get("v.ParentObjectApi")
                                     	});
                                action.setCallback(this, function(response) {
                                           var state = response.getState();
                                           var mode='pester';
                                           var message='';
                                           var duration=3000;
                                           if (component.isValid() && state === "SUCCESS") {
                                               message= component.get("v.ParentObjectApi")+'Owner Changed to '+ownerRec.Name;

                                           }
                                           else if (state === "ERROR") {
                                               var errors = response.getError();
                                               if (errors) {
                                                   if (errors[0] && errors[0].message) {
                                                       message=errors[0].message;
                                                       console.log("Error message: " +
                                                                   errors[0].message);
                                                   }
                                               } else {
                                                   message='Unknown error';
                                                   console.log("Unknown error");
                                               }
                                           }

                                            helper.ShowStatus(state,mode,message,duration)
                                       });
                                       $A.enqueueAction(action);

                      //call apex here
                  }
})