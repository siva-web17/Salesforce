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
        List<Opportunity> opportunities = new List<Opportunity>();
        if (oppIds.size() > 0) {
            opportunities = [
                    SELECT Id, Name, TimeOutDate__c,FollowupDatetime__c, AccountId, StageName,Program__c,Market__c,
                            CloseDate,LikelihoodToBook__c,HearAboutUs__c,Destinations__c,PreferredDuration__c,WhenYear__c,WhenMonth__c,
                            FirstContactDateTime__c,IsActive__c,TFBypassStageValidation__c,NumberOfUnreachedCalls__c,OtherPhone__c,HomePhone__c,Mobile__c,Account.DoNotCall__c
                    FROM Opportunity
                    WHERE Id IN :oppIds
            ];
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
                select id,Name, FollowupDatetime__c,AccountId,LastAutomationUpdateDateTime__c,TFBypassStageValidation__c,StageName,Program__c,IsActive__c,CloseMainReason__c
                from Opportunity
                where AccountId = :accId and IsActive__c = true
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

        list<opportunity> opportunityOrderByCreatedDateASC = [select id,IsActive__c,FollowupDateTime__c,stageName from opportunity where id in:mergedOpps and IsActive__c=true ORDER BY createddate ASC];
        return opportunityOrderByCreatedDateASC;
    }
    public static list<opportunity> getLstOfFollowupOpportunity(list<opportunity> mergedOpps) {
        list<opportunity> lstOfOpportunity = [select id,FollowupDateTime__c,stageName, SendBrochure__c,IsActive__c from opportunity where id in:mergedOpps and IsActive__c=true ORDER BY FollowupDateTime__c ASC];
        return lstOfOpportunity;

    }
    public static list<opportunity> getlstOfOpportunityByCreatedDateDesc(account masterAccount) {
        list<opportunity> lstOfOpportunity = [
                select id, Name, FollowupDateTime__c,AccountId,StageName,Program__c,IsActive__c
                from Opportunity
                Where accountId = :masterAccount.id AND IsActive__c = true
                ORDER BY CreatedDate DESC
        ];
        return lstOfOpportunity;
    }

    public static List<Opportunity> getAllEventsAndTasksforOpportunity(List<id> opportunityIds) {
        return [
                select id,Name,account.PersonDoNotCall,account.HasAddress__c,SendBrochure__c,CreationMethod__c,StageName, account.HasPhoneNumber__c, HasSystemCallTask__c,Program__c,Market__c,OwnerId, (
                        SELECT Id, WhoId, WhatId, Subject, Status,
                                FollowUpDate__c,SalesAction__c, Program__c, MergeReason__c,Type,IsClosed__c,FalseBrochureProgramCodes__c,WebOnlinePaymentTXLogId__c,
                                CloseDate__c, IsExpressCall__c,RecordType.DeveloperName,IsUp__c, IsJunior__c, Course__c, DestinationCode__c, StartWhen__c,
                                ReservedPrice__c, IsPaidOnline__c, Duration__c, Accommodation__c, ReservedCoursePrice__c, ReservedArticles__c, Comments__c,DepartureCity__c,Description
                        FROM Tasks
                ), (
                        Select Id, WhoId, WhatId, Subject, OwnerId,
                                Type, SalesAction__c, Program__c, EventId__c,
                                IsExpressCall__c, ProcessedforTaskcreation__c,FalseBrochureProgramCodes__c, RecordType.DeveloperName,IsUp__c, IsJunior__c, Course__c,
                                DestinationCode__c,StartWhen__c, ReservedPrice__c, IsPaidOnline__c, Duration__c, Accommodation__c,ReservedCoursePrice__c, ReservedArticles__c,
                                Comments__c,WebOnlinePaymentTXLogId__c,DepartureCity__c,Description

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
                Select id,StageName,CloseDate,Program__c,RecalculateRanking__c,TimeOutDate__c,FirstContactDateTime__c
                from Opportunity
                Where AccountId = :duplicateAccount.id
                /**and IsPrimary__c = TRUE**/
                and IsActive__c = TRUE
        ];
    }

    public static Opportunity getOpportunityRecord(Id recordId) {
        return [
                Select Id, AccountId, Account.PersonContactId, CampaignId, Program__c, Market__c
                from Opportunity
                where Id = :recordId
                LIMIT 1
        ];
    }

    public static String getOpportunityStageName(Opportunity opportunityRecord) {
        if (!Test.isRunningTest()) {
            String previousOpportunityStageName;
            for (OpportunityHistory oppHistory : [Select id,opportunityid,StageName from OpportunityHistory where opportunityid = :opportunityRecord.id]) {
                if (oppHistory.StageName != Label.salesclosed && previousOpportunityStageName == null || previousOpportunityStageName == '') {
                    previousOpportunityStageName = oppHistory.StageName;
                }
            }
            if (previousOpportunityStageName == label.OpportunityStageToContact && opportunityRecord.FirstContactDateTime__c != null) {
                previousOpportunityStageName = label.OpportunityStageFollowUp;
                return previousOpportunityStageName;
            }
            return previousOpportunityStageName;
        }
        return 'To Contact';
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
    * @author Arjun Mohan
    * ver 1.0 16-Feb-2018
    * @description Returns list of Active Opp records For Passed AcocuntId's
    *
    * @param accountIdSet Ids to select
    *
    * @return List<Opportunity>
    */
    public static Map<Id, Opportunity> getOpportunitiesforAccount(Set<Id> accountIdSet, Boolean checkActiveOpportunity) {
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Opportunity> accountIdWithOpportunityMap = new Map<Id, Opportunity>();
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.OppDetailsForAccountSyncing.getFields()) {
            query += f.getFieldPath() + ', ';
        }

        query += 'Name,AccountId,CreatedDate  from Opportunity Where AccountId in  : ' + 'accountIdSet';
        if (checkActiveOpportunity) {
            query += ' AND IsActive__c  = TRUE';
        }
        query += ' ORDER by LastModifiedDate desc';

        oppList = Database.query(query);
        for (Opportunity oppRecord : oppList) {
            accountIdWithOpportunityMap.put(oppRecord.AccountId, oppRecord);
        }
        return accountIdWithOpportunityMap;
    }


    /**
   * @author Arjun Mohan
   * ver 1.0 16-Feb-2018
   * @description Returns list of Active Opp records For Passed AcocuntId's
   *
   * @param accountIdSet Ids to select
   *
   * @return List<Opportunity>
   */
    public static Map<Id, Opportunity> getActiveOpportunitiesforPQ(Set<Id> oppIdSet) {
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Opportunity> OpportunityMap = new Map<Id, Opportunity>();
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.CreatePriceQuote.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Name,AccountId from Opportunity ';
        query += 'where IsActive__c  = TRUE and Id in  : ' + 'oppIdSet' + ' ' ;
        oppList = Database.query(query);
        for (Opportunity oppRecord : oppList) {
            OpportunityMap.put(oppRecord.Id, oppRecord);
        }
        return OpportunityMap;
    }


    /**
    * @author Arkadiusz Celej
    * @param List<id> opportunityIds - Opportunities to select
    * @return Returns list of opportunities with Tasks
    * */
    public static List<Opportunity> getOpportunitiesByIdsWithTasks(List<id> opportunityIds) {
        return [
                SELECT Name, Letter__c, OwnerId, Label__c, Age__c, TemplateKey__c, BrochuresToSend__c, SentBrochures__c, HasSystemCallTask__c, Account.PersonBirthdate, NumberOfUnreachedCalls__c, (SELECT Id, ActivityDate, SalesAction__c, IsTaskCallReached__c, WhatId, Program__c, IsClosed, TaskResult__c,FalseBrochureProgramCodes__c, Type, RecordTypeId, RecordType.DeveloperName, IsJunior__c, IsUp__c FROM Tasks ORDER BY ActivityDate)
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
                        Id, Name, StageName, Product__c, Program__c, FirstContactDateTime__c,OwnerId, (
                        SELECT Id, Subject, Status, NextCallType__c, FollowUpDate__c, Program__c, Type, IsClosed__c, IsClosed,IsParentClosing__c,isexpresscall__c,RecordTypeId
                        FROM Tasks
                        WHERE Type = :TasksHelper.CALL AND RecordTypeId = :systemCallTaskRecordTypeId
                        LIMIT 1
                )
                FROM Opportunity
                WHERE Id IN :opportunitiesIds
        ];
    }

    public static List<Opportunity> getOpportunitiesWithSBRTaskByAccountIds(List<Id> accountIds) {
        Id sbrRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SBR_TASK_DEVELOPER_NAME).Id;
        return [
                SELECT Id, Age__c, AccountId, Account.PersonBirthdate, Account.Language__c, Market__c, Program__c, Letter__c, Label__c, TemplateKey__c, (SELECT WhatId FROM Tasks WHERE RecordTypeId = :sbrRecordTypeId AND IsClosed <> TRUE)
                FROM Opportunity
                WHERE AccountId IN :accountIds
        ];
    }

    public static Map<Id, Opportunity> getOpportunityRecords(List<Id> opportunityIds) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        if (opportunityIds != null) {
            opportunityMap = new Map<Id, Opportunity>([select Id, SalesOffice__c from Opportunity where Id in :opportunityIds]);
        }
        return opportunityMap;
    }

    /**
    * @author Adam Osiecki
    * ver 1.0 12-Mar-2018
    * @description Returns List of Opportunities for selected Account
    *
    * @param accountId account Id to select
    *
    * @return List<Id,Opportunity>
    */

    public static List<Opportunity> getOpportunitiesByAccountId(Set<Id> accountIds) {

        List<Opportunity> opportunities = new List<Opportunity>(
        [
                SELECT Id, Name, IsActive__c, Product__c, Program__c, StageName, Owner.Name, toLabel(SalesOffice__c)
                FROM Opportunity
                WHERE AccountId IN :accountIds
        ]
        );
        return opportunities;
    }

    public static List<Opportunity> getOpportunityForQuote(Map<Id, String> taskMap) {
        return [Select Id,Program__c from Opportunity where id in:taskMap.keySet()];
    }
     public static map<id,string> getOpportunityStageNameForList(set<id> opportunityRecord) {
       
            map<id,string> opportunityIDAndStageMap = new Map<id,string>();
            String previousOpportunityStageName;
            system.debug('StageHistory>>>'+[Select id,opportunityid,opportunity.FirstContactDateTime__c,StageName from OpportunityHistory where opportunityid in:opportunityRecord and Opportunity.StageName=:Label.Salesclosed]);
            for (OpportunityHistory oppHistory : [Select id,opportunityid,opportunity.FirstContactDateTime__c,StageName from OpportunityHistory where opportunityid in:opportunityRecord and Opportunity.StageName=:Label.Salesclosed]) {
                if (oppHistory.StageName != NULL && oppHistory.StageName != Label.Salesclosed && !opportunityIDAndStageMap.containsKey(oppHistory.opportunityid)) {
                    opportunityIDAndStageMap.put
                    (oppHistory.opportunityid, (oppHistory.opportunity.FirstContactDateTime__c != null) ? label.OpportunityStageFollowUp : oppHistory.StageName);
                }
            }
        
        return opportunityIDAndStageMap;
    }
      public static map<id,opportunity> getLatestEventForOpportunityOrderByCreatedDate(set<id> opportunityID){
     map<id,opportunity> OpportunityEventsMap = new map<id,opportunity>([select id,stagename,program__c,(select id,program__c,type,whatid from events order by createddate desc) from opportunity where id in:opportunityID]);
     return OpportunityEventsMap;
    }
     public static List<Opportunity> getOpportunityWithTasksOrderByCreatedDate(Opportunity oppRecord){
        return [
            SELECT
                    id,NumberOfUnreachedCalls__c,(
                    SELECT id,salesaction__c,taskSubType,isclosed,recordtypeid from tasks order by createddate desc
            )
            FROM opportunity
            WHERE ID=:oppRecord.id And isactive__c=true];    
    }
}