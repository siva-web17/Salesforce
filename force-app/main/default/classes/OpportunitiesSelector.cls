/**************************************************************************************
Apex Class Name    : OpportunitiesSelector
Version            : 1.0
Created Date       : Apr 25 2017
Function           : All SOQL queries related Opportunity
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  04/25/2017              Original Version
 *************************************************************************************/
public class OpportunitiesSelector {

    public static List<OpportunityShare> getOpportunityShareRecDetails(Map<Id, ID> OpportunityShareDeleteMap) {

        return [
                select Id
                from OpportunityShare
                where UserOrGroupId IN:OpportunityShareDeleteMap.values()
                AND OpportunityId IN:OpportunityShareDeleteMap.keyset()
        ];
    }

    public static List<Account> getAccountDetails(List<ID> accIDList) {
        return [SELECT ID FROM ACCOUNT WHERE ID IN:accIDList];
    }

    /*
    * @param Set<String> oppIds 
    * @return Returns list of opportunities based on the oppIds
    * */
    
    public static List<Opportunity> getOpportunitiesOnId(Set<Id> oppIds) {
        List<Opportunity> opportunities= new List<Opportunity>();
        if (oppIds.size()>0)
        {
            opportunities = [SELECT Id, Name, TimeOutDate__c,FollowupDatetime__c, AccountId, StageName,Program__c,
                                    CloseDate,LikelihoodToBook__c,HearAboutUs__c,Destinations__c,PreferredDuration__c,WhenYear__c,WhenMonth__c,
                                    FirstContactDateTime__c,IsActive__c,TFBypassStageValidation__c,NumberOfUnreachedCalls__c 
                               FROM Opportunity
                              WHERE Id IN :oppIds];
        }
        return opportunities;
    }

    /*
    * @param Set<String> oppNames 
    * @return Returns list of opportunities based on the Name
    * */
    public static List<Opportunity> getOpportunitiesOnName(Set<String> oppNames) {
        return [
                SELECT id, 
                       Name
                  FROM Opportunity
                 WHERE Name = :oppNames
        ];
    }

    public static List<Opportunity> getOpportunityOnId_Optm(Set<Id> oppId) {
        return [
                select id, Name, FollowupDatetime__c, AccountId, StageName,Program__c
                from Opportunity
                where Id in :oppId
        ];
    }

    public static List<Opportunity> getOpportunitiesOnAccountId(Id accId) {
        return [
                select id,Name, FollowupDatetime__c,AccountId,StageName,Program__c
                from Opportunity
                where AccountId = :accId
                order by FollowupDateTime__c ASC
        ];
    }

    public static Opportunity getLatestOpportunityOnAccountId(Id accId) {
        List<Opportunity> opportunities = null;
        Opportunity latestOpportunity = null;
        try {
            opportunities = [SELECT Id,StageName,Name,AccountId,CloseDate FROM Opportunity WHERE AccountId = :accId AND IsDeleted = false ORDER BY CreatedDate desc];
            if (opportunities != null && opportunities.size() > 0) {
                latestOpportunity = opportunities[0];
            }
        } catch (Exception ex) {
        }
        return latestOpportunity;
    }

    public static List<Opportunity> getLatestOpportunityOnAccountId_Optm(Set<Id> accId) {
        List<Opportunity> latestOpportunity = [SELECT Id,StageName,Name,AccountId,CloseDate FROM Opportunity WHERE AccountId = :accId AND IsDeleted = false ORDER BY CreatedDate desc];
        return latestOpportunity;
    }
    public static list<opportunity> getLstOpportunityOrderByCrtdDateASC(list<opportunity> mergedOpps) {

        list<opportunity> opportunityOrderByCreatedDateASC = [select id,FollowupDateTime__c,stageName from opportunity where id in:mergedOpps ORDER BY createddate ASC];
        return opportunityOrderByCreatedDateASC;
    }
    public static list<opportunity> getLstOfFollowupOpportunity(list<opportunity> mergedOpps) {
        list<opportunity> lstOfOpportunity = [select id,FollowupDateTime__c,stageName, SendBrochure__c from opportunity where id in:mergedOpps AND stageName = 'FOLLOWUP' ORDER BY FollowupDateTime__c ASC];
        return lstOfOpportunity;

    }
    public static list<opportunity> getlstOfOpportunityByCreatedDateDesc(account masterAccount) {
        list<opportunity> lstOfOpportunity = [
                select id, Name, FollowupDateTime__c,AccountId,StageName,Program__c
                from Opportunity
                Where accountId = :masterAccount.id
                ORDER BY CreatedDate DESC
        ];
        return lstOfOpportunity;
    }

