/**************************************************************************************
Apex Class Name    : DcJobCleanUpTest
Version            : 1.0
Created Date       : May 10 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Osiecki A                  10/03/2018              Original Version
*******************************************************************************/


@IsTest
private class DcJobCleanUpTest{

    @isTest
    static void testBehavior(){
        User adminUser = TestDataFactory.createAdminUser(true);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            //given
            String testDcJobStatus = 'Aborted';
            String testDcJobName = 'TestName';
            String testDcJobSourceObject = '0010';
            String CRON_EXP = '0 0 0 1 1 ? 2055';

            dupcheck__dcJob__c dcJob = new dupcheck__dcJob__c(
                    dupcheck__status__c = testDcJobStatus,
                    dupcheck__name__c = testDcJobName,
                    dupcheck__sourceObject__c = testDcJobSourceObject

            );
            insert dcJob;

            List<AsyncApexJob> asyncApexJobs = [
                    SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                    FROM AsyncApexJob
            ];
            System.assertEquals(0, asyncApexJobs.size(), 'Checking if there are no jobs scheduled');

            //when
            Test.startTest();
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new dcJobCleanUp());
            Test.stopTest();

            //then
            CronTrigger ct = [
                    SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger
                    WHERE id = :jobId
            ];
            System.assertEquals(CRON_EXP, ct.CronExpression, 'Expecting job is scheduled correctly');
            System.assertEquals(0, ct.TimesTriggered, 'Expecting job is scheduled correctly');
            System.assertEquals('2055-01-01 00:00:00', String.valueOf(ct.NextFireTime), 'Expecting job is scheduled correctly');
        }
    }
}