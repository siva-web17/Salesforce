/**
 * Created by Arkadiusz Celej on 26.03.2018.
 */

@IsTest
private class PoseidonAccountSyncBatchTest {

    @testSetup
    static void setupData(){
        User adminUser = TestDataFactory.createAdminUser(true);
        System.runAs(adminUser) {

            BypassTriggersValidation__c bpv = new BypassTriggersValidation__c();
            bpv.DisableTrigger__c = true;
            bpv.DisableValidation__c = true;
            bpv.SetupOwnerId = adminUser.Id;
            bpv.TriggerObject__c = SObjectType.Account.Name;

            insert bpv;

            TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
            for(Integer i = 0; i < 10 ; i++){
                ob.withPersonAccount();
                Account acc = ob.getAccount();
                acc.PoseidonSyncStatus__c = PoseidonSyncService.SyncStatusTodo;
                acc.AccountExternalId__c = i;
                acc.PersonMailingCity = 'Test City';
                acc.IsSyncedToPoseidon__c = true;
                ob.withBooking();
                ob.save();
            }
        }

    }

    @isTest
    static void shouldScheduleBatchEvery30Mins() {
        Test.startTest();
        PoseidonAccountSyncBatch.scheduleEvery30mins();
        Test.stopTest();

        List<CronTrigger> ctList = [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE :PoseidonAccountSyncBatch.SCHEDULED_JOB_NAME+'%_test'];
        System.assertEquals(2, ctList.size());
        System.assert(ctList[0].CronJobDetail.Name.startsWith(PoseidonAccountSyncBatch.SCHEDULED_JOB_NAME));
        System.assert(ctList[1].CronJobDetail.Name.startsWith(PoseidonAccountSyncBatch.SCHEDULED_JOB_NAME));
    }

    @isTest
    static void shouldSyncAccountsWithPoseidonSyncStatusTodo(){
        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {
            //given
            //when
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.SuccessCalloutMock());
            PoseidonAccountSyncBatch psb = new PoseidonAccountSyncBatch();
            List<Account> scope = psb.start(null);
            psb.execute(null, scope);
            Test.stopTest();
            //then
            for(Account acc : [SELECT Id, PoseidonSyncStatus__c FROM Account]){
                System.assertEquals(PoseidonSyncService.SyncStatusSuccess, acc.PoseidonSyncStatus__c, 'Incorrect status');
            }
        }
    }

    @isTest
    static void onFailedCalloutShouldUpdateAccountsSyncStatusToFail(){
        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {
            //given
            //when
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.FailureCalloutMock());
            PoseidonAccountSyncBatch psb = new PoseidonAccountSyncBatch();
            List<Account> scope = psb.start(null);
            psb.execute(null, scope);
            Test.stopTest();
            //then
            for(Account acc : [SELECT Id, PoseidonSyncStatus__c FROM Account]){
                System.assertEquals(PoseidonSyncService.SyncStatusFail, acc.PoseidonSyncStatus__c, 'Incorrect status');
            }
        }
    }

    @isTest
    static void onInvalidCalloutShouldUpdateAccountsSyncStatusToFail(){
        User adminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        System.runAs(adminUser) {
            //given
            //when
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.InvalidCalloutMock());
            PoseidonAccountSyncBatch psb = new PoseidonAccountSyncBatch();
            List<Account> scope = psb.start(null);
            psb.execute(null, scope);
            Test.stopTest();
            //then
            for(Account acc : [SELECT Id, PoseidonSyncStatus__c FROM Account]){
                System.assertEquals(PoseidonSyncService.SyncStatusFail, acc.PoseidonSyncStatus__c, 'Incorrect status');
            }
        }
    }
}