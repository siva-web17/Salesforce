/**
 * @author Arkadiusz Celej
 * @version 1.00
 * @description Action to change owner of selected records and its open activities
 *
 * @id AG_ChangeOpportunityLeadOwner   ActionGrid custom action id that is added to the name field.
 * @param kendoEntry              ActionGrid helper for Kendo UI modal entry forms.
 * @param kendoPopup              ActionGrid helper for Kendo UI model message windows.
 * @param sfdc                    ActionGrid helper for Salesforce REST API's
 */
crmc.require(["KendoEntry", "KendoPopup", "sfdc"], function (kendoEntry, kendoPopup, sfdc) {

    var CurrentObject = {
        object: {Name: "Opportunity", Plural: "Opportunities"}
    };

    var IsContext = function (object) {
        objects = [
            {Name: "Opportunity", Plural: "Opportunities"},
            {Name: "Lead", Plural: "Leads"}
        ];
        for (var i = 0; i < objects.length; i++) {
            if (objects[i].Name === object) {
                CurrentObject.object = objects[i];
                return true;
            }
        }
        return false;
    };

    crmc.addCustomAction({
        "itemID": "AG_ChangeOpportunityLeadOwner",
        "isAvailable": function (context) {
            return false;
        },
        "isToolbarAvailable": function(context) {
            // This function determines if this item can be displayed in the Toolbar as a button
            IsContext(context.objectDescribe.name);
            return this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;

        },
        "getLabel": function (context) {
            return "Assign";
        },
        "createSubmenuItems": function (context) {
            return [];
        },
        "click": function (context) {

            /** Language strings.*/
            var POPUP_HEADER = 'Assign';

            if(context.selectedRows.length === 0){
                kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select at least one record to Assign', []);
                return;
            }

            function process(newOwner) {
                var recordsToUpdate = [];
                if (newOwner) {
                    for (var i = 0; i < context.selectedRows.length; i++) {
                        var record = new sforce.SObject(CurrentObject.object.Name);
                        record.Id = context.selectedRows[i].id;
                        record.OwnerId = newOwner;
                        record.SCT_Owner__c = newOwner;
                        recordsToUpdate.push(record);
                    }
                } else {
                    kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select new Owner', []);
                    return;
                }
                var onfailure = function (error) {
                    kendoPopup.popupWithButtons(POPUP_HEADER, (error.message || error.faultstring), []);
                };

                sforce.connection.update(recordsToUpdate, {
                    onSuccess: function (results) {

                        // Get the new record Ids
                        var recordIds = [];
                        $.each(results, function (i, row) {
                            if (row.errors) {
                                onfailure(row.errors);
                                return;
                            }
                            recordIds.push(row.id);
                        });
                        if (results.length != recordIds.length) {
                            kendoPopup.popupWithButtons(POPUP_HEADER, 'Some of records could not be assigned.', []);
                        }
                        context.actionGrid.refresh();
                    },
                    onFailure: onfailure
                });
            }

            function getUsers() {
                var values = [];
                var markets = [];
                for(var i = 0 ; i < context.selectedRows.length; i++){
                    markets.push(context.selectedRows[i].Market__c);
                }
                var users = sfdc.query("SELECT Id, Name,EnabledForMarkets__c FROM User WHERE EnabledForMarkets__c INCLUDES ('" + markets.sort().join(';') + "\') ORDER BY Name");

                for (var i = 0; i < users.length; i++) {
                    values.push({
                        value: users[i].Id,
                        label: users[i].Name
                    });
                }
                return values;
            }

            kendoEntry.entry(POPUP_HEADER,
                [
                    {name: "user", label: 'User', type: "picklist", values: getUsers(), required: true}
                ],
                {width: 350},
                null,
                function (selectedValues) {
                    var user = selectedValues["user"].value;
                    process(user);
                });
        }
    });
});
