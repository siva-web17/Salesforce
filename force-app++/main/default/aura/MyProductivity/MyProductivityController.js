({
    doInit : function(component, event, helper){
        helper.getData(component, event);
    },

    preventClickEvent:function(component, event, helper){
        event.stopPropagation();
    }
})