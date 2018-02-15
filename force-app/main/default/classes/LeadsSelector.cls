/**************************************************************************************
Apex Class Name    : LeadsSelector
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * shravan.boddula                 07/12/2017              Original Version
*******************************************************************************/
public class LeadsSelector {

    public static List<Lead> getLeadsWithReservations(List<Lead> leads) {
        return [
                select id, FirstName, LastName,status,City,PostalCode,phone,MobilePhone,OtherPhone__c,
                        DOB__c,street,Email,Email2__c,CreationType__c,
                        RequestType__c,Program__c,Market__c,InsertTime__c,ActivityDateTime__c,Region__c,
                        IsDupeProcessed__c,RecalculateRanking__c ,IsDupe__c,ReadyForRanking__c,Ranking__c
                from Lead
                where Id IN:leads and RequestType__c = 'RES'
                ORDER BY ActivityDateTime__c
        ];
    }

    public static List<Lead> getLeadsOnId(Set<Id> leadID) {
        List<Lead> leadList = [
                 SELECT Id, 
                        ActivityDateTime__c,
                        SourceCodeGroup__c,
                        RecalculateRanking__c ,
                        Country,CreatedDate,
                        DepartureCity__c,
                        DestinationCode__c,
                        DeviceType__c,
                        IsParent__c,
                        NumberOfCalls__c,
                        Ranking__c,
                        Region__c,RequestType__c,
                        SalesOffice__c,
                        HadAddressonCreation__c,
                        IsExpressCall__c,
                        State,StateCode,
                        WhenMonth__c,
                        City, 
                        status,
                        CloseDate__c,
                        CreationMethod__c,
                        CreationType__c,
                        Destinations__c,
                        DOB__c, 
                        DoubleOptIn__c, 
                        Duration__c,
                        Email, 
                        Email2__c, 
                        FirstContactDateTime__c,
                        FirstName,
                        HearAboutUs__c,
                        InsertTime__c,      
                        IsConverted,
                        IsDupe__c,
                        IsDupeProcessed__c,
                        LastName, 
                        LikelihoodToBook__c,
                        Market__c,
                        MobilePhone, 
                        OtherPhone__c, 
                        ownerId,
                        Phone, 
                        PostalCode, 
                        product__c,
                        Program__c,                         
                        ReadyForRanking__c,                    
                        PreferredDuration__c,
                        street,
                        TritonId__c,
                       
                        WhenYear__c
                   FROM Lead
                  WHERE Id in :leadId
        ];

        return leadList;
    }



    public static List<Lead> getSortedLeadsOnActivityDate(List<Lead> leads) {
        return [
                select
                        id,FirstName,street,state,LastName,City,PostalCode,phone,MobilePhone,OtherPhone__c,
                        DOB__c,Email,status,Email2__c,RequestType__c,TritonId__c,CreationType__c,
                        Program__c,Market__c,InsertTime__c,ActivityDateTime__c,Region__c,IsDupeProcessed__c,
                        IsDupe__c,ReadyForRanking__c,Ranking__c
                from Lead
                where Id IN:leads
                ORDER BY ActivityDateTime__c desc
        ];
    }

    public static Map<Id, Lead> leadRecordMap(List<Id> leadIdList) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>(
        [
                select
                        id, FirstName,street,LastName,City,PostalCode,phone,SourceCodeGroup__c,RecalculateRanking__c ,Country,CreatedDate,DepartureCity__c,DestinationCode__c,DeviceType__c,IsParent__c,NumberOfCalls__c,SalesOffice__c,State,StateCode,WhenMonth__c,
                        MobilePhone,OtherPhone__c,DoubleOptIn__c,DOB__c,Email,Email2__c,Product__c,
                        RequestType__c,Program__c,Market__c,InsertTime__c,ActivityDateTime__c,
                        Region__c,IsDupeProcessed__c,IsDupe__c,ReadyForRanking__c,CreationType__c,DoNotCall,
                        Ranking__c,status,
                        ConvertedAccountId,ConvertedOpportunityId
                from Lead
                where Id in :leadIdList
                ORDER BY ActivityDateTime__c DESC
        ]);
        return leadMap;
    }


    public static Map<Id, Lead> getNotConvertedLeadMapById(List<Id> leadIdList) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
                select Id,status
                from Lead
                where
                IsConverted = false and Id in :leadIdList
        ]);
        return leadMap;
    }


    public static List<Lead> getAllEventsAndTasksforLead(List<id> leadids) {
        return [select id,status, (Select id,FalseBrochureProgramCodes__c,Type from tasks), (Select id from events) from lead where id in :leadids];
    }


    /**
     * @author Arkadiusz Celej
     * ver 1.0 19-Dec-2017
     * @description Returns list of lead records with open Task with provided record type
     *
     * @param leadIds Ids to select
     * @param recordTypeDeveloperName Task record type developer name
     *
     * @return List<Lead>
     */
    public static List<Lead> getLeadsWithOpenTasks(Set<Id> leadIds, String recordTypeDeveloperName) {
        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(recordTypeDeveloperName).Id;
        return [
                SELECT
                        Id,status, (SELECT Id, Program__c, Subject, OwnerId FROM Tasks WHERE RecordTypeId = :recordTypeId AND IsClosed = FALSE)
                FROM Lead
                WHERE Id IN :leadIds
        ];
    }

    /**
     * @author Arkadiusz Celej
     * ver 1.0 19-Dec-2017
     * @description Returns list of lead records with open activities
     *
     * @param leadIds Ids to select
     *
     * @return List<Lead>
     */
    public static List<Lead> getLeadsWithOpenActivities(Set<Id> leadIds) {
        return [
                SELECT
                        Id,status, (SELECT Id, OwnerId, IsTask FROM OpenActivities)
                FROM Lead
                WHERE Id IN :leadIds
        ];
    }

    /**
     * @author Arkadiusz Celej
     * ver 1.0 19-Dec-2017
     * @description Returns list of lead records with open system call task
     *
     * @param leadIds Ids to select
     *
     * @return List<Lead>
     */
    public static List<Lead> getLeadsWithOpenSystemCallTask(Set<Id> leadIds) {
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;
        return [
                SELECT
                        Id, Name, Status, Product__c, Program__c,OwnerId,
                        (SELECT Id, Subject, Status, NextCallType__c, FollowUpDate__c,IsExpressCall__c, IsClosed,Program__c, Type, IsClosed__c, IsParentClosing__c, RecordTypeId
                        FROM Tasks
                        WHERE RecordTypeId = :systemCallTaskRecordTypeId LIMIT 1)
                FROM Lead
                WHERE Id IN :leadIds
        ];
    }

    /**
    * @author Arkadiusz Celej
    * @param List<id> leadIds - Leads to select
    * @return Returns list of Leads with Tasks
    * */
    public static List<Lead> getLeadsByIdsWithTasks(List<id> leadIds) {
        return [
                SELECT Id, NumberOfCalls__c,status, (SELECT Id,IsExpressCall__c, WhoId, Program__c, IsClosed, TaskResult__c,FalseBrochureProgramCodes__c, Type, RecordTypeId FROM Tasks)
                FROM Lead
                WHERE Id in :leadIds
        ];
    }
     public static Lead getLeadRecord(Id recordId) {
        return [Select Id, Program__c, Market__c
        from Lead
        where Id = :recordId
        LIMIT 1];
    }
}