/**
 * @author Arkadiusz Celej
 * @version 1.00
 * @description Action to Send brochures for SBR Tasks
 *
 * @id AG_DoNotSendBrochure       ActionGrid custom action id that is added to the name field.
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
        "itemID": "AG_SendBrochures",
        "isAvailable": function (context) {
            return false;
        },
        "isToolbarAvailable": function (context) {
            // This function determines if this item can be displayed in the Toolbar as a button
            IsContext(context.objectDescribe.name);
            return this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;
        },
        "getLabel": function (context) {
            return "Send Brochures";
        },
        "createSubmenuItems": function (context) {
            return [];
        },
        "click": function (context) {
            /** Language strings.*/
            var TASK_RESULT_WILL_NOT_SEND = 'Will not Send Brochure';
            var TASK_RESULT_SENT_BROCHURE = 'Sent Brochure';
            var POPUP_HEADER = 'Send Material';

            if (context.selectedRows.length === 0) {
                kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select at least one record to Send Brochures', []);
                return;
            }

            function templatesAreValid() {
                var templatesAssigned = true;
                var lettersAndLabelsToCheckAttachment = new Set();
                for (var i = 0; i < context.selectedRows.length; i++) {
                    if(context.selectedRows[i].Letter__c || context.selectedRows[i].Label__c){
                        lettersAndLabelsToCheckAttachment.add(context.selectedRows[i].Letter__c);
                        lettersAndLabelsToCheckAttachment.add(context.selectedRows[i].Label__c);
                        continue;
                    }else{
                        templatesAssigned = false;
                        break;
                    }
                }

                if(templatesAssigned){
                    lettersAndLabelsToCheckAttachment.delete(undefined);
                    var templates = sfdc.query("SELECT Id, APXTConga4__Template_Type__c, APXTConga4__Name__c, (SELECT Id FROM ContentDocumentLinks WHERE IsDeleted <> TRUE) FROM APXTConga4__Conga_Template__c WHERE Id IN ('" + Array.from(lettersAndLabelsToCheckAttachment).join("','") + "') ORDER BY APXTConga4__Template_Type__c ASC");
                    var invalidTemplates = [];
                    for(var i = 0 ; i < templates.length; i++){
                        if(!templates[i].ContentDocumentLinks || templates[i].ContentDocumentLinks.size < 1){
                            invalidTemplates.push(templates[i]);
                        }
                    }

                    if(invalidTemplates.length > 0){
                        var message = 'Following selected Letters/Labels have no templates attached,<br>please make sure that there is a valid Template attached to all selected Letters/Labels.<br>';

                        for(var i = 0; i < invalidTemplates.length; i++){
                            message += '<br>'+invalidTemplates[i].APXTConga4__Template_Type__c+'- '+invalidTemplates[i].APXTConga4__Name__c;
                        }

                        kendoPopup.popupWithButtons(POPUP_HEADER, message, []);
                        return false;
                    }
                    return true;
                }else{
                    kendoPopup.popupWithButtons(POPUP_HEADER, 'Please select Letter/Label for all the selected opportunities', []);
                    return false;
                }
            }

            function printTemplates() {
                var opportunityIds = [];
                for (var i = 0; i < context.selectedRows.length; i++) {
                    opportunityIds.push(context.selectedRows[i].id);
                }

                var baseURL = 'https://conductor.congamerge.com/Conductor8/index.html?';
                baseURL += 'MOID=' + opportunityIds.join(',');
                baseURL += '&SessionId=' + sforce.connection.sessionId;
                baseURL += '&ServerUrl=' + context.actionGrid.settings.Partner_Server_URL_290;
                baseURL += '&UrlFieldName=' + 'CongaConductorPrintTemplate__c';
                window.open(baseURL);

                Process();
            }

            function Process() {
                var ids = [];
                for (var i = 0; i < context.selectedRows.length; i++) {
                    ids.push(context.selectedRows[i].id);
                }

                //Query for the data that needs to be passed into new records.
                var sbrTasks = sfdc.query("SELECT Id FROM Task WHERE IsClosed = False AND TaskResult__c <> \'" + TASK_RESULT_WILL_NOT_SEND + "\' AND TaskResult__c <> \'" + TASK_RESULT_SENT_BROCHURE + "\' AND RecordType.DeveloperName IN ('SBRTask','SBR_Task_Read_Only') AND WhatId IN ('" + ids.join("','") + "')");

                //Loop through each result and pull the data.
                var records = [];

                for (var i = 0; i < sbrTasks.length; i++) {
                    var record = new sforce.SObject('Task');
                    record.Id = sbrTasks[i].Id;
                    record.TaskResult__c = TASK_RESULT_SENT_BROCHURE;
                    record.Status = 'Completed';
                    records.push(record);
                }

                var onfailure = function (error) {
                    kendoPopup.popupWithButtons(POPUP_HEADER, error.message || error.faultstring, []);
                };

                if (records.length > 0) {
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
                } else {
                    kendoPopup.popupWithButtons(POPUP_HEADER, 'No SBR Task records to update', []);
                }
            }

            if (templatesAreValid()) {
                printTemplates();
            }
        }
    });
});
