public with sharing class MyProductivity {

    private static Id USER = UserInfo.getUserId();
    
    @AuraEnabled
    public static MyStatistics getMyStatistics(){
        MyStatistics stats = NULL;
        try{
            stats = new MyStatistics();
            Task[] tasks = TasksSelector.getTodaysCallTasksClosedByUser(USER);
            stats.myCompletedTasks = MyProductivity.calculateMyCompletedTasks(tasks);
            stats.myReachedTasks = MyProductivity.calculateMyReachedTasks(tasks);
            stats.reachedRate = stats.myCompletedTasks > 0 ? ((stats.myReachedTasks * 100.0 / stats.myCompletedTasks)).intValue() : 0;
            stats.myLeads = MyProductivity.myLeads();
        }catch(Exception ex){ throw new AuraHandledException(Label.AuraErrorMessage+ ex.getMessage()); }

        return stats;
    }
    
    private static Integer calculateMyCompletedTasks(Task[] tasks){
        return tasks.size();
    }

    private static Integer calculateMyReachedTasks(Task[] tasks){
        Integer reachedCount = 0;
        for(Task t : tasks){
            if(t.IsTaskCallReached__c){
                reachedCount++;
            }
        }
        return reachedCount;
    }
    
    private static Integer myLeads(){
        return (Integer)TasksSelector.getTodaysTasksByRecordTypeAndWhoType(Label.SystemCallTaskRecordTypeDeveloperName, 'Lead', USER)[0].get('cnt');
    }
    
    public class MyStatistics{
        @AuraEnabled
        public Integer myCompletedTasks;
        @AuraEnabled
        public Integer myReachedTasks;
        @AuraEnabled
        public Integer reachedRate;
        @AuraEnabled
        public Integer myLeads;
    }
}