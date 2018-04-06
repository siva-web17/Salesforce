/**
 * Created by Arkadiusz Celej on 23.03.2018.
 */

public class PoseidonAccountSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, System.Schedulable{

    public static final String SCHEDULED_JOB_NAME = 'Poseidon Account Sync Batch';
    public static Boolean SYNC_IN_PROGRESS = false;

    public List<Account> start(Database.BatchableContext BC){
        return findRecords();
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        SYNC_IN_PROGRESS = true;
        try {
            AccountsHelper.SyncAccountDetailsWrapper accountDetailsWrapper = AccountsHelper.retrieveDataToSync(new Map<Id, Account>(scope), null);
            if(accountDetailsWrapper != NULL) {
                ExternalRouter.updateAccountDetails(JSON.serialize(accountDetailsWrapper));
            }
        }catch (Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'PoseidonAccountSyncBatch', 'execute', null);
        }
        SYNC_IN_PROGRESS = false;
    }

    public void finish(Database.BatchableContext BC){}

    public void execute(SchedulableContext ctx){
        Database.executeBatch(new PoseidonAccountSyncBatch());
    }

    private List<Account> findRecords(){
        Set<String> toSyncStatuses = new Set<String>{PoseidonSyncService.SyncStatusTodo, PoseidonSyncService.SyncStatusFail};
        Set<String> fieldsToSelect=new Set<String>();

        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UpdatePersonalInfo.getFields()) {
            fieldsToSelect.add(f.getFieldPath());
        }
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Address.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
            }

        }

        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Customer.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
            }
        }
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.CustomerMarketingPref.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
            }
        }
        fieldsToSelect.addAll('Name,Id,Market__c,CreatedById,LastModifiedById,Firstname,lastname,ParentEmail__c,Middlename,PersonMailingCity,PersonMailingPostalCode,PersonMailingCountryCode,PersonMailingState,ShippingCity,ShippingState,ShippingStreet,PersonOtherPostalCode,TotalBooking__c'.split(','));

        String query = 'SELECT '+String.join(new List<String>(fieldsToSelect), ',')+' FROM Account WHERE (TotalBooking__c > 0 OR (AccountExternalId__c <> null AND IsSyncedToPoseidon__c = TRUE)) AND PoseidonSyncStatus__c IN :toSyncStatuses';

        return Database.query(query);
    }

    public static void scheduleEvery30mins(){
        String appendix = Test.isRunningTest()? '_test' : '';
        PoseidonAccountSyncBatch.schedule('0 0 * ? * *', SCHEDULED_JOB_NAME+' - 00 minute of hour'+appendix);
        PoseidonAccountSyncBatch.schedule('0 33 * ? * *', SCHEDULED_JOB_NAME+' - 30 minute of hour'+appendix);
    }

    public static void schedule(String crone, String label){
        System.schedule(label, crone, new PoseidonAccountSyncBatch());
    }
}