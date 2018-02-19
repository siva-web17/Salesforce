public class TasksHelper {

    private static final String SEPARATOR = ';';
    public static final String SYSTEM_TASK_DEVELOPER_NAME = 'SystemCallTask';
    public static final String VISIT_EVENT_DEVELOPER_NAME = 'CustomerVisit';
    public static final String SBR_TASK_DEVELOPER_NAME = 'SBRTask';
    public static final String CALL_TASK_DEVELOPER_NAME = Label.CallTaskRecordTypeDeveloperName;
    public static final String MCR_TASK_DEVELOPER_NAME = 'MCRTask';
    public static final String SPQ_TASK_DEVELOPER_NAME = 'SPQTask';
    @testvisible private static final String DO_NOT_SEND_BROCHURE = 'Will not Send Brochure';
    @testvisible private static final String SENT_BROCHURE = 'Sent Brochure';
    public static final String CALL = 'Call';
    public static final String CONTACT_CUSTOMER = 'TCC';

    public enum CustomerActivities {
        BR, PQ, BKN, CNT, CALL, EXPRESS_CALL, CAM, CAM_BR,RES
    }
    public enum SalesTasks {
        TCC, UCC, FUP, FUA, SPQ, SBR, MCR, PTS, CLOSEDCALL, OPENCALL, Call
    }

    public enum SObjectName {
        LEAD, OPPORTUNITY, TASK, ACCOUNT
    }

    public enum TaskActivityType {
        CUSTOMERREQUEST, TASK
    }

    public enum SaveType {
        INSERTDATA, UPDATEDATA, CLOSEDINSERT
    }
    public static Opportunity oppRecord;
    public static Lead leadrecord;
    public static Event eventRecord;

    public static Map<String, Task> tasksForActivitiesList = new Map<String, Task>();
    public static Id eventId;
    public static Map<String, TaskSetting__mdt> taskSettingsMap = MetaDataSelector.getTaskSettingMetada();


    public static void convertActivitiesToTask(List<Opportunity> opportunityRecord) {
        Id parentId;
        Map<Id, List<Task>> currentTaskMap = new Map<Id, List<Task>>();
        Map<Id, List<Event>> activityMap = new Map<Id, List<Event>>();
        Map<Id, Opportunity> parentOpportunityMap = new Map<Id, Opportunity>();
        Map<Id, String> eventTypeValues = new Map<Id, String>();
        List<Event> eventsToUpdateList = new List<Event>();
        if (opportunityRecord.size() > 0) {
            {
                for (Opportunity opportunityRecords : opportunityRecord) {
                    {
                        currentTaskMap.put(opportunityRecords.id, opportunityRecords.tasks);
                        if(opportunityRecords.StageName==system.label.OpportunityBookingStage) {
                            system.debug('insideBooking>>');
                            activityMap.put(opportunityRecords.id, getEventToBeProcessed(opportunityRecords.events));
                            system.debug('insideBookingactivityMap>>>'+activityMap);
                        }
                        else {
                            system.debug('insideNotBooking>>');
                            activityMap.put(opportunityRecords.id, opportunityRecords.events);
                            system.debug('insideNotBookingactivityMap>>>'+activityMap);
                        }
                        parentOpportunityMap.put(opportunityRecords.id, opportunityRecords);
                    }

                    //Here we will get mix of LEAD and opportunity records
                    //Here we are getting all the activities for parent
                    //activityMap = EventsSelector.getAllActivities(parentIdList);
                    //taskSettingsMap = getTaskSettings();
                    //Here we are getting all the tasks for parent

                    //########Commented by suresh..why u need this ???*********
                    //currentTaskMap = TasksSelector.getAllTasksForparent(parentIdList) ;

                    try {

                        for (Id parentIds : activityMap.keySet()) {
                            for (Event parentActivity : activityMap.get(parentIds)) {
                                if(parentActivity == null)
                                {
                                    return;
                                }
                                eventRecord = parentActivity;
                                eventId = parentActivity.Id;
                                //Here we are processing record by record for parent object(LEAD/OPPORTUNITY
                                //parentId = parentActivity.whatId != null ? parentActivity.whatId : parentActivity.WhoId;

                                Map<String, List<Task>> filterTaskTypeForParentMap = new Map<String, List<Task>>();
                                //leadrecord = parentLeadMap.containsKey(parentId) ? parentLeadMap.get(parentId) : null;
                                oppRecord = parentOpportunityMap.containsKey(parentIds) ? parentOpportunityMap.get(parentIds) : null;

                                //Filter tasks based on task type
                                if (currentTaskMap.containsKey(parentIds))
                                    filterTaskTypeForParentMap = filterTaskTypeTaskForparent(currentTaskMap.get(parentIds), parentActivity.Program__c);

                                //Here we are collecting all the tasks which are to be saved(Insert/Update)
                                tasksForActivitiesList.putAll(saveActivityDataToTask(filterTaskTypeForParentMap, parentActivity));
                                parentActivity.ProcessedforTaskcreation__c = true;
                                eventsToUpdateList.add(parentActivity);

                            }
                        }
                        if (tasksForActivitiesList.size() > 0) {
                            SObjectUnitOfWork.saveTasks(tasksForActivitiesList.values());
                            //Here we are Marking Field on Events as ProcessedforTaskcreation__c=true;
                            SObjectUnitOfWork.modifyEvents(eventsToUpdateList);
                        }
                    } catch (exception ex) {
                        ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                                'Tasks', 'convertActivitiesToTask', eventId);
                    }
                }

            }

        }
    }

    public static List<Event> getEventToBeProcessed(List<Event> events) {
        //Opportunity oppRecord = [select id, stagename from opportunity where id in: events.whatid];

        List<Event> eventsToBeProcessed = new List<Event>();
        for (Event event : events) {
            system.debug('insidefor>>>>');
           // if(event.Type !='CAM'|| event.Type !='IM'|| event.Type !='BR'|| event.Type !='CBR'||event.Type !='CBR' ){
            if( event.Type != system.label.CAM && event.Type !=system.label.InfoMeeting &&
                    event.Type !=system.label.BrochureRequest && event.Type !=system.label.CampaignBrochureRequest &&
                    event.Type != system.label.IR ){
                system.debug('insideifprocessevent>>>>');
                eventsToBeProcessed.add(event);
            }
        }
        system.debug('eventsToBeProcessed>>>'+eventsToBeProcessed);
        return eventsToBeProcessed;
    }

    //Filter Tasks Types for parent using Map Ex:(SBR,List<3 SBR Tasks>)

    //Get the MetaData Values from Metadata Types
    public static Map<String, TaskSetting__mdt> getTaskSettings() {
        return MetaDataSelector.getTaskSettingMetada();
    }

    //Filter Tasks Types for parent using Map Ex:(SBR,List<3 SBR Tasks>)
    public static Map<String, List<Task>> filterTaskTypeTaskForparent(List<Task> currentParentTaskList,
            String CurrentProgram) {
        Map<String, List<Task>> currentParentTaskMap = new Map<String, List<Task>>();
        List<Task> brochureRequestTaskList = new List<Task>();
        List<Task> priceQuoteTaskList = new List<Task>();
        List<Task> taskClosedList = new List<Task>();
        List<Task> taskOpenList = new List<Task>();
        for (Task parentTask : currentParentTaskList) {
            System.debug('parentTask.Type :'+parentTask.Type );
            if ((parentTask.Type == SalesTasks.Call.name()
                    || parentTask.Type == SalesTasks.FUA.name()
                    || parentTask.Type == SalesTasks.FUP.name()
                    || parentTask.Type == SalesTasks.UCC.name())) {

                if (parentTask.IsClosed__c)
                    taskClosedList.add(parentTask); else
                        taskOpenList.add(parentTask);


            } else if (parentTask.Type == SalesTasks.SBR.name() && CurrentProgram == parentTask.Program__c) {
                brochureRequestTaskList.add(parentTask);
            } else if (parentTask.Type == SalesTasks.SPQ.name()) {
                priceQuoteTaskList.add(parentTask);
            }


        }
        if (taskClosedList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.CLOSEDCALL.name(), taskClosedList);
        }
        if (taskOpenList.size() > 0) {

            currentParentTaskMap.put(SalesTasks.OPENCALL.name(), taskOpenList);
        }
        if (brochureRequestTaskList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.SBR.name(), brochureRequestTaskList);
        }
        if (priceQuoteTaskList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.SPQ.name(), priceQuoteTaskList);
        }
        return currentParentTaskMap;
    }

    //This will return an List to upsert based on rules and condition
    public static Map<String, Task> saveActivityDataToTask(
            Map<String, List<Task>> currentTasksOfParentMap,
            Event parentActivity) {
        Map<String, Task> upsertTasksRecordList = new Map<String, Task>();
        if (taskSettingsMap.containsKey(parentActivity.Type)) {

            TaskSetting__mdt objCurrentType = taskSettingsMap.get(parentActivity.Type);
            Map<String, String[]> saveTypeMap = returnTaskToSave(objCurrentType);
            upsertTasksRecordList = finalTaskListToSave
                    (saveTypeMap,
                            currentTasksOfParentMap,
                            parentActivity, null);
        }
        return upsertTasksRecordList;
    }

    //Here we get array of task types to save for perticular request(Event/Task)
    public static Map<String, String[]> returnTaskToSave(TaskSetting__mdt objCurrentType) {
        Map<String, String[]> callTypeMap = new Map<String, String[]>();
        String taskSettingsValues = '';
        if (!String.isBlank(objCurrentType.CreateCallType__c)) {
            taskSettingsValues = objCurrentType.CreateCallType__c;
            //Add is Active Condition
            String[] createCallTypeArray = SFLangUtil.splitString(taskSettingsValues, '|');
            callTypeMap.put(SaveType.INSERTDATA.name(), createCallTypeArray);
        }
        if (!String.isBlank(objCurrentType.UpdateCallType__c)) {
            taskSettingsValues = objCurrentType.UpdateCallType__c;
            String[] updateCallTypeArray = SFLangUtil.splitString(taskSettingsValues, '|');
            callTypeMap.put(SaveType.UPDATEDATA.name(), updateCallTypeArray);
        }
        if (!String.isBlank(objCurrentType.ForClosedCallTypes__c)) {
            taskSettingsValues = objCurrentType.ForClosedCallTypes__c;
            String[] closedCallTypeArray = SFLangUtil.splitString(taskSettingsValues, '|');
            callTypeMap.put(SaveType.CLOSEDINSERT.name(), closedCallTypeArray);
        }
        return callTypeMap;
    }

    //This Method returns list to tasks to be saved for perticular request
    public static Map<String, Task> finalTaskListToSave(Map<String, String[]> typeToSave,
            Map<String, List<Task>> currentParentTaskMap,
            Event requestEventObject, Task requestTaskObj) {

        Boolean isClosedOpportunity = true;
        String currentRequestProgram = requestEventObject != null ? requestEventObject.Program__c : requestTaskObj.Program__c;

        Map<String, Task> taskList = new Map<String, Task>();
        if (typeToSave.containsKey(SaveType.INSERTDATA.name())) {
            String[] insertTypeCalls = typeToSave.get(SaveType.INSERTDATA.name());
            Boolean hasCallTask = false;
            Boolean canCreateTask = false;
            Task newTask = new Task();

            for (String typeOfTask : insertTypeCalls) {
                if (taskSettingsMap.containsKey(typeOfTask.trim())) {
                    TaskSetting__mdt objTaskSettingMap = taskSettingsMap.get(typeOfTask);
                    if (objTaskSettingMap.IsTaskPerCustomer__c) {
                        if (currentParentTaskMap != null
                                && currentParentTaskMap.size() > 0
                                && currentParentTaskMap.containsKey(SalesTasks.OPENCALL.name())
                                && typeOfTask != SalesTasks.MCR.name()) {
                            //as this will be call type we will
                            //  get only one call type task per customer
                            hasCallTask = true;
                            isClosedOpportunity = false;
                        } else if (currentParentTaskMap != null
                                && currentParentTaskMap.size() > 0
                                && !currentParentTaskMap.containsKey(SalesTasks.MCR.name())
                                ) {

                            hasCallTask = false;
                            isClosedOpportunity = false;
                        }
                        if (!hasCallTask) {
                            isClosedOpportunity = false;
                            if (!String.isBlank(objTaskSettingMap.RuleForActivity__c)) {
                                newTask.type = typeOfTask;
                                canCreateTask = canCreateCallTask();
                                system.debug('canCreateTask>>>>'+canCreateTask);
                                //Create Task Directly TCC/UCC/FUP/FUA
                            } else
                                    canCreateTask = true;
                        }
                    } else {
                        isClosedOpportunity = false;
                        if (!String.isBlank(objTaskSettingMap.RuleForActivity__c)
                                || !String.isBlank(objTaskSettingMap.RuleForTask__c)) {
                            //Here we get SBR Tasks
                            canCreateTask = canSendBrochure(currentParentTaskMap.get(typeOfTask), currentRequestProgram, leadrecord, oppRecord);
                        }
                        //SPQ Task Comes here
                        else {
                            canCreateTask = true;
                        }


                    }
                    newTask.type = typeOfTask;
                    Id id = (leadrecord != null ? requestEventObject.WhoId : requestEventObject.WhatId);
                    String program = requestEventObject.Program__c;
                    String type = typeOfTask;
                    if (canCreateTask && !tasksForActivitiesList.containsKey(id + '|' + type + '|' + program)) {
                        Task task = craeteTaskObject(requestEventObject, newTask, objTaskSettingMap.RecordTypeLabel__c);
                        taskList.put(leadRecord + '|' + task.Type + '|' + requestEventObject.Program__c, task);
                    }
                }
            }
        }

        if (typeToSave.containsKey(SaveType.UPDATEDATA.name())) {
            String[] updateTypeCalls = typeToSave.get(SaveType.UPDATEDATA.name());
            String tasktype = '';
            String currentParentProgram;
            List<Task> closedTaskList;
            Task currentActiveTaskToUpdate;
            for (String type : updateTypeCalls) {
                if (taskSettingsMap.containsKey(type.trim())) {
                    TaskSetting__mdt objTaskSettingMap = taskSettingsMap.get(type);
                    boolean canUpdateTask = false;
                    if (currentParentTaskMap.containsKey(SalesTasks.OPENCALL.name())) {
                        //closedTaskList=new List<Task>();
                        //As Per rules update
                        canUpdateTask = true;
                        tasktype = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0].type;
                        isClosedOpportunity = false;
                        currentActiveTaskToUpdate = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0];
                        currentParentProgram = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0].Program__c;

                        if (canUpdateTask) {
                            isClosedOpportunity = false;

                            //Based on parent program we need to update the due date here
                            Task objUpdateTask;
                            if (currentParentTaskMap.containsKey(SalesTasks.OPENCALL.name()))
                                closedTaskList = currentParentTaskMap.get(SalesTasks.OPENCALL.name());

                            // if (requestEventObject != null && (currentParentProgram == requestEventObject.Program__c))
                            if (requestEventObject != null)
                                objUpdateTask = updateTaskRulesForActivity(closedTaskList, currentActiveTaskToUpdate);


                            if (requestEventObject != null) {
                                objUpdateTask = updateIsExpressCallOnSystemCallTask(closedTaskList,currentActiveTaskToUpdate, requestEventObject.IsExpressCall__c);
                            }

                            if (objUpdateTask != null)
                                taskList.put(objUpdateTask.WhatId + '|' + objUpdateTask.Type + '|' + objUpdateTask.Program__c, objUpdateTask);

                            break;
                        }
                    }
                }
            }
        }
        //This is  for closed opportunity Need to look into it
        if (typeToSave.containsKey(SaveType.CLOSEDINSERT.name()) && isClosedOpportunity) {
            String[] closedInsertTypeCalls = typeToSave.get(SaveType.UPDATEDATA.name());
            for (String type : closedInsertTypeCalls) {
                if (taskSettingsMap.containsKey(type.trim())) {
                    TaskSetting__mdt objTaskSettingMap = taskSettingsMap.get(type);
                    if (objTaskSettingMap.IsTaskPerCustomer__c) {
                        String[] groupItems = SFLangUtil.splitString(objTaskSettingMap.TaskGroup__c, '|');
                        boolean canInsertTask = false;
                        for (String Item : groupItems) {
                            if (currentParentTaskMap.containsKey(Item)) {
                                for (Task currentTask : currentParentTaskMap.get(Item)) {

                                    if (!currentTask.IsClosed__c) {
                                        canInsertTask = true;
                                        break;
                                    }

                                }
                                if (canInsertTask) {
                                    //Create Task FUP
                                }
                            }
                        }
                    }
                }
            }
        }


        return taskList;
    }

    //For Customer activities we need to updates the call tasks which are alrteady there that is being checked here
    public static Task updateTaskRulesForActivity(List<Task> closedTaskList, Task tasktoUpdate) {

        if (closedTaskList != null && closedTaskList.size() > 0) {
            for (Task objtask : closedTaskList) {
                if (date.today() == SFLangUtil.ConvertDateTimeTodate(objtask.FollowUpDate__c)) {
                    return tasktoUpdate;
                }
            }
            //we will update this only if the Sales user has not spoken to customer today.
            if (tasktoUpdate != null)

                tasktoUpdate.FollowUpDate__c = Datetime.now();
                tasktoUpdate.ActivityDate = Datetime.now().Date();
            // tasktoUpdate.IsExpressCall__c = isExpressCall;

        }


        return tasktoUpdate;
    }
    //update IsExpressCal Flag on Task
    public static task updateIsExpressCallOnSystemCallTask(List<Task> listOfCallTask , Task tasktoUpdate,boolean isExpressCall){
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;

        listOfCallTask = [select id,type,recordtype.developername from task where id in:listOfCallTask AND Type = :TasksHelper.CALL AND RecordTypeId = :systemCallTaskRecordTypeId];

        if (listOfCallTask != null && isExpressCall) {

            tasktoUpdate.IsExpressCall__c = isExpressCall ;

        }

        //update listOfCallTask[0];

        return tasktoUpdate;
    }

    //Under Construction
    public static void createTaskFromTask(Id parentId, Task salesActionTask) {

    }

    //Partially done only mapping of event to task is done but stiil we need to do task to task mapping
    public static Task craeteTaskObject(Event eventObj, Task objTask, String recordTypeLabel) {
        system.debug('recordTypeLabel>>>>>'+recordTypeLabel);
        system.debug('recordTypeid>>>>>'+Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId());
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
        system.debug('recordTypeid2>>>>>'+Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId());
        Task newTask = new Task();
        String taskSubject = '';

        if (eventObj != null) {
            newTask.WhoId = eventObj.WhoId;
            newTask.WhatId = eventObj.WhatId;
            newTask.Type = (objTask.Type == SalesTasks.TCC.Name()) ? SalesTasks.Call.Name() : objTask.Type;
            newTask.Program__c = eventObj.Program__c;
            newTask.FollowUpDate__c = Datetime.now();
            system.debug('followup>>>>'+ newTask.FollowUpDate__c );
            newTask.ActivityDate = Datetime.now().Date();
            system.debug('ActivityDate>>>>'+ newTask.ActivityDate );
            newTask.ActivityDateTime__c = Datetime.now();
            newTask.EventId__c = eventObj.Id;
            newTask.recordtypeid = recordTypeId;
            newTask.Subject= taskSettingsMap.get(objTask.Type).TaskSubject__c+' - '+newTask.Program__c ;
            mapTaskFieldsBasedonType(newTask,eventObj, objTask);
        } else {
            newTask = objTask;
        }

        return newTask;
    }

    //SBR Complete rules are being verified here
    public static Boolean canSendBrochure(List<Task> taskList, String currentRequestProgram, Lead leadRecord, opportunity oppRecord) {
        boolean canSendBR = false;
        String temp = '';
        //canSendBR = oppRecord != null ? (oppRecord.Account.HasAddress__c && oppRecord.SendBrochure__c) : false;
        canSendBR = oppRecord != null ? ((oppRecord.Account.HasAddress__c && oppRecord.SendBrochure__c && (oppRecord.CreationMethod__c!=system.label.EFCOM && oppRecord.CreationMethod__c!=system.label.ExcelImport))|| (oppRecord.Account.HasAddress__c && (!oppRecord.SendBrochure__c) && (oppRecord.CreationMethod__c==system.label.EFCOM || oppRecord.CreationMethod__c==system.label.ExcelImport)))  : false;
        system.debug('canSendBR>>>'+canSendBR);
        if (!canSendBR) {
            return canSendBR;
        }
        Map<String, MarketProgramLevelSetting__c> marketProgramSetting = MarketProgramLevelSetting__c.getAll();
        If (taskList != null && taskList.size() > 0) {
            for (Task taskRecord : taskList) {
                //temp=taskRecord.market__c + '_' + taskRecord.program__c;
                if (marketProgramSetting.containsKey(temp)) {

                    if (taskRecord.IsClosed__c && (marketProgramSetting.get(temp).AutoCloseBrochureRequest__c == null
                            || marketProgramSetting.get(temp).AutoCloseBrochureRequest__c == 0
                            || (marketProgramSetting.get(temp).AutoCloseBrochureRequest__c
                            <
                            (SFLangUtil.ConvertDateTimeTodate(taskRecord.CloseDate__c).daysBetween(date.today()))))
                            && !marketProgramSetting.get(temp).DoNotSendBrochure__c) {
                        system.debug('inautoclose>>>');
                        canSendBR = true;
                        break;
                    } else if (taskRecord.program__c == currentRequestProgram && !taskRecord.IsClosed__c) {
                        canSendBR = false;
                        break;
                    } else if (!marketProgramSetting.get(temp).DoNotSendBrochure__c) {
                        canSendBR = true;
                        break;
                    }


                }

                else if (taskRecord.Program__c == currentRequestProgram && !taskRecord.IsClosed__c) {
                    canSendBR = false;
                    break;
                }

            }
        } else {
            //temp=eventRecord.market__c + '_' + eventRecord.program__c;
            if (marketProgramSetting.containsKey(temp)) {
                if (marketProgramSetting.get(temp).DoNotSendBrochure__c) {
                    canSendBR = false;
                }
            }

        }
        return canSendBR;
    }
    //Create call task only if below condition are verified
    public static Boolean canCreateCallTask() {
        //return (oppRecord != null) ? ((!oppRecord.Account.PersonDoNotCall) )  : false;
        // system.debug('oppRecord.HasSystemCallTask__c>>>>>>>'+oppRecord.HasSystemCallTask__c);
        return (oppRecord != null) ? (!oppRecord.Account.PersonDoNotCall && !oppRecord.HasSystemCallTask__c ) : false;
    }

    //Here we check weather we have already task for perticular request which we wiil be saving
    // we will be avoiding creating duplicate task for same request
    public static Boolean isTheTaskAlreadyInQue(Id parentId, String program, String taskType) {
        Boolean hasTaskToCreate = false;
        id whoIdOrWhatId;
        for (Task objTask : tasksForActivitiesList.values()) {
            whoIdOrWhatId = ((leadrecord != null) ? objTask.WhoId : objTask.WhatId);
            if (whoIdOrWhatId == parentId && taskType != SalesTasks.SBR.name()) {
                hasTaskToCreate = true;
                break;
            } else if (whoIdOrWhatId == parentId
                    && objTask.program__c == program
                    && taskType == SalesTasks.SBR.name()) {
                hasTaskToCreate = true;
                break;
            }
        }
        return hasTaskToCreate;
    }

    //
    public static Boolean closeTasksOnParent(Id parentId) {
        try {
            List<Task> tasksToBeClosed = new List<Task>();
            if (String.valueOf(parentId).substring(0, 3) == '006') {
                tasksToBeClosed = [Select Id,Status FROM Task WHERE WhatId = :parentId AND (Status != 'Deferred' OR Status != 'Completed')];
                for (Task task : tasksToBeClosed) {
                    task.Status = 'Deferred';
                }
                update tasksToBeClosed;
            }
            return true;
        } catch (exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'Tasks', 'closeTasksOnParent', parentId);
            return false;
        }
    }

    /**
    * @author Arkadiusz Celej
    * @date 29.11.2017
    * @description Method updates parent records based on changed tasks
    * @version 1.0
    * */
    public static String refreshTaskSubject(String currentSubject, String program){
        String newSubject = '';
        String[] splitSubject = currentSubject != NULL ? currentSubject.split('-') : new String[]{};
        if (splitSubject.size() > 0) {
            newSubject = splitSubject[0].trim() + ' - ' + program;
        }
        return newSubject;
    }

    public static void updateParents(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        updateLeads((Map<Id, Task>) newItems);
        updateOpportunities((Map<Id, Task>) newItems, (Map<Id, Task>) oldItems);
    }

    private static void updateLeads(Map<Id, Task> tasksByIds) {
        Set<Id> parentLeadIds = new Set<Id>();
        Map<Id, Task> leadTasks = new Map<Id, Task>();
        for (Task t : tasksByIds.values()) {
            if (t.WhoId != NULL && t.WhoId.getSobjectType() == Schema.Lead.SObjectType) {
                parentLeadIds.add(t.WhoId);
                leadTasks.put(t.Id, t);
            }
        }

        if (parentLeadIds.size() > 0) {
            processLeads(parentLeadIds, leadTasks);
        }
    }

    private static void processLeads(Set<Id> idsToProcess, Map<Id, Task> updatedTasksByIds) {
        Map<Id, Lead> processedLeadsByIds = new Map<Id, Lead>();
        List<Lead> leadsToProcess = LeadsSelector.getLeadsByIdsWithTasks(new List<Id>(idsToProcess));
        Map<Id, Map<Id, Task>> tasksByLeadIds = new Map<Id, Map<Id, Task>>();
        for (Lead lead : leadsToProcess) {
            for (Task leadTask : lead.Tasks) {
                if (!tasksByLeadIds.containsKey(lead.Id)) {
                    tasksByLeadIds.put(lead.Id, new Map<Id, Task>());
                }
                tasksByLeadIds.get(lead.Id).put(leadTask.Id, leadTask);
            }
        }

        for (Task t : updatedTasksByIds.values()) {
            if (!tasksByLeadIds.containsKey(t.WhoId)) {
                tasksByLeadIds.put(t.WhoId, new Map<Id, Task>());
            }
            tasksByLeadIds.get(t.WhoId).put(t.Id, t);
        }

        for (Id leadId : tasksByLeadIds.keySet()) {
            Lead currentLead;
            if (processedLeadsByIds.containsKey(leadId)) {
                currentLead = processedLeadsByIds.get(leadId);
            } else {
                currentLead = new Lead(Id = leadId);
            }

            updatePendingToDoList(currentLead, tasksByLeadIds.get(leadId).values());
            updateNumberOfCompletedCalls(currentLead, tasksByLeadIds.get(leadId).values());

            processedLeadsByIds.put(leadId, currentLead);
        }

        if (processedLeadsByIds.values().size() > 0) {
            update processedLeadsByIds.values();
        }
    }

    private static void updateOpportunities(Map<Id, Task> tasksByIds, Map<Id, Task> oldTasksByIds) {
        Set<Id> parentOppIds = new Set<Id>();
        Map<Id, Task> updatedOpportunityTasks = new Map<Id, Task>();
        for (Task t : tasksByIds.values()) {
            if (t.WhatId != NULL && t.WhatId.getSobjectType() == Schema.Opportunity.SObjectType) {
                parentOppIds.add(t.WhatId);
                updatedOpportunityTasks.put(t.Id, t);
            }
        }

        if (parentOppIds.size() > 0) {
            Map<Id,Opportunity> opportunitiesToProcess = new Map<Id, Opportunity>(OpportunitiesSelector.getOpportunitiesByIdsWithTasks(new List<Id>(parentOppIds)));
            summarizeOpportunityFields(opportunitiesToProcess, updatedOpportunityTasks);
            //only for new tasks
            if(oldTasksByIds == NULL) {
                updateOpportunityFields(opportunitiesToProcess, updatedOpportunityTasks);
            }
            update opportunitiesToProcess.values();
        }
    }

    private static void summarizeOpportunityFields(Map<Id,Opportunity> opportunitiesToProcess, Map<Id, Task> updatedTasksByIds){
        Map<Id, Map<Id, Task>> tasksByOpportunityIds = new Map<Id, Map<Id, Task>>();
        for (Opportunity opp : opportunitiesToProcess.values()) {
            if (opp.Tasks.size() > 0) {
                for (Task oppTask : opp.Tasks) {
                    if (!tasksByOpportunityIds.containsKey(opp.Id)) {
                        tasksByOpportunityIds.put(opp.Id, new Map<Id, Task>());
                    }
                    tasksByOpportunityIds.get(opp.Id).put(oppTask.Id, oppTask);
                }
            }
        }

        for (Task t : updatedTasksByIds.values()) {
            if (!tasksByOpportunityIds.containsKey(t.WhatId)) {
                tasksByOpportunityIds.put(t.WhatId, new Map<Id, Task>());
            }
            tasksByOpportunityIds.get(t.WhatId).put(t.Id, t);
        }

        //summarize opportunity fields based on all opportunity tasks
        for (Id oppId : tasksByOpportunityIds.keySet()) {
            Opportunity currentOpportunity = opportunitiesToProcess.get(oppId);

            updatePendingToDoList       (currentOpportunity, tasksByOpportunityIds.get(oppId).values());
            updateBorchuresToSentList   (currentOpportunity, tasksByOpportunityIds.get(oppId).values());
            updateSentBrochuresList     (currentOpportunity, tasksByOpportunityIds.get(oppId).values());
            updateNumberOfCompletedCalls(currentOpportunity, tasksByOpportunityIds.get(oppId).values());
            updateSendBrochureDueDateTime(currentOpportunity, tasksByOpportunityIds.get(oppId).values());
        }
    }

    private static void updateOpportunityFields(Map<Id,Opportunity> opportunitiesToProcessByIds, Map<Id, Task> updatedTasksByIds){

        Map<Id, Map<Id, Task>> tasksByOpportunityIds = new Map<Id, Map<Id, Task>>();
        for (Task t : updatedTasksByIds.values()) {
            if (!tasksByOpportunityIds.containsKey(t.WhatId)) {
                tasksByOpportunityIds.put(t.WhatId, new Map<Id, Task>());
            }
            tasksByOpportunityIds.get(t.WhatId).put(t.Id, t);
        }

        for (Task t : updatedTasksByIds.values()) {
            if (!tasksByOpportunityIds.containsKey(t.WhatId)) {
                tasksByOpportunityIds.put(t.WhatId, new Map<Id, Task>());
            }
            tasksByOpportunityIds.get(t.WhatId).put(t.Id, t);
        }
        for (Id oppId : tasksByOpportunityIds.keySet()) {
            Opportunity currentOpportunity = opportunitiesToProcessByIds.get(oppId);
            updateNumberOfUnreachedCalls(currentOpportunity, tasksByOpportunityIds.get(oppId).values());
        }
    }

    private static void updateNumberOfUnreachedCalls(Opportunity toUpdate, Task[] tasks) {
        Integer numberOfUnreachedCalls = toUpdate.NumberOfUnreachedCalls__c != NULL ? toUpdate.NumberOfUnreachedCalls__c.intValue() : 0;
        for (Task t : tasks) {
            if (isTaskRecordType(CALL_TASK_DEVELOPER_NAME, t.RecordTypeId) && t.IsClosed) {
                if(t.IsTaskCallReached__c){
                    numberOfUnreachedCalls = 0;
                }else if(t.SalesAction__c == Label.CallNotReached){
                    numberOfUnreachedCalls++;
                }
            }
        }
        toUpdate.NumberOfUnreachedCalls__c = numberOfUnreachedCalls;
    }

    private static void updateSendBrochureDueDateTime(Opportunity opportunity, Task[] opportunityTasks){
        Datetime minDateTime = NULL;
        for(Task t : opportunityTasks){
            if(isTaskRecordType(SBR_TASK_DEVELOPER_NAME, t.RecordTypeId) && t.IsClosed == false){
                if(minDateTime == NULL || (t.ActivityDate != NULL && t.ActivityDate < minDateTime)){
                    minDateTime = t.ActivityDate;
                }
            }
        }
        opportunity.SendBrochureDueDateTime__c = minDateTime;
    }

    private static void updateNumberOfCompletedCalls(SObject toUpdate, Task[] tasks) {
        Integer numberOfCompletedCalls = 0;
        for (Task t : tasks) {
            if (isTaskRecordType(CALL_TASK_DEVELOPER_NAME, t.RecordTypeId) && t.IsClosed) {
                numberOfCompletedCalls++;
            }
        }
        toUpdate.put('NumberOfCalls__c',numberOfCompletedCalls);
    }

    private static void updatePendingToDoList(SObject toUpdate, Task[] tasks) {
        Set<String> pendingToDo = new Set<String>();
        for (Task t : tasks) {
            if (isNotCallTypeTask(t.RecordTypeId) && !t.IsClosed && t.Type != CALL && t.Type != NULL) {
                pendingToDo.add(t.Type);
            }
        }
        toUpdate.put('PendingToDo__c', String.join(new List<String>(pendingToDo), SEPARATOR));
    }

    private static void updateBorchuresToSentList(Opportunity opportunity, Task[] opportunityTasks) {
        Set<String> brochuresToSend = new Set<String>();
        for (Task t : opportunityTasks) {
            if (isTaskRecordType(SBR_TASK_DEVELOPER_NAME, t.RecordTypeId) && t.TaskResult__c != DO_NOT_SEND_BROCHURE && !t.IsClosed) {
                brochuresToSend.add(t.Program__c);
                if(t.IsJunior__c){
                    brochuresToSend.add('JU');
                }
                if(t.IsUp__c){
                    brochuresToSend.add('UP');
                }
                if (t.FalseBrochureProgramCodes__c != NULL) {
                    brochuresToSend.addAll(t.FalseBrochureProgramCodes__c.split(SEPARATOR));
                }
            }
        }
        opportunity.BrochuresToSend__c = String.join(new List<String>(brochuresToSend), SEPARATOR);
    }

    private static void updateSentBrochuresList(Opportunity opportunity, Task[] opportunityTasks) {
        Set<String> sentBrochures = new Set<String>();
        for (Task t : opportunityTasks) {
            if (isTaskRecordType(SBR_TASK_DEVELOPER_NAME, t.RecordTypeId) && t.TaskResult__c != DO_NOT_SEND_BROCHURE && t.IsClosed && t.TaskResult__c == SENT_BROCHURE) {
                sentBrochures.add(t.Program__c);
                if(t.IsJunior__c){
                    sentBrochures.add('JU');
                }
                if(t.IsUp__c){
                    sentBrochures.add('UP');
                }
                if (t.FalseBrochureProgramCodes__c != NULL) {
                    sentBrochures.addAll(t.FalseBrochureProgramCodes__c.split(SEPARATOR));
                }
            }
        }
        opportunity.SentBrochures__c = String.join(new List<String>(sentBrochures), SEPARATOR);
    }

    private static Boolean isNotCallTypeTask(Id recordTypeId) {
        return isTaskRecordType(SBR_TASK_DEVELOPER_NAME, recordTypeId)
                || isTaskRecordType(MCR_TASK_DEVELOPER_NAME, recordTypeId)
                || isTaskRecordType(SPQ_TASK_DEVELOPER_NAME, recordTypeId);
    }

    private static Boolean isTaskRecordType(String recordTypeDeveloperName, Id recordTypeId) {
        return RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).containsKey(recordTypeDeveloperName)
                && RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(recordTypeDeveloperName).Id == recordTypeId;
    }

    public static void setDefaultLetterAndLabelOnOpportunities(Map<Id, Task> tasksByIds){
        Id sbrRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(SBR_TASK_DEVELOPER_NAME).Id;
        Set<Id> parentOppIdsWithSBRTask = new Set<Id>();
        for (Task t : tasksByIds.values()) {
            if (t.WhatId != NULL && t.WhatId.getSobjectType() == Schema.Opportunity.SObjectType && t.RecordTypeId == sbrRecordTypeId) {
                parentOppIdsWithSBRTask.add(t.WhatId);
            }
        }

        if (parentOppIdsWithSBRTask.size() > 0) {
            List<Opportunity> toUpdate = new List<Opportunity>();
            Map<Id, Date> accountBirthdatesByOppIds = new Map<Id, Date>();
            for(Opportunity opp : OpportunitiesSelector.getOpportunitiesByIdsWithTasks(new List<Id>(parentOppIdsWithSBRTask))){
                toUpdate.add(opp);
                accountBirthdatesByOppIds.put(opp.Id, opp.Account.PersonBirthdate);
            }
            List<Opportunity> changedOpportunities = OpportunitiesHelper.setTemplatesForOpportunities(toUpdate, accountBirthdatesByOppIds);
            if(changedOpportunities.size() > 0){
                update changedOpportunities;
            }
        }
    }

    //accepts a list of events and returns ids of records that are related to opportunity
    public static List<Id> filterEventsRelatedToOppotunity(List<Event> lstEvents){
        List<Id> lstEventIds = new List<Id>();
        for (event eventRecord : lstEvents) {
            String oppId = String.valueof(eventRecord.WhatId);
            if(oppId != null && oppId != ''){
                system.debug('inside if opp');
                if (oppId.startswith( '006')){
                    system.debug('inside if opp 006');
                    lstEventIds.add(eventRecord.WhatId);
                }
            }
        }
        return lstEventIds;
    }

    private  static Task mapTaskFieldsBasedonType(Task newTask, Event eventObj, Task objTask){

        if(newTask == null||eventObj == NULL){
            return null;
        }
        if (objTask.Type == SalesTasks.TCC.Name()) {
            newTask.NextCallType__c = objTask.Type;
        }
        if(newTask.Type == SalesTasks.SBR.Name()) {
            newTask.FalseBrochureProgramCodes__c = eventObj.FalseBrochureProgramCodes__c;
            newTask.IsUp__c = eventObj.IsUp__c;
            newTask.IsJunior__c = eventObj.IsJunior__c;
        }
        else if(newTask.Type == SalesTasks.MCR.Name()) {
            newTask.Course__c = eventObj.Course__c;
            newTask.DestinationCode__c = eventObj.DestinationCode__c;
            newTask.StartWhen__c = eventObj.StartWhen__c;
            newTask.ReservedPrice__c = eventObj.ReservedPrice__c;
            //mapping WebOnlinePaymentTXLog_id instead of IsPaidOnline(formula field). Because it gets updated to 1, if WebOnlinePaymentTXLog_id > 0 otherwise 0.
            newTask.WebOnlinePaymentTXLogId__c = eventObj.WebOnlinePaymentTXLogId__c;
            newTask.Duration__c = eventObj.Duration__c;
            newTask.Accommodation__c = eventObj.Accommodation__c;
            newTask.ReservedCoursePrice__c = eventObj.ReservedCoursePrice__c;
            newTask.ReservedArticles__c = eventObj.ReservedArticles__c;
        }
        else if(newTask.Type == SalesTasks.SPQ.Name()) {
            newTask.DestinationCode__c = eventObj.DestinationCode__c;
            newTask.Course__c = eventObj.Course__c;
            newTask.StartWhen__c = eventObj.StartWhen__c;
            newTask.Comments__c = eventObj.Comments__c;
            newTask.Duration__c = eventObj.Duration__c;
            newTask.Accommodation__c = eventObj.Accommodation__c;
        }
        else if(newTask.Type == SalesTasks.Call.Name()) {
            newTask.IsExpressCall__c = eventObj.IsExpressCall__c;
        }
        return newTask;
    }
}