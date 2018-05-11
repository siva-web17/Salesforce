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
    static void when_DcJobCleanUpIsScheduled_Dc3SearchBatchDeleteIsExecuted(){
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
            List<AsyncApexJob> asyncBatchApexJobs = [
                    SELECT CreatedById
                    FROM AsyncApexJob
                    WHERE JobType = 'BatchApex' AND CreatedById = :adminUser.Id];

            List<AsyncApexJob> asyncScheduledApexJobs = [
                    SELECT CreatedById
                    FROM AsyncApexJob
                    WHERE JobType = 'ScheduledApex' AND CreatedById = :adminUser.Id];

            System.assertEquals(1, asyncBatchApexJobs.size(), 'Expecting exactly one Batch job queried');
            System.assertEquals(1, asyncScheduledApexJobs.size(), 'Expecting exactly one Scheduled job queried');
        }
    }
}