/**
 * Created by aneesh.bhat on 1/11/2018.
 */

public with sharing class LogACallHelper {
    public static Set<String> allReachedItems = new Set<String>{
            Label.CallReached.toUpperCase(), Label.CalledUs.toUpperCase(), Label.VisitedUs.toUpperCase(), Label.EmailedUs.toUpperCase(), Label.SocialMediaReached.toUpperCase()
    };
    public static Set<String> allNotReachedItems = new Set<String>{
            Label.CallNotReached.toUpperCase(), Label.SentEmail.toUpperCase(), Label.SocialMediaSent.toUpperCase()
    };

    public static Set<String> callTypes = new Set<String>{
            Label.CallReached.toUpperCase(),Label.CallNotReached.toUpperCase(), Label.CalledUs.toUpperCase()
    };
    public static Set<String> emailTypes = new Set<String>{
            Label.SentEmail.toUpperCase(), Label.EmailedUs.toUpperCase()
    };
    public static Set<String> taskTypes = new Set<String>{
            Label.SocialMediaSent.toUpperCase(),Label.SocialMediaReached.toUpperCase(),Label.VisitedUs.toUpperCase()
    };

    public static String getTaskSubType(String callAction){
        system.debug('callAction>>>'+callAction);
        if(callTypes.contains(callAction.toUpperCase())) {
            system.debug('insidecalltypes>>>'+callAction);
            return 'Call';
        }
        if(emailTypes.contains(callAction.toUpperCase())) {
            return 'Email';
        }
        if(taskTypes.contains(callAction.toUpperCase())) {
            return 'Task';
        }
        return null;
    }

    /**
     * @author Aneesh Bhat
     * ver 1.0 11-Jan-2018
     * @description Handles the actions performed on Log a Call component
     *
     * @param parentId Represents the ID of the object on which Log a Call was performed
     * @param newTask Task record representing the Tassk that was performed
     * @param visitDatetime Represents the Visit date if the Call Result is Visit
     *
     */
    public static void handleLogAnAction(Id parentId, Task newTask, Datetime visitDatetime, String oldProgram) {
        Task openCallTask = null;
        Opportunity opp = null;
        Lead lead = null;
        String finalProgram;
        String callAction = newTask.SalesAction__c;
        String callResult = newTask.ResultType__c;
        String selectedProgram = newTask.Program__c;
        String closeReason = newTask.CloseMainReason__c;
        Datetime followupDate = newTask.FollowUpDate__c;
        String currentProgram = '';
        // If Lead, use WhoId to filter
        // If Opportunity, use WhatId to filter

        //get parent record with it's system call task
        if(parentId.getSobjectType() == Schema.Lead.SObjectType){
            List<Lead> leads = getLeadsWithOpenSystemCallTask(new Set<Id>{parentId},newTask.FollowUpDate__c, callResult);
            if(leads.size() > 0){
                lead = leads[0];
                if (lead.Tasks.size() > 0) {
                    openCallTask = lead.Tasks[0];
                }
                currentProgram = lead.Program__c;
            }
        }else if(parentId.getSobjectType() == Schema.Opportunity.SObjectType){
            List<Opportunity> opportunities = getOpportunitiesWithOpenSystemCallTask(new Set<Id>{parentId},newTask.FollowUpDate__c, callResult);
            if(opportunities.size() > 0){
                opp = opportunities[0];
                if(opp.Tasks.size() > 0){
                    openCallTask = opp.Tasks[0];
                }

                if (callAction != NULL && allReachedItems.contains(callAction.toUpperCase()) && opp.FirstContactDateTime__c == NULL) {
                    opp.FirstContactDateTime__c = Datetime.now();
                    update opp;
                }
                currentProgram = opp.Program__c;
            }
        }

        system.debug('Opencalltask : '+openCallTask);
        if (callAction != null && callResult != null ) {
            if(openCallTask != NULL) {
                System.debug('Open Call task exists');
                if (allReachedItems.contains(callAction.toUpperCase())) {
                    openCallTask.IsExpressCall__c = false;
                }

                String nextCallType = openCallTask.NextCallType__c;
                openCallTask.IsParentClosing__c = true;
                if (callResult.toUpperCase() == Label.CallBack.toUpperCase()) {
                    System.debug('Call back section invoked' );
                    if (allReachedItems.contains(callAction.toUpperCase()) &&
                            (nextCallType == TasksHelper.SalesTasks.FUP.name() ||
                                    nextCallType == TasksHelper.SalesTasks.FUA.name() ||
                                    nextCallType == TasksHelper.SalesTasks.TCC.name() ||
                                    nextCallType == TasksHelper.SalesTasks.UCC.name())) {
                        System.debug('Call back section if invoked' );
                        openCallTask.NextCallType__c = TasksHelper.SalesTasks.FUP.name();
                    } else if (allNotReachedItems.contains(callAction.toUpperCase())) {
                        if (nextCallType == TasksHelper.SalesTasks.TCC.name() || nextCallType == TasksHelper.SalesTasks.UCC.name()) {
                            System.debug('Call back section else-if-if invoked' );
                            openCallTask.NextCallType__c = TasksHelper.SalesTasks.UCC.name();
                        } else if (nextCallType == TasksHelper.SalesTasks.FUP.name() || nextCallType == TasksHelper.SalesTasks.FUA.name()) {
                            System.debug('Call back section else-if-else invoked' );
                            openCallTask.NextCallType__c = TasksHelper.SalesTasks.FUP.name();
                        }
                    }

                    openCallTask.FollowUpDate__c = followupDate;
                    openCallTask.OriginalDueDate__c = followupDate;                    
                    openCallTask.ActivityDate = SFLangUtil.ConvertDateTimeTodate(followupDate);
                } else if (callResult.toUpperCase() == Label.CallAppointment.toUpperCase()) {
                    System.debug('Call appointment section invoked');
                    openCallTask.NextCallType__c = TasksHelper.SalesTasks.FUA.name();
                    openCallTask.FollowUpDate__c = followupDate;
                    openCallTask.OriginalDueDate__c = followupDate;
                    openCallTask.ActivityDate = SFLangUtil.ConvertDateTimeTodate(followupDate);
                } else if (callResult.toUpperCase() == Label.Visit.toUpperCase()) {
                    System.debug('Visit section invoked');
                    openCallTask.NextCallType__c = TasksHelper.SalesTasks.FUP.name();
                    openCallTask.FollowUpDate__c = followupDate;
                    openCallTask.OriginalDueDate__c = followupDate;
                    openCallTask.ActivityDate = SFLangUtil.ConvertDateTimeTodate(followupDate);
                    Event visitEvent = new Event();
                    visitEvent.Program__c = (String.valueOf(parentId).substring(0, 3) == '00Q') ? lead.Program__c : opp.Program__c;
                    visitEvent.FollowUpDate__c = visitDatetime;
                    visitEvent.RecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Event.SObjectType).get(TasksHelper.VISIT_EVENT_DEVELOPER_NAME).Id;
                    visitEvent.Subject = system.label.OfficeVisit;
                    if (String.valueOf(parentId).substring(0, 3) == '006') {
                        visitEvent.WhatId = opp.Id;
                    } else if (String.valueOf(parentId).substring(0, 3) == '00Q') {
                        visitEvent.WhoId = lead.Id;
                    }
                    visitEvent.DurationInMinutes = 30;
                    visitEvent.ActivityDateTime = visitDatetime;
                    insert visitEvent;
                }else if (callResult.toUpperCase() == Label.CloseOpp.toUpperCase()) {
                    System.debug('Close section invoked');
                    if (String.valueOf(parentId).substring(0, 3) == '006') {
                        opp.CloseMainReason__c = closeReason;
                        update opp;
                    } else if (String.valueOf(parentId).substring(0, 3) == '00Q') {
                        lead.CloseMainReason__c = closeReason;
                        update lead;
                    }
                    //openCallTask.Status = 'Completed';
                }

                if ((callResult.toUpperCase() == Label.ChangeProgram.toUpperCase()) ||
                        (allReachedItems.contains(callAction.toUpperCase()) && oldProgram == 'MULTI')) {
                    System.debug('Change program section invoked');
                    openCallTask.NextCallType__c = TasksHelper.SalesTasks.FUP.name();
                    openCallTask.FollowUpDate__c = followupDate;
                    openCallTask.OriginalDueDate__c = followupDate;
                    openCallTask.ActivityDate = SFLangUtil.ConvertDateTimeTodate(followupDate);
                    String subject = openCallTask.Subject;

                    if(!String.isEmpty(selectedProgram)){
                        openCallTask.Program__c = selectedProgram;
                        List<String> splitSubject = subject.split('\\-');
                        if (splitSubject.size() > 0) {
                            openCallTask.Subject = splitSubject[0] + ' - ' + selectedProgram;
                        }
                        if (String.valueOf(parentId).substring(0, 3) == '006') {
                            if (opp.Program__c != selectedProgram) {
                                opp.Program__c = selectedProgram;
                                update opp;
                         	}
                        } else if (String.valueOf(parentId).substring(0, 3) == '00Q') {
                            if ( lead.Program__c != selectedProgram) {
                                lead.Program__c = selectedProgram;
                                update lead;
                            }
                        }
                    }
                }

                system.debug('openCallTask.NextCallType : '+openCallTask.NextCallType__c);
                if(TasksHelper.taskSettingsMap.containsKey(openCallTask.NextCallType__c)) {
                    openCallTask.Subject = TasksHelper.taskSettingsMap.get(openCallTask.NextCallType__c).TaskSubject__c;
                    system.debug('openCallTask.Subject : '+openCallTask.Subject);
                }
                openCallTask.ActivityDateTime__c = System.Now();
                openCallTask.IsParentClosing__c = false;
                //upsert new List<Task>{newTask, openCallTask};
                update openCallTask;
            }

            if(openCallTask != null){
                newTask.NextCallType__c = openCallTask.NextCallType__c;
            }
            newTask.Status = 'Completed';
            newTask.Program__c = oldProgram;

            insert newTask;
        }
    }

    /**
    * @author Aneesh Bhat
    * ver 1.0 11-Jan-2018
    * @description Returns List of Leads with List of Open Call Tasks
    *
    * @param parentIds Represents the List of Lead Ids
    * @param followupDateTime Represents the Followup Datetime specified in the Call action
    * @param callResult Represents the Call Result of the Call made
    *
    */
    private static List<Lead> getLeadsWithOpenSystemCallTask(Set<Id> parentIds, DateTime followupDateTime, String callResult){
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;
        List<Lead> leads = LeadsSelector.getLeadsByIdsWithTasks(new List<Id>(parentIds));
        if(leads.size() > 0 && callResult != Label.CloseOpp && followupDateTime != NULL){
            Lead lead = leads[0];
            if(lead.Tasks.size() > 0) {
                Task callTask = null;
                for(Task objTask:lead.Tasks){
                    if(!objTask.IsClosed) {
                        objTask.ownerid = UserInfo.getUserId();
                    }
                    if(objTask.RecordTypeId == systemCallTaskRecordTypeId){
                        callTask = objTask;
                    }
                }

                update lead.Tasks;
                //Task callTask = lead.Tasks[0];
                if(callTask!=null && callTask.IsClosed) {
                    System.debug('Open the existing System Call Task');
                    callTask.IsParentClosing__c = true;
                    callTask.Status = 'Not Started' ;
                    callTask.FollowUpDate__c = followupDateTime;
                    update callTask;
                    callTask.IsParentClosing__c = false;
                    update callTask;
                }
                if(callTask == null){
                    System.debug('Created a new Task');
                    callTask = LeadsHelper.createSystemCallTaskRecordForLead(lead);
                    insert callTask;
                }
            }
            else{
                System.debug('Created a new Task');
                Task callTask = LeadsHelper.createSystemCallTaskRecordForLead(lead);
                insert callTask;
            }
        }
        return LeadsSelector.getLeadsWithOpenSystemCallTask(parentIds);
    }

    /**
    * @author Aneesh Bhat
    * ver 1.0 11-Jan-2018
    * @description Returns List of Opportunities with List of Open Call Tasks
    *
    * @param parentIds Represents the List of Opportunity Ids
    * @param followupDateTime Represents the Followup Datetime specified in the Call action
    * @param callResult Represents the Call Result of the Call made
    *
    */
    public static List<Opportunity> getOpportunitiesWithOpenSystemCallTask(Set<Id> parentIds, Datetime followupDatetime, String callResult){
        system.debug('insiedLogacallhelper>>>');
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;
        List<Opportunity> opportunities = OpportunitiesSelector.getOpportunitiesByIdsWithTasks(new List<Id>(parentIds));

        Task callTask = null;
        if(opportunities.size() > 0 && callResult != Label.CloseOpp && followupDatetime != NULL) {
            Opportunity opp = opportunities[0];
            if(opp.Tasks.size() > 0) {
                for(Task objTask:opp.Tasks){
                    if(objTask.RecordTypeId == systemCallTaskRecordTypeId && objTask.Type == TasksHelper.CALL){
                        callTask = objTask;
                    }
                }

                if(callTask == null){
                    System.debug('Created a new Task');
                    callTask = OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opp);
                    callTask.NextCallType__c = getNextCallTypeOnSCT(opp);
                    callTask.Subject = TasksHelper.taskSettingsMap.get(callTask.NextCallType__c).TaskSubject__c;
                    insert callTask;
                }
                else if(callTask.IsClosed) {
                    System.debug('Open the existing System Call Task');
                    callTask.IsParentClosing__c = true;
                    callTask.Status = 'Not Started' ;
                    callTask.FollowUpDate__c = followupDatetime;
                    callTask.NextCallType__c = getNextCallTypeOnSCT(opp);
                    callTask.Subject = TasksHelper.taskSettingsMap.get(callTask.NextCallType__c).TaskSubject__c;
                    update callTask;
                    callTask.IsParentClosing__c = false;
                    update callTask;
                }
            }
            else {
                System.debug('Created a new Task');
                callTask = OpportunitiesHelper.createSystemCallTaskRecordForOpportunity(opp);
                callTask.NextCallType__c = getNextCallTypeOnSCT(opp);
                callTask.Subject = TasksHelper.taskSettingsMap.get(callTask.NextCallType__c).TaskSubject__c;
                insert callTask;
            }
        }
        return OpportunitiesSelector.getOpportunitiesWithOpenSystemCallTask(parentIds);
    }

    private static String getNextCallTypeOnSCT(Opportunity opp){
        if(opp.FirstContactDateTime__c == NULL){
            if(opp.Tasks == NULL || opp.Tasks.size() == 0){
                return TasksHelper.SalesTasks.TCC.name();
            }

            for(Task task : opp.Tasks){
                if(task.SalesAction__c == Label.CallNotReached){
                    return TasksHelper.SalesTasks.UCC.name();
                }
            }

            return TasksHelper.SalesTasks.TCC.name();
        }
        else{
            return TasksHelper.SalesTasks.FUP.name();
        }

    }
}