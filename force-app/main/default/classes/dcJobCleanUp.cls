global class dcJobCleanUp implements Schedulable{

    global void execute(SchedulableContext sc) {

        List<dupcheck__dcJob__c> jobList = [
                SELECT Id,dupcheck__status__c
                FROM dupcheck__dcJob__c
                WHERE dupcheck__duplicateCount__c =0
                AND (dupcheck__status__c ='Aborted' OR dupcheck__status__c ='Completed')
        ];
        Set<Id> jobIdSet = new Set<Id>();
        for (dupcheck__dcJob__c j : jobList) {
            jobIdSet.add(j.Id);
        }

        database.executeBatch(new dupcheck.dc3SearchBatchDelete(jobIdSet,'DUPLICATE'));
    }
}