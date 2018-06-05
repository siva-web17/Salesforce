({
    ShowStatus:function(type,mode,message,duration)
    {
         var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
                                 mode: mode,
                                 type : type,
                                 message: message,
                                 duration:duration
                                 });
          toastEvent.fire();
    }
})