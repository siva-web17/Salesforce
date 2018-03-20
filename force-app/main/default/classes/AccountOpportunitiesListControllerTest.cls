@isTest
private class AccountOpportunitiesListControllerTest{

    @testSetup
    static void testDataSetup(){
        TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
        ob.withPersonAccount();
        ob.save();
    }
    @isTest
    static void When_SelectingOpportunitiesForAccount_Expect_ListOfResults(){
        //given
        Account testAccount = [SELECT Id FROM Account LIMIT  1];

        //when
        Test.startTest();
        List<AccountOpportunitiesListController.OpportunityWrapper> opportunityWrappers =
                AccountOpportunitiesListController.getOpportunities(testAccount.Id);
        Test.stopTest();

        //then
        System.assertEquals(1, opportunityWrappers.size(),'');
    }
}