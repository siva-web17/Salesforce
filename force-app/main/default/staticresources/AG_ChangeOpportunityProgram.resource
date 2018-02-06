/**
 * @author Arkadiusz Celej
 * @version 1.00
 * @description Action to mass update Program
 *
 * @id AG_ChangeProgram   ActionGrid custom action id that is added to the name field.
 * @param kendoEntry              ActionGrid helper for Kendo UI modal entry forms.
 * @param kendoPopup              ActionGrid helper for Kendo UI model message windows.
 * @param sfdc                    ActionGrid helper for Salesforce REST API's
 */
crmc.require(["KendoEntry", "KendoPopup", "sfdc"], function (kendoEntry, kendoPopup, sfdc) {

    var CurrentObject = {
        object: {Name: "Opportunity", Plural: "Opportunities"},
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
        "itemID": "AG_ChangeOpportunityProgram",
        "isAvailable": function (context) {
            var isCorrectContext = IsContext(context.objectDescribe.name);
            var multipleSelected = context.selectedRows && context.selectedRows.length > 0;
            var isEnabled = this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;
            return isCorrectContext && multipleSelected && isEnabled;
        },
        "getLabel": function (context) {
            return "Change Program";
        },
        "createSubmenuItems": function (context) {
            return [];
        },
        "click": function (context) {

            /** Language strings.*/
            var POPUP_HEADER = 'Action Screen';

            function getControllingFieldValue(objectDesctibe, controllingField, dependentField, dependentFieldValue) {
                var picklists = sfdc.getDependentPicklistValues(objectDesctibe, controllingField, dependentField);
                for (key in picklists) {
                    if (picklists.hasOwnProperty(key)) {
                        if (typeof picklists[key] != 'function' && picklists[key].indexOf(dependentFieldValue) > -1) {
                            return key;
                        }
                    }
                }
            }

            function Process(Program) {
                var controllingProduct = getControllingFieldValue(context.objectDescribe, 'Product__c', 'Program__c', Program);
                var ids = [];
                for (var i = 0; i < context.selectedRows.length; i++) {
                    ids.push(context.selectedRows[i].id);
                }

                //Query for the data that needs to be passed into new records.
                var results = sfdc.query("SELECT Id FROM " + CurrentObject.object.Name + " WHERE Id IN('" + ids.join("','") + "')");

                //Loop through each result and pull the data.
                var records = [];
                if (Program && controllingProduct) {
                    for (var i in results) {
                        var record = new sforce.SObject(CurrentObject.object.Name);
                        for (var j in ids) {
                            if (ids[j] === results[i].Id) {
                                record.Id = results[i].Id;
                                record.Product__c = controllingProduct;
                                record.Program__c = Program;
                                records.push(record);
                                break;
                            }
                        }
                    }
                } else {
                    kendoPopup.popupWithButtons(POPUP_HEADER, 'Program value must be provided', []);
                    return;
                }
                var onfailure = function (error) {
                    kendoPopup.popupWithButtons(POPUP_HEADER, error.message || error.faultstring, []);
                };

                sforce.connection.update(records, {
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
                        if (results.length == recordIds.length) {
                            context.actionGrid.refresh();
                        }
                    },
                    onFailure: onfailure
                });
            }

            function GetPicklist(table, field) {

                //Get the object describe.
                var fields = sfdc.getSObjectDescribe(table).fields;
                //Loop through table fields.
                for (var i = 0; i < fields.length; i++) {
                    //Find the picklist.
                    if (fields[i].name === field) {
                        //return the values.
                        return fields[i].picklistValues;
                    }
                }
            }

            kendoEntry.entry(POPUP_HEADER,
                [
                    {
                        name: "Program__c",
                        label: 'Program',
                        type: "picklist",
                        values: GetPicklist(CurrentObject.object.Name, 'Program__c'),
                        required: true
                    }
                ],
                {width: 350},
                null,
                function (selectedValues) {
                    var Program = selectedValues["Program__c"].value;
                    Process(Program);
                });
        }
    });
});
