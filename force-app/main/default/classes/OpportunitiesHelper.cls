/**************************************************************************************
Apex Class Name    : OpportunityHelper
Version            : 1.0
Created Date       : Apr 25 2017
Function           : Opportunity related business logic here.
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  04/25/2017              Original Version
 *************************************************************************************/

public class OpportunitiesHelper {
    public static boolean isActiveChanged = false;

    //For after insert
    public static void createShareOnInsert(List<Opportunity> oppList) {

        Map<Id, String> OpportunityMap = new Map<Id, String>();

        for (Opportunity opp : oppList) {
            OpportunityMap.put(opp.ID, opp.RecordSharingKey__c); //*** replace name with the Formula field
        }

        //get the public group details here
        Map<String, ID> publicGroupMap = publicGroupsSelector.getRegularPublicGroupsByName(OpportunityMap.values());

        List<OpportunityShare> OppShareList = new List<OpportunityShare>();
        OppShareList = createOpportunityShareRec(OpportunityMap, publicGroupMap);
        try {
            if (OppShareList.size() > 0) {
                insert OppShareList;
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'createShareOnInsert', null);
        }
    }

    public static List<opportunityShare> createOpportunityShareRec(Map<Id, String> opportunityMap, Map<String, ID> publicGroupMap) {
        List<opportunityShare> opportunityShareList = new List<opportunityShare>();
        for (ID LId : opportunityMap.keySet()) {
            if (publicGroupMap.containsKey(opportunityMap.get(LId))) {
                opportunityShare shareRecord = createShareRecord(LId, publicGroupMap.get(opportunityMap.get(LId)), System.Label.EditAccessLevel);
                opportunityShareList.add(shareRecord);
            }
        }
        return opportunityShareList;
    }


    //For after update
    public static void createShareOnUpdateTypes(List<opportunity> opportunityNewList, List<opportunity> opportunityOldList) {
        List<String> addPublicGroupNameList = new List<String>();
        List<String> removePublicGroupNameList = new List<String>();
        List<String> allPublicGroupList = new List<String>();
        List<Id> opportunityIdList = new List<Id>();

        try {
            for (Integer index = 0; index < opportunityNewList.size(); index++) {
                opportunityIdList.add(opportunityNewList[index].id);
                if (opportunityNewList[index].RecordSharingKey__c != opportunityOldList[index].RecordSharingKey__c) {
                    addPublicGroupNameList.add(opportunityNewList[index].RecordSharingKey__c);
                    removePublicGroupNameList.add(opportunityOldList[index].RecordSharingKey__c);
                }
                if (opportunityNewList[index].OwnerId != opportunityOldList[index].OwnerId) {
                    addPublicGroupNameList.add(opportunityNewList[index].RecordSharingKey__c);
                }
            }
            allPublicGroupList.addAll(addPublicGroupNameList);
            allPublicGroupList.addAll(removePublicGroupNameList);
            if (allPublicGroupList.isEmpty()) {
                return;
            }
            Map<String, ID> publicGroupMap = publicGroupsSelector.getRegularPublicGroupsByName(allPublicGroupList);
            //access level
            List<opportunityShare> opportunityShareList = new List<opportunityShare>();
            List<opportunityShare> deleteAccess = new List<opportunityShare>();
            //share table query
            List<opportunityShare> opportunityShareIdList = [select id,userOrGroupId,opportunityId from opportunityShare Where opportunityId in :opportunityIdList];
            Map<String, opportunityShare> opportunityShareIdKeyMap = new Map<String, opportunityShare>();
            Map<Id, Id> groupIdMap = new Map<Id, Id>();
            String opportunityGroupIdCombinationMap = '';
            for (opportunityShare share : opportunityShareIdList) {
                opportunityGroupIdCombinationMap = String.valueOf(String.valueOf(share.userOrGroupId) + String.valueOf(share.opportunityid));
                opportunityShareIdKeyMap.put(opportunityGroupIdCombinationMap, share);
            }

            for (Integer index = 0; index < opportunityNewList.size(); index++) {
                if (opportunityNewList[index].RecordSharingKey__c != opportunityOldList[index].RecordSharingKey__c) {
                    if (publicGroupMap.containsKey(opportunityNewList[index].RecordSharingKey__c)) {
                        //add acccess level
                        opportunityShareList.add(createShareRecord(opportunityNewList[index].id, publicGroupMap.get(opportunityNewList[index].RecordSharingKey__c), 'Edit'));
                    }
                    if (publicGroupMap.containsKey(opportunityOldList[index].RecordSharingKey__c)) {
                        String groupstr = String.valueOf(publicGroupMap.get(opportunityOldList[index].RecordSharingKey__c));
                        groupstr += opportunityNewList[index].id;
                        if (opportunityShareIdKeyMap.containsKey(groupstr)) {
                            deleteAccess.add(opportunityShareIdKeyMap.get(groupstr));
                        }
                    }
                }
                if (opportunityNewList[index].OwnerId != opportunityOldList[index].OwnerId) {
                    if (publicGroupMap.containsKey(opportunityNewList[index].RecordSharingKey__c)) {
                        opportunityshareList.add(createShareRecord(opportunityNewList[index].id, publicGroupMap.get(opportunityNewList[index].RecordSharingKey__c), 'Edit'));
                    }
                }if (opportunityNewList[index].isActive__c != opportunityOldList[index].isActive__c) {
                    isActiveChanged = true;
                }
            }
            if (deleteAccess != null && deleteAccess.size() > 0) {
                delete deleteAccess;
            }
            if (opportunityshareList != null && opportunityshareList.size() > 0) {
                insert opportunityShareList;
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'createShareOnUpdateTypes', null);
        }
    }
    //*********opportunity Share code End here****************//

