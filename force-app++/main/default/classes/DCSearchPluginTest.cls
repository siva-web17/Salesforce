/**************************************************************************************
Apex Class Name    : DCSearchPluginTest
Version            : 1.0
Created Date       : May 11 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki Adam                11/05/2018             Original Version
*******************************************************************************/

@IsTest
private class DCSearchPluginTest{

    @isTest
    static void when_searchResultsAreProcessed_expect_LeadsAreUpdated(){

        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            String methodName = 'ON_INSERT;';

            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            Lead lead = (Lead)leadBuilder.getRecord();
            insert lead;
            List<Lead> leads = [
                    SELECT IsDupeProcessed__c
                    FROM Lead
                    WHERE Id = :lead.Id
            ];
            System.assert(!leads[0].IsDupeProcessed__c, 'Expecting lead has IsDupeProcessed__c set to false after insert');
            Map<String, Object> searchResults = new Map<String, Object>();

            //when
            Test.startTest();
            DCSearchPlugin.processResults(methodName, lead.Id, searchResults);
            Test.stopTest();

            //then
            leads = [
                    SELECT IsDupeProcessed__c
                    FROM Lead
                    WHERE Id = :lead.Id
            ];
            System.assert(leads[0].IsDupeProcessed__c, 'Expecting lead has IsDupeProcessed__c set to true');

        }
    }
}