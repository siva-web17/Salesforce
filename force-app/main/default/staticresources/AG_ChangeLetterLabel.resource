/**
 * @author Arkadiusz Celej
 * @version 1.00
 * @description Action to mass update Program
 *
 * @id AG_ChangeLetterLabel   ActionGrid custom action id that is added to the name field.
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
            {Name: "Opportunity", Plural: "Opportunities"}
        ];
        for (var i = 0; i < objects.length; i++) {
            if (objects[i].Name === object) {
                CurrentObject.object = objects[i];
                return true;
            }
        }
        ;
        return false;
    };

    crmc.addCustomAction({
        "itemID": "AG_ChangeLetterLabel",
        "isAvailable": function (context) {
            return false;
        },
        "isToolbarAvailable": function (context) {
            // This function determines if this item can be displayed in the Toolbar as a button
            IsContext(context.objectDescribe.name);
            return this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;
        },
        "getLabel": function (context) {
            return "Change Letter/Label";
        },
        "createSubmenuItems": function (context) {
            return [];
        },
        "click": function (context) {
            /** Language strings.*/
            var POPUP_HEADER = 'Send Material';

            if (context.selectedRows.length === 0) {
                kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select at least one record to change Letter/Label', []);
                return;
            }

            function Process(letter, label, clearLabels) {
                //Loop through each result and pull the data.
                var records = [];
                if (letter || label) {
                    for (var i = 0; i < context.selectedRows.length; i++) {
                        var record = new sforce.SObject('Opportunity');
                        record.Id = context.selectedRows[i].id;
                        if (letter) {
                            record.Letter__c = letter;
                        }
                        if (label) {
                            record.Label__c = label;
                        }
                        if(clearLabels){
                            record.Label__c = null;
                        }
                        records.push(record);
                    }
                }else if(clearLabels){
                    for (var i = 0; i < context.selectedRows.length; i++) {
                        var record = new sforce.SObject('Opportunity');
                        record.Id = context.selectedRows[i].id;
                        record.Label__c = null;
                        records.push(record);
                    }
                } else {
                    kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select Letter or Label', []);
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

            function getCongaTemplates(type) {
                if (context.selectedRows.length < 1) {
                    return [];
                }
                var firstOpportunityId = context.selectedRows[0].id;
                var opps = sfdc.query("SELECT Id, Market__c FROM Opportunity WHERE Id = \'" + firstOpportunityId + "\'");
                if (opps.length > 0) {
                    market = opps[0].Market__c;
                } else {
                    return [];
                }
                var results = sfdc.query("SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE IsDeleted = FALSE AND Market__c = \'" + market + "\' AND APXTConga4__Template_Type__c = \'" + type + "\' Order BY APXTConga4__Name__c");
                return results;
            }

            function getLetters() {
                var letters = getCongaTemplates('Letter');
                return convertToPicklist(letters);
            }

            function getLabels() {
                var labels = getCongaTemplates('Label');
                return convertToPicklist(labels);
            }

            function convertToPicklist(lst) {
                var picklist = [];
                for (var i = 0; i < lst.length; i++) {
                    var item = {
                        value: lst[i].Id,
                        label: lst[i].APXTConga4__Name__c
                    }
                    picklist.push(item);
                }
                return picklist;
            }

            kendoEntry.entry(POPUP_HEADER,
                [
                    {name: "Letter__c", label: 'Letter', type: "picklist", values: getLetters()},
                    {name: "Label__c", label: 'Label', type: "picklist", values: getLabels()},
                    {name: "ClearLabels", label: 'Clear Label', type: "boolean"}
                ],
                {width: 350},
                null,
                function (selectedValues) {
                    var letter = selectedValues["Letter__c"].value;
                    var label = selectedValues["Label__c"].value;
                    var clearLabels = selectedValues["ClearLabels"].value;
                    Process(letter, label, clearLabels);
                });
        }
    });
});
