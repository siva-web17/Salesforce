/**************************************************************************************
Apex Class Name    : AccountOpportunitiesListController
Version            : 1.0
Created Date       : March 12 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  03/09/2018              Original Version
*******************************************************************************/

public without sharing class OpportunitiesSelectorWithoutSharing{

    /**
    * @author Adam Osiecki
    * ver 1.0 12-Mar-2018
    * @description Returns List of Opportunities for selected Account
    *
    * @param accountId account Id to select
    *
    * @return Map<Id,Opportunity>
    */

    public static List<Opportunity> getOpportunitiesByAccountId(Set<Id> accountIds){
        return OpportunitiesSelector.getOpportunitiesByAccountId(accountIds);
    }
}