    public static List<Opportunity> getAllEventsAndTasksforOpportunity(List<id> opportunityIds) {
        return [
                 select id,Name,account.PersonDoNotCall,account.HasAddress__c,SendBrochure__c,CreationMethod__c,StageName, account.HasPhoneNumber__c, HasSystemCallTask__c,Program__c, (
//                        SELECT Id, WhoId, WhatId, Subject, Status,
//                                FollowUpDate__c,SalesAction__c, Program__c, MergeReason__c,Type,IsClosed__c,FalseBrochureProgramCodes__c,
//                                CloseDate__c, IsExpressCall__c,RecordType.DeveloperName
//                        FROM Tasks
//                ), (
//                        Select Id, WhoId, WhatId, Subject, OwnerId,
//                                Type, SalesAction__c, Program__c, EventId__c,
//                                IsExpressCall__c, ProcessedforTaskcreation__c,FalseBrochureProgramCodes__c, RecordType.DeveloperName
//                        FROM Events
//                        where ProcessedforTaskcreation__c = false
                        SELECT Id, WhoId, WhatId, Subject, Status,
                                FollowUpDate__c,SalesAction__c, Program__c, MergeReason__c,Type,IsClosed__c,FalseBrochureProgramCodes__c,WebOnlinePaymentTXLogId__c,
                                CloseDate__c, IsExpressCall__c,RecordType.DeveloperName,IsUp__c, IsJunior__c, Course__c, DestinationCode__c, StartWhen__c,
                                ReservedPrice__c, IsPaidOnline__c, Duration__c, Accommodation__c, ReservedCoursePrice__c, ReservedArticles__c, Comments__c
                        FROM Tasks
                ), (
                        Select Id, WhoId, WhatId, Subject, OwnerId,
                                Type, SalesAction__c, Program__c, EventId__c,
                                IsExpressCall__c, ProcessedforTaskcreation__c,FalseBrochureProgramCodes__c, RecordType.DeveloperName,IsUp__c, IsJunior__c, Course__c,
                                DestinationCode__c,StartWhen__c, ReservedPrice__c, IsPaidOnline__c, Duration__c, Accommodation__c,ReservedCoursePrice__c, ReservedArticles__c,
                                Comments__c,WebOnlinePaymentTXLogId__c

                        FROM Events
                        where ProcessedforTaskcreation__c = false
                )
                from Opportunity
                where id in :opportunityIds
        ];
    }

