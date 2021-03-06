/**************************************************************************************
Apex Class Name    : RankingHandler
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class RankingHandler { 
   ///Pass LeadList to check each lead against Ranking setting and legal setting
    public static Map<ID, Boolean> getLeadSettings(List<Lead> leadList) {
        Map<ID, Boolean> qualificationMap = new Map<Id, Boolean>();
        try {
            //get the map of raning name and settings
            Map<String, LeadRankingSetting__c> rankingSettingMap = LeadRankingSetting__c.getAll();
            //get the map of legal setting name and legal setting
            Map<String, LegalSettings__c> MapLegalSetting = LegalSettings__c.getAll();
            Boolean isQualified = false;
            String Combination = '';
            LegalSettings__c objLS = new LegalSettings__c();
            for (Lead leadRecord : leadList) {
                 //skipping ranking and legal setting if the lead are loading as Account or Opportunity(SF-280)
                if( leadRecord.CreationMethod__c == 'Excel Import' && !String.isBlank(leadRecord.CreationType__c) ) {
                    qualificationMap.put(leadRecord.id,leadRecord.CreationType__c != System.Label.StringLead);
                    continue;
                }
                //Ranking
                Combination = leadRecord.Market__c + '_' + leadRecord.Program__c;
                system.debug('******** combination'+Combination);
                if (rankingSettingMap.containsKey(Combination) &&
                        leadRecord.Ranking__c < rankingSettingMap.get(Combination).Ranking__c) {
                    system.debug('******** map'+rankingSettingMap.get(Combination).Ranking__c);
                    isQualified = true;
                }
                // Both Ranking setting and legal setting should be true to be qualified
                //legal setting
                if (isQualified && MapLegalSetting.containsKey(leadRecord.Market__c)) {
                    objLS = MapLegalSetting.get(leadRecord.Market__c);
                    system.debug('Doubleoptin>>>>>'+objLS);
                    system.debug('Doubleoptin@@@@@'+leadRecord);
                    if (objLS.CallCampaign__c && objLS.DoubleOptIn__c && leadRecord.IsCAMOnly__c) {
                        isQualified = leadRecord.IsCAMOnly__c && leadRecord.DoubleOptIn__c?true:false;
                    } else if(objLS.CallCampaign__c && leadRecord.IsCAMOnly__c ){
                        isQualified = true;
                    }
                    else if(objLS.DoubleOptIn__c && !leadRecord.IsCAMOnly__c && leadRecord.DoubleOptIn__c){
                        isQualified = true;
                    }
                    else if(!objLS.DoubleOptIn__c && !leadRecord.IsCAMOnly__c) {
                        isQualified=true;
                    }
                    else {
                        isQualified = false;
                    }
                }
                //map of lead and qualified status
                qualificationMap.put(leadRecord.Id, isQualified);
                system.debug('final qualification Map **** Lead record '+leadRecord.Id+'********** value '+isQualified);
            }
        } catch (exception ex) {
            ExceptionHandler.errorLog( ex.getMessage(), ex.getStackTraceString(), 'RankingHandler',
                    'getLeadSettings', null);
        }
        return QualificationMap;
    }
}