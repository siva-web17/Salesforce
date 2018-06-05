/**************************************************************************************
Apex Class Name    : DcJobsSelector
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  07/16/2017              Original Version
*******************************************************************************/
public class DcJobsSelector {

    public static List<dupcheck__dc3Duplicate__c> selectDuplicateRecordsByDCJobID( List<Id> jobidList) {
        List <dupcheck__dc3Duplicate__c> dcheckDc3Dups = new List<dupcheck__dc3Duplicate__c>();
        if (jobidList!=null && jobidList.size()>0)
        {
            dcheckDc3Dups = [SELECT Id,
                                    dupcheck__dcJob__c,
                                    dupcheck__sourceObject__c,
                                    dupcheck__MatchObject__c
                              FROM  dupcheck__dc3Duplicate__c
                             WHERE  dupcheck__dcJob__c in :jobidList];
        }
        return dcheckDc3Dups;
    }
}