    public static Map<Id, Opportunity> getopportunityMap(List<Id> parentId) {

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
                SELECT Id
                        , Name,account.PersonDoNotCall,account.HasAddress__c,account.HasPhoneNumber__c,Program__c,Market__c,Product__c,owner.Id
                FROM Opportunity
                WHERE Id in :parentId
        ]);
        return opportunityMap;

    }

    //This method used to get the active opportunity
    public static List<Opportunity> dupeCheckOpportunities(Account duplicateAccount) {
        return [
                Select id,StageName,CloseDate,Program__c,TimeOutDate__c,FirstContactDateTime__c
                from Opportunity
                Where AccountId = :duplicateAccount.id
                /**and IsPrimary__c = TRUE**/
                and isActive__c = TRUE
        ];
    }

    public static Opportunity getOpportunityRecord(Id recordId) {
        return [Select Id, AccountId, Account.PersonContactId, CampaignId, Program__c, Market__c
                from Opportunity
                where Id = :recordId
                LIMIT 1];
    }

    public static String getOpportunityStageName(Opportunity opportunityRecord) {
        String previousOpportunityStageName;
        for (OpportunityHistory oppHistory : [Select id,opportunityid,StageName from OpportunityHistory where opportunityid = :opportunityRecord.id]) {
            if (oppHistory.StageName != Label.salesclosed && previousOpportunityStageName == null || previousOpportunityStageName == '') {
                previousOpportunityStageName = oppHistory.StageName;
            }
        }
        system.debug('I am here'+opportunityRecord.FirstContactDateTime__c +'previousstage'+previousOpportunityStageName);
        if(previousOpportunityStageName==label.OpportunityStageToContact && opportunityRecord.FirstContactDateTime__c!=null){
           system.debug('I am here');
            previousOpportunityStageName = label.OpportunityStageFollowUp;
            return previousOpportunityStageName;
        }
        return previousOpportunityStageName;
    }

    /**
    * @author Arkadiusz Celej
    * @param List<id> opportunityIds - Opportunities to select
    * @param Set<String> taskRecordTypes - Record types of tasks to select
    * @return Returns list of opportunities with Tasks filtered by provided record type developer name
    * */
    public static List<Opportunity> getOpportunitiesWithTasksByIdAndTaskRecordType(List<id> opportunityIds, Set<String> taskRecordTypes) {
        return [
                SELECT Name, BrochuresToSend__c, SentBrochures__c, NumberOfCalls__c, NumberOfUnreachedCalls__c, (
                        SELECT Id, WhatId, Program__c, IsClosed, TaskResult__c,FalseBrochureProgramCodes__c, Type, RecordType.DeveloperName
                        FROM Tasks
                        WHERE RecordType.DeveloperName IN :taskRecordTypes
                )
                FROM Opportunity
                WHERE Id in :opportunityIds
        ];
    }

    /**
    * @author Arkadiusz Celej
    * @param List<id> opportunityIds - Opportunities to select
    * @return Returns list of opportunities with Tasks
    * */
    public static List<Opportunity> getOpportunitiesByIdsWithTasks(List<id> opportunityIds) {
        return [
                SELECT Name, Letter__c, Label__c, Age__c, TemplateKey__c, BrochuresToSend__c, SentBrochures__c, HasSystemCallTask__c, Account.PersonBirthdate, NumberOfUnreachedCalls__c, (SELECT Id, ActivityDate, SalesAction__c, IsTaskCallReached__c, WhatId, Program__c, IsClosed, TaskResult__c,FalseBrochureProgramCodes__c, Type, RecordTypeId, RecordType.DeveloperName, IsJunior__c, IsUp__c FROM Tasks ORDER BY ActivityDate)
                FROM Opportunity
                WHERE Id in :opportunityIds
        ];
    }

    /**
     * @author Arkadiusz Celej
     * ver 1.0 19-Dec-2017
     * @description
     * @param opportunityIds
     *
     * @return
     */
    public static List<Opportunity> getOpportunitiesWithOpenActivities(Set<id> opportunityIds) {
        return [
                SELECT Id, (SELECT Id, OwnerId, IsTask FROM OpenActivities)
                FROM Opportunity
                WHERE Id in :opportunityIds
        ];
    }

    /**
     * @author Arkadiusz Celej
     * ver 1.0 21-Dec-2017
     * @description Returns list of opportunity records with open Task with provided record type
     *
     * @param opportunityIds Ids to select
     * @param recordTypeDeveloperName Task record type developer name
     *
     * @return List<Opportunity>
     */
    public static List<Opportunity> getOpportunitiesWithOpenTasks(Set<Id> opportunityIds, String recordTypeDeveloperName) {
        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(recordTypeDeveloperName).Id;
        return [
                SELECT
                        Id, Account.PersonBirthdate, (SELECT Id, Program__c, Subject, OwnerId FROM Tasks WHERE RecordTypeId = :recordTypeId AND IsClosed = FALSE)
                FROM Opportunity
                WHERE Id IN :opportunityIds
        ];
    }

    /**
     * @author Arkadiusz Celej
     * ver 1.0 27-Dec-2017
     * @description Returns list of lead records with open system call task
     *
     * @param opportunitiesIds Ids to select
     *
     * @return List<Opportunity>
     */
    public static List<Opportunity> getOpportunitiesWithOpenSystemCallTask(Set<Id> opportunitiesIds) {
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;
        return [
                SELECT
                        Id, Name, StageName, Product__c, Program__c, FirstContactDateTime__c,OwnerId,
                        (SELECT Id, Subject, Status, NextCallType__c, FollowUpDate__c, Program__c, Type, IsClosed__c, IsClosed,IsParentClosing__c,isexpresscall__c,RecordTypeId
                        FROM Tasks
                        WHERE Type = :TasksHelper.CALL AND RecordTypeId = :systemCallTaskRecordTypeId LIMIT 1)
                FROM Opportunity
                WHERE Id IN :opportunitiesIds
        ];
    }

    public static List<Opportunity> getOpportunitiesWithSBRTaskByAccountIds(List<Id> accountIds) {
        Id sbrRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SBR_TASK_DEVELOPER_NAME).Id;
        return [SELECT Id, Age__c, AccountId, Account.PersonBirthdate, Account.Language__c, Market__c, Program__c, Letter__c, Label__c, TemplateKey__c,
                (SELECT WhatId FROM Tasks WHERE RecordTypeId = :sbrRecordTypeId AND IsClosed <> TRUE)
            FROM Opportunity
            WHERE AccountId IN : accountIds];
    }
}