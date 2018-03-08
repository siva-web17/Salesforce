/**
 * Created by aneesh.bhat on 28-Jul-17.
 */
({
    onClick:function(component,event,helper){
        helper.toggle(component);
    },

    handleIconState: function(component){
        var buttonState = component.get('v.buttonState');
        component.set('v.buttonState',!buttonState);
    }
})