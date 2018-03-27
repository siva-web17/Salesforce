/**
 * Created by aneesh.bhat on 28-Jul-17.
 */
({
    toggle: function (cmp) {
            var sectionHeader = cmp.find("sectionHeader");
            $A.util.toggleClass(sectionHeader, "slds-is-open");

            var content = cmp.find("content");
            $A.util.toggleClass(content, "slds-hide");
        }
})