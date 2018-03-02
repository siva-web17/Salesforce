/**************************************************************************************
Apex Class Name    : StartDatesSelector
Version            : 1.0
Created Date       : September 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arjun.Mohan                 09/22/2017              Original Version
*******************************************************************************/

public class StartDatesSelector {

    Public static List<Start_Dates__c> getStartDatesForSelectedBundle(String query) {
        List<Start_Dates__c> startdateList = Database.query(query);
        system.debug('Startdate count is' + startdateList);
        return startdateList;
    }

    Public static List<ProfileNamesForAdminAccess__mdt> getProfilesForAdminAccess(String sObjectname) {
        return [Select Id,Profiles__c,SObjectname__c from ProfileNamesForAdminAccess__mdt where SObjectname__c = :sObjectname];
    }

    Public static List<StartDateSettings__mdt> getStartDateSettings(String destinationCode, string program) {

        List<StartDateSettings__mdt> startDateSettingsList = new List<StartDateSettings__mdt>();
        List<StartDateSettings__mdt> actualstartDateSettingsList = new List<StartDateSettings__mdt>();
        System.debug('Destination Code ' + destinationCode + ' program ' + program);
        startDateSettingsList = [
                Select Id, DestinationCode__c, Program__c,EndDateOffSet__c, ProductCode__c, ProductSubType__c, ProductType__c, StartDateOffSet__c, ValidAccommodationDays__c
                from StartDateSettings__mdt
                where DestinationCode__c = :destinationCode
        ];

        if (startDateSettingsList.size() == 0) {
            startDateSettingsList = [
                    Select Id, DestinationCode__c,Program__c, EndDateOffSet__c, ProductCode__c, ProductSubType__c, ProductType__c, StartDateOffSet__c, ValidAccommodationDays__c
                    from StartDateSettings__mdt
                    where DestinationCode__c = 'ALL'
            ];
        }
        for (StartDateSettings__mdt settingRecord : startDateSettingsList) {
            String[] ProgramsList = settingRecord.Program__c.split(';');
            for (String programrecord : ProgramsList) {
                string rec = program.toUpperCase().trim();
                if (rec.equals(program.toUpperCase().trim())) {
                    actualstartDateSettingsList.add(settingRecord);
                    break;
                }
            }
            if (actualstartDateSettingsList.size() > 0) {
                break;
            }
        }
        system.debug('Selected Start dates settings are ' + startDateSettingsList);
        return actualstartDateSettingsList;

    }
}