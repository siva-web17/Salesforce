@isTest(SeeAllData=true) 
public class LeadConversionBatchTest{

    @isTest 
    static void setupData(){
        User adminUser = TestDataFactory.createAdminUser(true);
        System.runAs(adminUser) {
	        Test.startTest(); 
			LeadConversionBatch LCB = new LeadConversionBatch();
			DataBase.executeBatch(LCB, 1);
	        Test.stopTest();
        }
    }

    @isTest
    static void shouldScheduleBatchEvery30Mins() {
        Test.startTest();
        LeadConversionBatch.scheduleEvery30mins();
        Test.stopTest();
       	List<CronTrigger> ctList = [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE :LeadConversionBatch.SCHEDULED_JOB_NAME+'%_test'];
        System.assertEquals(2, ctList.size());
        System.assert(ctList[0].CronJobDetail.Name.startsWith(LeadConversionBatch.SCHEDULED_JOB_NAME));
        System.assert(ctList[1].CronJobDetail.Name.startsWith(LeadConversionBatch.SCHEDULED_JOB_NAME));
    }
}