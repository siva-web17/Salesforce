({
    ModalPopUpEvent:function(component,event,helper)
    {

      var compEvent = component.getEvent("LookUpEvent");

      compEvent.setParams({"SelectedLookUpValue" : component.get("v.selectedLookUpRecord") });
      compEvent.fire();
    },
    OnOwnerChangeClicked:function(component,event,helper)
    {
        component.set('v.selectedLookUpRecord',component.get('v.localSelectedLookUpRecord'));
        var compEvent1 = component.getEvent("LookUpEvent");
         compEvent1.setParams({"SelectedLookUpValue" : component.get("v.selectedLookUpRecord") });
         compEvent1.fire();
    }
})