public class PoseidonSyncService {
    public static final String SyncStatusTodo = 'Todo';
    public static final String SyncStatusSuccess = 'Success';
    public static final String SyncStatusFail = 'Fail';
    public static final String SyncStatusInProgress = 'In Progress';

    public static void setSyncStatus(List<Account> accounts, String status) {
        for(Account acc : accounts){
            acc.PoseidonSyncStatus__c = status;
        }
    }
}