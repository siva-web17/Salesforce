/**
 * Created by thejasvi.a on 9/20/2017.
**/

public without sharing class CongaTemplateHelper {

    //create and insert share records
    public static void createShareOnInsert(List<APXTConga4__Conga_Template__c> templateList) {
        try {
            Map<Id, String> templateMap = new Map<Id, String>();
            for (APXTConga4__Conga_Template__c templateRec: templateList) {
                templateMap.put(templateRec.ID, templateRec.RecordSharingKey__c);
            }
            //get the public group details here
            Map<String, Id> publicGroupMap = publicGroupsSelector.getRegularPublicGroupsByName(templateMap.values());
            List<APXTConga4__Conga_Template__share> templateShareList = new List<APXTConga4__Conga_Template__share>();
            templateShareList = createTemplateShareRec(templateMap, publicGroupMap);
            if (templateShareList.size() > 0) {
                insert templateShareList;
            }
        }
        catch (Exception ex) {
            String errMessage = ex.getMessage();
            String trace = ex.getStackTraceString();
            String className = 'CongaTemplatesHelper';
            String methodName = 'createShareOnInsert';
            Id id = '';
            ExceptionHandler.errorLog(errMessage, trace, className, methodName, id);
        }
    }

    //create and return list of share records without inserting it
    public static List<APXTConga4__Conga_Template__share> createTemplateShareRec(Map<Id, String> templateMap, Map<String, ID> publicGroupMap) {
        List<APXTConga4__Conga_Template__share> templateShareList = new List<APXTConga4__Conga_Template__share>();
        for (Id templateId : templateMap.keySet()) {
            if (publicGroupMap.containsKey(templateMap.get(templateId))) {
                APXTConga4__Conga_Template__share shareRecord = createShareRecord(templateId, publicGroupMap.get(templateMap.get(templateId)), System.Label.EditAccessLevel);
                templateShareList.add(shareRecord);
            }
        }
        return templateShareList;
    }

    //create and return a single share record
    public static APXTConga4__Conga_Template__share createShareRecord(ID recordId, ID userOrGroupId, String accessLevel) {
        APXTConga4__Conga_Template__share shareRecord = new APXTConga4__Conga_Template__share();
        shareRecord.ParentId = recordId;
        shareRecord.UserOrGroupId = userOrGroupId;
        shareRecord.AccessLevel = accessLevel;
        return shareRecord;
    }

    //For after update
    public static void createShareOnUpdateTypes(List<APXTConga4__Conga_Template__c> congaTemplateNewList, List<APXTConga4__Conga_Template__c> congaTemplateOldList) {
        List<String> addPublicGroupNameList = new List<String>();
        List<String> removePublicGroupNameList = new List<String>();
        List<String> allPublicGroupList = new List<String>();
        List<Id> templateIdList = new List<Id>();

        for (Integer index = 0; index < congaTemplateNewList.size(); index++) {
            templateIdList.add(congaTemplateNewList[index].id);
            if (congaTemplateNewList[index].RecordSharingKey__c != congaTemplateOldList[index].RecordSharingKey__c) {
                addPublicGroupNameList.add(congaTemplateNewList[index].RecordSharingKey__c);
                removePublicGroupNameList.add(congaTemplateOldList[index].RecordSharingKey__c);
            }
            if (congaTemplateNewList[index].OwnerId != congaTemplateOldList[index].OwnerId) {
                addPublicGroupNameList.add(congaTemplateNewList[index].RecordSharingKey__c);
            }
        }
        allPublicGroupList.addAll(addPublicGroupNameList);
        allPublicGroupList.addAll(removePublicGroupNameList);
        Map<String, ID> publicGroupMap = publicGroupsSelector.getRegularPublicGroupsByName(allPublicGroupList);
        //access level
        List<APXTConga4__Conga_Template__share> templateShareList = new List<APXTConga4__Conga_Template__share>();
        List<APXTConga4__Conga_Template__share> templateDeleteAccess = new List<APXTConga4__Conga_Template__share>();
        //share table query
        List<APXTConga4__Conga_Template__share> templateShareIdList = new List<APXTConga4__Conga_Template__share>();
        templateShareIdList = [Select Id, userOrGroupId, ParentId
                               from APXTConga4__Conga_Template__share
                               where ParentId  in :templateIdList];
        Map<String, APXTConga4__Conga_Template__share> templateShareIdKeyMap = new Map<String, APXTConga4__Conga_Template__share>();
        Map<Id, Id> groupIdMap = new Map<Id, Id>();
        String templateGroupIdCombinationMap = '';
        for (APXTConga4__Conga_Template__share share : templateShareIdList) {
            templateGroupIdCombinationMap = String.valueOf(String.valueOf(share.UserOrGroupId) + String.valueOf(share.ParentId));
            templateShareIdKeyMap.put(templateGroupIdCombinationMap, share);
        }

        for (Integer index = 0; index < congaTemplateNewList.size(); index++) {
            if (congaTemplateNewList[index].RecordSharingKey__c != congaTemplateOldList[index].RecordSharingKey__c) {
                if (publicGroupMap.containsKey(congaTemplateNewList[index].RecordSharingKey__c)) {
                    //add access level
                    templateShareList.add(createShareRecord(congaTemplateNewList[index].id, publicGroupMap.get(congaTemplateNewList[index].RecordSharingKey__c), System.Label.EditAccessLevel));
                }
                if (publicGroupMap.containsKey(congaTemplateOldList[index].RecordSharingKey__c)) {
                    String groupStr = String.valueOf(publicGroupMap.get(congaTemplateOldList[index].RecordSharingKey__c));
                    groupStr += congaTemplateNewList[index].id;
                    if (templateShareIdKeyMap.containsKey(groupStr)) {
                        templateDeleteAccess.add(templateShareIdKeyMap.get(groupStr));
                    }
                }
            }
            if (congaTemplateNewList[index].OwnerId != congaTemplateOldList[index].OwnerId) {
                if (publicGroupMap.containsKey(congaTemplateNewList[index].RecordSharingKey__c)) {
                    templateShareList.add(createShareRecord(congaTemplateNewList[index].id, publicGroupMap.get(congaTemplateNewList[index].RecordSharingKey__c), System.Label.EditAccessLevel));
                }
            }
        }
        if (templateDeleteAccess != null && templateDeleteAccess.size() > 0) {
            delete templateDeleteAccess;
        }
        if (templateShareList != null && templateShareList.size() > 0) {
            system.debug('records inserted'+templateShareList);
            insert templateShareList;
            system.debug('records after inserted'+templateShareList);
        }
    }
}