    public static OpportunityShare createShareRecord(ID recordId, ID userOrGroupId, String accessLevel) {
        OpportunityShare os = new OpportunityShare();
        os.OpportunityId = recordId;
        os.UserOrGroupId = userOrGroupId;
        os.OpportunityAccessLevel = accessLevel;
        return os;
    }

    public static void UpdateMarketCodeOnAccount(List<Opportunity> oppNewList, List<Opportunity> oppOldList) {
        Map<Id, String> accountMarketCodeMap = new Map<Id, String>();
        for (Integer i = 0; i < oppNewList.size(); i++) {

            if (oppNewList[i].Market__c != oppOldList[i].Market__c) {
                accountMarketCodeMap.put(oppNewList[i].AccountID, oppNewList[i].Market__c);
            }
        }

        List<ID> accIDList = new List<ID>(accountMarketCodeMap.keySet());

        List<Account> accList = OpportunitiesSelector.getAccountDetails(accIDList);
        for (Account acc : accList) {
            if (accountMarketCodeMap.containsKey(acc.ID)) {
                acc.Market__c = accountMarketCodeMap.get(acc.ID);
            }
        }
        update accList;
    }

    /**
    * @author Arkadiusz Celej
    * ver 1.0 8-Dec-2017
    * @description This method sets Letter and Label for opportunities based on matching TemplateSettings records
    *
    * */
    public static void setDefaultLetterAndLabel(Map<Id, Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        Set<Id> opportunitiesToUpdate = new Set<Id>();
        try {
            for (Opportunity opp : newOpportunities.values()) {
                Opportunity oldOpportunity = oldOpportunities.get(opp.Id);
                system.debug('the setDaulfLetterAndLabel' + oldOpportunity);
                if (opp.TemplateKey__c != oldOpportunity.TemplateKey__c) {
                    opportunitiesToUpdate.add(opp.Id);
                }
            }
            if (opportunitiesToUpdate.size() > 0) {
                List<Opportunity> opportunitiesWithSBRTasks = new List<Opportunity>();
                Map<Id, Date> accountBirthdatesByOppIds = new Map<Id, Date>();
                for (Opportunity opp : OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunitiesToUpdate, System.Label.SBRTask)) {
                    if (opp.Tasks.size() > 0) {
                        opportunitiesWithSBRTasks.add(newOpportunities.get(opp.Id));
                        accountBirthdatesByOppIds.put(opp.Id, opp.Account.PersonBirthdate);
                    }
                }
                setTemplatesForOpportunities(opportunitiesWithSBRTasks, accountBirthdatesByOppIds);
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'setDefaultLetterAndLabel', null);
        }
    }

    public static List<Opportunity> setTemplatesForOpportunities(List<Opportunity> opportunities, Map<Id, Date> accountBirthdatesByOppIds) {
        Map<String, TemplateSetting__c[]> templateSettings = getTemplateSettingsForOpportunities(opportunities);

        for (Opportunity opp : opportunities) {
            TemplateSetting__c matchingTemplate = findMatchingTemplateSetting(opp.TemplateKey__c, accountBirthdatesByOppIds.get(opp.Id), templateSettings);
            if (matchingTemplate != NULL) {
                opp.Letter__c = matchingTemplate.Letter__c;
                opp.Label__c = matchingTemplate.Label__c;
            } else {
                opp.Letter__c = NULL;
                opp.Label__c = NULL;
            }
        }

        return opportunities;
    }

    @TestVisible
    private static TemplateSetting__c findMatchingTemplateSetting(String templateKey, Date birthday, Map<String, TemplateSetting__c[]> templateSettings) {
        if (templateSettings.containsKey(templateKey)) {
            for (TemplateSetting__c templateSetting : templateSettings.get(templateKey)) {
                Integer monthsSinceBirth = birthday != NULL ? birthday.monthsBetween(System.today()) : 0;
                Decimal templateMonthsFrom = calculateMonths(templateSetting.AgeFromYears__c, templateSetting.AgeFromMonths__c);
                Decimal templateMonthsTo = calculateMonths(templateSetting.AgeToYears__c, templateSetting.AgeToMonths__c);
                if (templateMonthsFrom <= monthsSinceBirth && monthsSinceBirth <= templateMonthsTo) {
                    return templateSetting;
                }
            }
        }
        return null;
    }

    @TestVisible
    private static Decimal calculateMonths(Decimal years, Decimal months) {
        Decimal totalMonths = 0;
        if (years != NULL) {
            totalMonths += years * 12;
        }
        if (months != NULL) {
            totalMonths += months;
        }
        return totalMonths;
    }

    private static Map<String, TemplateSetting__c[]> getTemplateSettingsForOpportunities(Opportunity[] opportunities) {
        Set<String> templateKeys = new Set<String>();

        for (Opportunity opp : opportunities) {
            templateKeys.add(opp.TemplateKey__c);
        }
        Map<String, TemplateSetting__c[]> result = new Map<String, TemplateSetting__c[]>();
        List<TemplateSetting__c> templateSettings = TemplateSettingsSelector.getTemplateSettingsByKeys(templateKeys);

        for (TemplateSetting__c template : templateSettings) {

            if (!result.containsKey(template.TemplateKey__c)) {
                result.put(template.TemplateKey__c, new List<TemplateSetting__c>());
            }
            result.get(template.TemplateKey__c).add(template);
        }
        return result;
    }

    public static void handleProgramChange(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunitiesWithChangedProgram = new List<Opportunity>();
        try {
            for (Opportunity opportunity : newOpportunities) {
                if (opportunity.Program__c != oldOpportunities.get(opportunity.Id).Program__c) {
                    opportunityIds.add(opportunity.Id);
                    opportunitiesWithChangedProgram.add(opportunity);
                }
            }
            if (opportunitiesWithChangedProgram.size() > 0) {
                changeProgramOnSystemCallTasks(opportunitiesWithChangedProgram, new Map<Id, Opportunity>(OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName)));
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'handleProgramChange', null);
        }
    }
    @TestVisible
    private static void changeProgramOnSystemCallTasks(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesWithTasks) {
        Task[] tasksToUpdate = new Task[]{
        };
        for (Opportunity opportunity : opportunities) {
            for (Task callTask : opportunitiesWithTasks.get(opportunity.Id).Tasks) {
                system.debug('callTask.Program__c ' + callTask.Program__c);
                system.debug('opportunity.Program__c ' + opportunity.Program__c);
                if (callTask.Program__c != opportunity.Program__c) {
                    callTask.Program__c = opportunity.Program__c;
                    String refreshedSubject = TasksHelper.refreshTaskSubject(callTask.Subject, callTask.Program__c);
                    if (refreshedSubject != '') {
                        callTask.Subject = refreshedSubject;
                    }
                    tasksToUpdate.add(callTask);
                }
            }
        }
        if (tasksToUpdate.size() > 0) {
            update tasksToUpdate;
        }
    }

    public static void handleOwnerChange(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunitiesWithChangedOwner = new List<Opportunity>();
        try {
            for (Opportunity opportunity : newOpportunities) {
                if (opportunity.OwnerId != oldOpportunities.get(opportunity.Id).OwnerId) {
                    opportunityIds.add(opportunity.Id);
                    opportunitiesWithChangedOwner.add(opportunity);
                }
            }

            if (opportunitiesWithChangedOwner.size() > 0) {
                reassignOpenActivitiesForOpportunities(opportunitiesWithChangedOwner, new Map<Id, Opportunity>(OpportunitiesSelector.getOpportunitiesWithOpenActivities(opportunityIds)));
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'handleOwnerChange', null);
        }
    }

    @TestVisible
    private static void reassignOpenActivitiesForOpportunities(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesWithOpenActivities) {
        Id currentRecordId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
        try {
            SObject[] updatedActivities = new SObject[]{
            };
            Task[] tasksToUpdate = new Task[]{
            };
            Event[] eventsToUpdate = new Event[]{
            };
            for (Opportunity lead : opportunities) {
                if (opportunitiesWithOpenActivities.containsKey(lead.Id)) {
                    for (OpenActivity oa : opportunitiesWithOpenActivities.get(lead.Id).OpenActivities) {
                        if (oa.OwnerId != lead.OwnerId) {
                            if (oa.IsTask) {
                                tasksToUpdate.add(new Task(Id = oa.Id, OwnerId = lead.OwnerId));
                            } else {
                                eventsToUpdate.add(new Event(Id = oa.Id, OwnerId = lead.OwnerId));
                            }
                        }
                    }
                }
            }
            updatedActivities.addAll((List<SObject>) tasksToUpdate);
            updatedActivities.addAll((List<SObject>) eventsToUpdate);
            if (updatedActivities.size() > 0) {
                update updatedActivities;
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'OpportunitiesHelper', 'reassignOpenActivitiesForOpportunities', currentRecordId);
        }
    }

    public static Task createSystemCallTaskRecordForOpportunity(Opportunity opportunity) {
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(Label.SystemCallTaskRecordTypeDeveloperName).Id;
        Task systemTask = new Task();
        systemTask.RecordTypeId = systemCallTaskRecordTypeId;
        systemTask.WhatId = opportunity.Id;
        systemTask.OwnerId = opportunity.OwnerId;
        systemTask.FollowUpDate__c = System.now();
        systemTask.Program__c = opportunity.Program__c;
        systemTask.Subject = Label.SystemTaskDefaultSubject;
        systemTask.Type = System.Label.Call;
        systemTask.ActivityDate = System.today();
        systemTask.NextCallType__c = System.Label.ContactCustomer;

        return systemTask;
    }

    public static void passOpportunityListToPopulateSalesOfficeProgram(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        List<Opportunity> oppListforSalesOfficeUpdate = new List<Opportunity>(); 
        try {
            for (Opportunity objOpportunity : newOpportunityMap.values()) {
                if (oldOpportunityMap.get(objOpportunity.Id).RecordSharingKey__c != newOpportunityMap.get(objOpportunity.Id).RecordSharingKey__c) {
                    oppListforSalesOfficeUpdate.add(objOpportunity);
                }
            }
            if (oppListforSalesOfficeUpdate.Size() > 0) {
                populateSalesOfficeProgram(oppListforSalesOfficeUpdate);
            }
        }catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'passOpportunityListToPopulateSalesOfficeProgram', null);
        }
    }

    public static void populateSalesOfficeProgram(List<Opportunity> opportunityList) {
        Set<string> recordSharingValues = new Set<String>();
        Map<string, id> salesOfficeMap = new Map<string, id>();
            for (Opportunity oppRecord : opportunityList) {
                if (oppRecord.RecordSharingKey__c != '') {
                    recordSharingValues.add(oppRecord.RecordSharingKey__c);
                }
            }

            List<SalesOfficeProgram__c> salesofficeRecords = SalesOfficeProgramSelector.getSalesOfficeRecords(recordSharingValues);
            for (SalesOfficeProgram__c salesOfficeRecord : salesofficeRecords) {
                if (salesOfficeRecord.Name != null) {
                    salesOfficeMap.put(salesOfficeRecord.Name, salesOfficeRecord.id);
                }
            }

            for (Opportunity oppRec : opportunityList) {
                {
                    if (salesOfficeMap.containsKey(oppRec.RecordSharingKey__c)) {
                        oppRec.SalesOfficeProgram__c = salesOfficeMap.get(oppRec.RecordSharingKey__c);
                    }
                }
            }
    }


    public static void populateSourceBasedonSorceCodeAuto(List<Opportunity> oppList) {
        Set<String> sourceAutoCodeValues = new Set<String>();
        Map<String, String> sourceMap = new Map<string, String>();

        try {
            for (Opportunity oppRecord : oppList) {
                if (oppRecord.SourceCodeAuto__c != null && oppRecord.SourceCodeAuto__c != '') {
                    sourceAutoCodeValues.add(oppRecord.SourceCodeAuto__c);
                }
            }

            List<Source__c> sourceRecords = SourcesSelector.getSourceRecords(sourceAutoCodeValues);
            for (Source__c sourceRec : sourceRecords) {
                if (sourceRec.Code__c != null) {
                    sourceMap.put(sourceRec.Code__c, sourceRec.Name);
                }
            }

            for (Opportunity opportunityRec : oppList) {
                if (sourceMap.containsKey(opportunityRec.SourceCodeAuto__c)) {
                    opportunityRec.Partner__c = sourceMap.get(opportunityRec.SourceCodeAuto__c);
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'populateSourceBasedonSorceCodeAuto', null);
        }
    }

    public static void populateSourceCodeAutoAndPartnerFromSource(List<Opportunity> opportunityList) {

        Set<Id> sourceIds = new Set<Id>();
        Map<Id, List<Opportunity>> opportunityMap = new Map<Id, List<Opportunity>>();
        Map<Id, Source__c> sourceMap = new Map<Id, Source__c>();

        try {
            for (Opportunity opportunityRecord : opportunityList) {
                if (opportunityRecord.Source__c != null) {
                    if (!opportunityMap.containsKey(opportunityRecord.Source__c)) {
                        opportunityMap.put(opportunityRecord.Source__c, new List<Opportunity>());
                    }
                    opportunityMap.get(opportunityRecord.Source__c).add(opportunityRecord);
                }
            }

            sourceMap = SourcesSelector.getSourceMapRecordforOpportunity(opportunityMap);

            for (Id recordId : opportunityMap.keyset()) {
                for (Opportunity opportunityRec : opportunityMap.get(recordId)) {
                    if (sourceMap.containskey(opportunityRec.source__c) && sourceMap.get(opportunityRec.Source__c) != null) {
                        opportunityRec.Partner__c = (sourceMap.get(opportunityRec.Source__c).Name);
                        opportunityRec.SourceCodeAuto__c = (sourceMap.get(opportunityRec.Source__c).Code__c);
                    }
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'OpportunitiesHelper', 'populateSourceCodeAutoAndPartnerFromSource', null);
        }
    }

    public static Opportunity createActiveOpportunityForAccount(OpportunityDataWrapper wrapper){
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = wrapper.account.Name;
        newOpportunity.StageName = Label.OpportunityStageToContact;
        newOpportunity.IsActive__c = true;
        newOpportunity.Market__c = wrapper.account.Market__c;
        newOpportunity.AccountId = wrapper.account.Id;
        newOpportunity.CloseDate = System.today();
        newOpportunity.Program__c = wrapper.lead.Program__c;
        newOpportunity.RequestType__c = wrapper.lead.RequestType__c;
        newOpportunity.Source__c = wrapper.lead.Source__c;
        newOpportunity.SalesOffice__c = wrapper.lead.SalesOffice__c;
        newOpportunity.Etag__c = wrapper.lead.Etag__c;
        newOpportunity.CreationMethod__c = wrapper.lead.CreationMethod__c;
        return newOpportunity;
    }

    public class CreateActiveOpportunitiesQueueable implements Queueable{
        private Integer chunkSize = Integer.valueOf(Label.CreateActiveOpportunitiesQueueableChunkSize);
        private List<OpportunityDataWrapper> opportunityDataWrappers;

        public CreateActiveOpportunitiesQueueable(OpportunityDataWrapper[] wrappers){
            this.opportunityDataWrappers = wrappers;
        }

        public void execute(QueueableContext context){
            List<OpportunityDataWrapper> chunk = retrieveChunk();
            if(chunk.size() == 0){
                return;
            }

            Map<Id, Event> eventsByIds = new Map<Id, Event>();
            Map<Id, Opportunity> opportunitiesByPersonContactIds = new Map<Id, Opportunity>();
            for(OpportunityDataWrapper wrapper : chunk){
                if(wrapper.events != NULL && wrapper.account != NULL && wrapper.lead != NULL){
                    opportunitiesByPersonContactIds.put(wrapper.account.PersonContactId, OpportunitiesHelper.createActiveOpportunityForAccount(wrapper));
                    for(Event evt : wrapper.events) {
                        eventsByIds.putAll(wrapper.events);
                    }
                }
            }

            if(opportunitiesByPersonContactIds.values().size() > 0){
                insert opportunitiesByPersonContactIds.values();
            }

            for(Event evt : eventsByIds.values()){
                Opportunity opp = opportunitiesByPersonContactIds.get(evt.WhoId);
                if(opp != NULL){
                    evt.WhatId = opp.Id;

                }
            }
            if(eventsByIds.values().size() > 0){
                update eventsByIds.values();
            }

            if(this.opportunityDataWrappers.size() > 0){
                System.enqueueJob(new CreateActiveOpportunitiesQueueable(this.opportunityDataWrappers));
            }
        }

        private List<OpportunityDataWrapper> retrieveChunk(){
            List<OpportunityDataWrapper> chunk = new List<OpportunityDataWrapper>();
            if(this.opportunityDataWrappers.size() <= this.chunkSize) {
                chunk.addAll(this.opportunityDataWrappers);
                this.opportunityDataWrappers.clear();
            }else{
                Integer counter = 0;
                for(Integer i = this.opportunityDataWrappers.size()-1; i >= 0; i--){
                    if(counter < this.chunkSize){
                        chunk.add(this.opportunityDataWrappers[i]);
                        this.opportunityDataWrappers.remove(i);
                        counter++;
                    }else{
                        break;
                    }
                }
            }
            return chunk;
        }
    }

    /**
     * Wrapper class to store data needed
     * to create new Opportunity record
     * for merged lead to Person account
     */
    public class OpportunityDataWrapper {
        public List<Event> events;
        public Lead lead;
        public Account account;
    }
    public static List<Opportunity> populateCloseDate(List<Opportunity> opportunities){
        for (Opportunity opp : opportunities) {
            if(opp.IsByConversion__c == false) {
                opp.CloseDate = System.today().addMonths(2);
            }
        }
        return opportunities;
    }
}