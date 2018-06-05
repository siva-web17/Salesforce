/**
 * Created by britenet-patrykzak on 28/05/2018.
 */

@IsTest
private class SandboxEmailInvalidatorTest {
    @isTest
    static void When_SandboxEmailInvalidatorSandboxPost_Expect_InvalidateEmailAdresses() {
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser) {

            String testEmail = 'test@gmail.pl';
            String instanceNameFromUserInfo = UserInfo.getUserName().substringAfterLast('.');

            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();
            Lead lead = (Lead)leadBuilder.getRecord();
            lead.Email = testEmail;
            lead.ParentEmail__c = testEmail;
            insert lead;

            TestDataFactory.PersonAccountBuilder pab = new TestDataFactory.PersonAccountBuilder();
            Account acc = (Account)pab.getRecord();
            acc.PersonEmail = testEmail;
            acc.InvoiceEmail__c = testEmail;
            acc.ParentEmail__c = testEmail;
            insert acc;

            Test.startTest();

            Test.testSandboxPostCopyScript(
                new SandboxEmailInvalidatorSandboxPostCopy(),
                UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(),
                UserInfo.getOrganizationName()
            );

            Test.stopTest();

            List<Lead> leadsList = [SELECT id,Email,Email2__c,ParentEmail__c From Lead];
            List<Account> accountsList = [SELECT id,PersonEmail,InvoiceEmail__c,Email2__c,ParentEmail__c From Account WHERE IsPersonAccount = True];

            System.assert(leadsList.size()>0);
            System.assert(accountsList.size()>0);
            System.assert(leadsList[0].Email == testEmail + '.' + instanceNameFromUserInfo);
            System.assert(leadsList[0].Email2__c == null);
            System.assert(accountsList[0].PersonEmail == testEmail + '.' + instanceNameFromUserInfo);
            System.assert(accountsList[0].Email2__c == null);
        }
    }
}