crmc.require(["sfdc", "KendoPopup"], function (sfdc,kendoPopup) {

    crmc.addCustomAction({
        "itemID": "AG_View_Team_Workload_Report",
        "isAvailable": function (context) {
            return false;
        },
        "isToolbarAvailable": function (context) {
            return true;
        },
        "getLabel": function (context) {
            return "Team Workload";
        },
        "createSubmenuItems": function (context) {
            return [];
        },
        "click": function (context) {
          var workloadReport = sfdc.query("SELECT Id,DeveloperName From Report WHERE DeveloperName = 'Opportunity_Workload_Till_Tomorrow_EOD' LIMIT 1");
          if(workloadReport.length == 0 || workloadReport[0].Id == null){
            kendoPopup.popupWithButtons("Team Workload", "Could not find Report", []);
          } else {
            var win = window.open('/' + workloadReport[0].Id, '_blank');
            win.focus();
          }
        }
    });
});