/**************************************************************************************
Apex Class Name    : TemplateSettingsSelector
Version            : 1.0
Created Date       : Dec 6 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej             06-Dec-2017            Original Version
*******************************************************************************/
public class TemplateSettingsSelector {

    public static List<TemplateSetting__c> getTemplateSettingsByKeys(Set<String> templateKeys){
        return [
                SELECT Name, AgeFromYears__c, AgeFromMonths__c,
                        AgeToYears__c, AgeToMonths__c,
                        Letter__c, Label__c, Market__c, Program__c, Language__c, TemplateKey__c
                FROM TemplateSetting__c
                WHERE TemplateKey__c IN : templateKeys AND IsActive__c = TRUE
        ];
    }
}