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
        }
        catch (Exception ex) {
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
            }
        }
        if (deleteAccess != null && deleteAccess.size() > 0) {
            delete deleteAccess;
        }
        if (opportunityshareList != null && opportunityshareList.size() > 0) {
            insert opportunityShareList;
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

        for(Opportunity opp: newOpportunities.values()){
            Opportunity oldOpportunity = oldOpportunities.get(opp.Id);
            if(opp.TemplateKey__c != oldOpportunity.TemplateKey__c){
                opportunitiesToUpdate.add(opp.Id);
            }
        }
        if(opportunitiesToUpdate.size() > 0) {
            List<Opportunity> opportunitiesWithSBRTasks = new List<Opportunity>();
            Map<Id, Date> accountBirthdatesByOppIds = new Map<Id, Date>();
            for(Opportunity opp : OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunitiesToUpdate, System.Label.SBRTask)){
                if(opp.Tasks.size() > 0){
                    opportunitiesWithSBRTasks.add(newOpportunities.get(opp.Id));
                    accountBirthdatesByOppIds.put(opp.Id, opp.Account.PersonBirthdate);
                }
            }
            setTemplatesForOpportunities(opportunitiesWithSBRTasks, accountBirthdatesByOppIds);
        }
    }

    public static List<Opportunity> setTemplatesForOpportunities(List<Opportunity> opportunities, Map<Id, Date> accountBirthdatesByOppIds){
        Map<String, TemplateSetting__c[]> templateSettings = getTemplateSettingsForOpportunities(opportunities);

        for (Opportunity opp : opportunities) {
            TemplateSetting__c matchingTemplate = findMatchingTemplateSetting(opp.TemplateKey__c, accountBirthdatesByOppIds.get(opp.Id), templateSettings);
            if (matchingTemplate != NULL) {
                opp.Letter__c = matchingTemplate.Letter__c;
                opp.Label__c = matchingTemplate.Label__c;
            }else{
                opp.Letter__c = NULL;
                opp.Label__c = NULL;
            }
        }

        return opportunities;
    }

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

    private static Decimal calculateMonths(Decimal years, Decimal months){
        Decimal totalMonths = 0;
        if(years != NULL){
            totalMonths += years*12;
        }
        if(months!=NULL){
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
        for (Opportunity opportunity : newOpportunities) {
            if (opportunity.Program__c != oldOpportunities.get(opportunity.Id).Program__c) {
                opportunityIds.add(opportunity.Id);
                opportunitiesWithChangedProgram.add(opportunity);
            }
        }
        if(opportunitiesWithChangedProgram.size() > 0) {
            changeProgramOnSystemCallTasks(opportunitiesWithChangedProgram, new Map<Id, Opportunity>(OpportunitiesSelector.getOpportunitiesWithOpenTasks(opportunityIds, Label.SystemCallTaskRecordTypeDeveloperName)));
        }
    }

    private static void changeProgramOnSystemCallTasks(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesWithTasks) {
        Task[] tasksToUpdate = new Task[]{};
        for(Opportunity opportunity : opportunities){
            for(Task callTask : opportunitiesWithTasks.get(opportunity.Id).Tasks){
                if( callTask.Program__c != opportunity.Program__c){
                    callTask.Program__c = opportunity.Program__c;
                    String refreshedSubject = TasksHelper.refreshTaskSubject(callTask.Subject, callTask.Program__c);
                    if(refreshedSubject != ''){
                        callTask.Subject = refreshedSubject;
                    }
                    tasksToUpdate.add(callTask);
                }
            }
        }
        if(tasksToUpdate.size() > 0){
            update tasksToUpdate;
        }
    }

    public static void handleOwnerChange(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunitiesWithChangedOwner = new List<Opportunity>();
        for (Opportunity opportunity : newOpportunities) {
            if (opportunity.OwnerId != oldOpportunities.get(opportunity.Id).OwnerId) {
                opportunityIds.add(opportunity.Id);
                opportunitiesWithChangedOwner.add(opportunity);
            }
        }

        if(opportunitiesWithChangedOwner.size() > 0 ) {
            reassignOpenActivitiesForOpportunities(opportunitiesWithChangedOwner, new Map<Id, Opportunity>(OpportunitiesSelector.getOpportunitiesWithOpenActivities(opportunityIds)));
        }
    }

    private static void reassignOpenActivitiesForOpportunities(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesWithOpenActivities) {
        SObject[] updatedActivities = new SObject[]{};
        Task[] tasksToUpdate = new Task[]{};
        Event[] eventsToUpdate = new Event[]{};
        for (Opportunity lead : opportunities) {
            if (opportunitiesWithOpenActivities.containsKey(lead.Id)) {
                for (OpenActivity oa : opportunitiesWithOpenActivities.get(lead.Id).OpenActivities) {
                    if (oa.OwnerId != lead.OwnerId) {
                        if(oa.IsTask){
                            tasksToUpdate.add( new Task(Id = oa.Id, OwnerId = lead.OwnerId));
                        }else{
                            eventsToUpdate.add(new Event(Id = oa.Id, OwnerId = lead.OwnerId));
                        }
                    }
                }
            }
        }
        updatedActivities.addAll((List<SObject>)tasksToUpdate);
        updatedActivities.addAll((List<SObject>)eventsToUpdate);
        if (updatedActivities.size() > 0) {
            update updatedActivities;
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
}