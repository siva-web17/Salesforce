/**
 * Created by aneesh.bhat on 09-Jun-17.
 */
({
    doInit:function(component,event,helper){
        var templatesAction = component.get("c.getTemplates");
        templatesAction.setCallback(this, function(response){
                    switch(response.getState()){
                        case 'SUCCESS':
                            var templates = JSON.parse(response.getReturnValue());
                            debugger;
                            component.set("v.files",templates);
                            var message = component.find("warningMessage");
                            var fileThumbnails = component.find("fileThumbnails");
                            if(templates == null || templates.length==0){
                                $A.util.removeClass(message,'slds-hide');
                                $A.util.addClass(message,'slds-show');
                            }
                            else{
                                $A.util.removeClass(message,'slds-show');
                                $A.util.addClass(message,'slds-hide');
                            }
                            break;
                        case 'INCOMPLETE':
                            break;
                        case 'ERROR':
                            break;
                    }
                });
          $A.enqueueAction(templatesAction);
    },
    sendMessage: function(component, event, helper) {
          helper.toggle(component);

          //Prepare message in the format required in VF page
          var message = {
              "uploadFile" : true
          } ;
          //Send message to VF
          helper.sendMessage(component, helper, message);
      }
})