/**
 * Created by britenet-patrykzak on 07/05/2018.
 */

@IsTest
private class TemplateBuilderApexTest {

    @testSetup static void setup() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
    }

    static testMethod void When_getServerURL_Expect_ReturnServerURLForCurrentUserThatContainsOrganizationId() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Test.startTest();

            String serverURL = TemplateBuilderApexController.getServerURL();

            Test.stopTest();

            System.assert(serverURL.contains(UserInfo.getOrganizationId().substring(0,15)),'serverURL should contain organizationID');
        }
    }

    static testMethod void When_getRecordsWithLeadPrefix_Expect_ReturnListOfOpportunities() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Integer numberOfOpportunities = 100;
            Opportunity[] opportunities = new Opportunity[]{};

            for(Integer i = 0; i < numberOfOpportunities; i++) {
                TestDataFactory.OpportunityBuilder opportunityBuilder = new TestDataFactory.OpportunityBuilder();
                Opportunity testOpportunity = (Opportunity) opportunityBuilder.getRecord();
                opportunities.add(testOpportunity);
                opportunityBuilder.build();
            }
            insert opportunities;

            Test.startTest();

            List<SObject> sObjects = TemplateBuilderApexController.getRecords('00Q');

            Test.stopTest();

            System.assertEquals(sObjects.size(),numberOfOpportunities,'It should return all created Opportunities');
        }
    }

    static testMethod void When_getRecordsWithOpportunityPrefix_Expect_ReturnListOfLeads() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Integer numberOfLeads = 100;
            Lead[] leads = new Lead[]{};

            for(Integer i = 0; i < numberOfLeads; i++) {
                TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
                Lead testLead = (Lead) leadBuilder.getRecord();
                leads.add(testLead);
                leadBuilder.build();
            }
            insert leads;

            Test.startTest();

            List<SObject> sObjects = TemplateBuilderApexController.getRecords('006');

            Test.stopTest();

            System.assertEquals(sObjects.size(),numberOfLeads,'It should return all created Leads');
        }
    }

    static testMethod void When_getRecordsAccountPrefix_Expect_ReturnEmptyList() {

        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {

            Test.startTest();

            List<SObject> sObjects = TemplateBuilderApexController.getRecords('001');

            Test.stopTest();

            System.assert(sObjects.isEmpty(),'It should return an empty List');
        }
    }
}