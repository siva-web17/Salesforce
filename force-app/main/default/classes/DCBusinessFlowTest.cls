/******************************************************************************
Apex Class Name    : DCBusinessFlowTest
Version            : 1.0
Created Date       : 21/05/2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Adam Osiecki                21/05/2017             Original version
*******************************************************************************/

@IsTest
private class DCBusinessFlowTest{

    private static User adminUser = TestDataFactory.createAdminUser(true);

    @isTest
    static void when_notifyForRankingIsSent_expect_LeadIsUpdated(){
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            List<Lead> leads = new List<Lead>();
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            Lead lead = (Lead)leadBuilder.getRecord();
            lead.IsDupeProcessed__c = FALSE;
            lead.ReadyForRanking__c = FALSE;
            leads.add(lead);
            insert leads;

            //when
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.CallForRankingMock(leads));
            DCBusinessFlowHelper.notifyForRanking(leads[0]);
            Test.stopTest();

            //then
            leads = [SELECT IsDupeProcessed__c, ReadyForRanking__c, Ranking__c FROM Lead WHERE Id IN :leads];
            System.assertEquals(1, leads.size());
            System.assert(leads[0].IsDupeProcessed__c, 'Expecting IsDupeProcessed Is set to true');
            System.assert(leads[0].ReadyForRanking__c, 'Expecting ReadyForRanking Is set to true');
            System.assertEquals(5, leads[0].Ranking__c, 'Expecting specific value of lead ranking');
        }
    }
}