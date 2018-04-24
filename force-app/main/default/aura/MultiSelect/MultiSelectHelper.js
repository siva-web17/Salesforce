({
    setInitialData:function(component){
          var options = component.get('v.options');
          var options_Internal = [];
          if(options === null || typeof options === undefined){
              return;
          }

        var selectedItems = component.get('v.selectedItems');
        for(var key in options){
            options_Internal.push({'label':options[key],'value':key,'isSelected':(selectedItems != null && selectedItems.indexOf(key) > -1)});
          }

          component.set('v.options_internal',options_Internal);
    },
  getSelectedValues: function(component){
    var options = component.get("v.options_internal");
    var values = [];
     if(options === null || typeof options === undefined){
                  return;
              }
    options.forEach(function(element) {
      if (element.isSelected) {
        values.push(element.value);
      }
    });
    return values;
  },
//
//  getSelectedLabels: function(component){
//    var options = component.get("v.options_");
//    var labels = [];
//    options.forEach(function(element) {
//      if (element.selected) {
//        labels.push(element.label);
//      }
//    });
//    return labels;
//  },
//
//  despatchSelectChangeEvent: function(component,values){
//    var compEvent = component.getEvent("selectChange");
//    compEvent.setParams({ "values": values });
//    compEvent.fire();
//  }
})