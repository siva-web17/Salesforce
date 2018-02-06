/**************************************************************************************
Apex Class Name    : UsersHelper
Version            : 1.0
Created Date       : January 22 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arkadiusz Celej             22/01/2018              Original Version
*******************************************************************************/
public class UsersHelper {

    public static final String USER_GROUPS_SEPARATOR = ';';

    public static void createUsersGroupMembership(Map<Id, User> newUsersByIds){
        Set<String> groupDeveloperNames = extractGroupDeveloperNames(newUsersByIds);
        if(groupDeveloperNames.size() > 0) {
            Map<String, Group> groupsByDeveloperNames = getGroupsByDeveloperNames(groupDeveloperNames);
            GroupMember[] toInsert = createMembershipForUsers(newUsersByIds, groupsByDeveloperNames);
            if(toInsert.size() > 0){
                insert toInsert;
            }
        }
    }

    public static void synchronizeUsersGroupMembership(Map<Id, User> newUsersByIds, Map<Id, User> oldUsersByIds){
        Map<Id, User> deactivatedUsersByIds = new Map<Id, User>();
        Map<Id, User> activatedUsersByIds = new Map<Id, User>();
        Map<Id, User> usersWithChangedGroupMembership = new Map<Id, User>();
        Map<Id, User> oldUsersToRecalculate = new Map<Id, User>();
        Set<String> groupDeveloperNames = new Set<String>();

        Set<Id> usersToRecalculate = new Set<Id>();
        for(Id userId : newUsersByIds.keySet()){
            User newUser = newUsersByIds.get(userId);
            User oldUser = oldUsersByIds.get(userId);
            if(newUser.IsActive != oldUser.IsActive){
                if(newUser.IsActive){
                    activatedUsersByIds.put(newUser.Id, newUser);
                }else{
                    deactivatedUsersByIds.put(newUser.Id, newUser);
                }
                oldUsersToRecalculate.put(newUser.Id, oldUsersByIds.get(newUser.Id));
            }else if(newUser.EnabledForMarketSalesOfficeProgram__c != oldUser.EnabledForMarketSalesOfficeProgram__c || newUser.EnabledForMarkets__c != oldUser.EnabledForMarkets__c){
                usersWithChangedGroupMembership.put(newUser.Id, newUser);
                oldUsersToRecalculate.put(newUser.Id, oldUsersByIds.get(newUser.Id));
            }
        }
        usersToRecalculate.addAll(usersWithChangedGroupMembership.keySet());
        usersToRecalculate.addAll(activatedUsersByIds.keySet());
        usersToRecalculate.addAll(deactivatedUsersByIds.keySet());
        if(usersToRecalculate.size() > 0){
            groupDeveloperNames.addAll(extractGroupDeveloperNames(activatedUsersByIds));
            groupDeveloperNames.addAll(extractGroupDeveloperNames(deactivatedUsersByIds));
            groupDeveloperNames.addAll(extractGroupDeveloperNames(usersWithChangedGroupMembership));
            groupDeveloperNames.addAll(extractGroupDeveloperNames(oldUsersToRecalculate));
            Map<String, Group> groupsByDeveloperNames = getGroupsByDeveloperNames(groupDeveloperNames);

            Map<Id, Map<String, GroupMember>> userMembershipByGroupDeveloperNames = new Map<Id, Map<String, GroupMember>>();
            for(GroupMember gm : GroupMembersSelector.getGroupMembersByUserIds(usersToRecalculate)){
                if(!userMembershipByGroupDeveloperNames.containsKey(gm.UserOrGroupId)){
                    userMembershipByGroupDeveloperNames.put(gm.UserOrGroupId, new Map<String, GroupMember>());
                }
                userMembershipByGroupDeveloperNames.get(gm.UserOrGroupId).put(gm.Group.DeveloperName, gm);
            }

            GroupMember[] toInsert = new GroupMember[]{};
            GroupMember[] toDelete = new GroupMember[]{};
            if(!activatedUsersByIds.isEmpty()){
                toInsert.addAll( createMembershipForUsers(activatedUsersByIds, groupsByDeveloperNames) );
            }

            for(User u : usersWithChangedGroupMembership.values()){
                Set<String> newGroups = extractGroupDeveloperNames(newUsersByIds.get(u.Id));
                Set<String> oldGroups = extractGroupDeveloperNames(oldUsersByIds.get(u.Id));
                oldGroups.removeAll(newGroups);
                toDelete.addAll( getGroupMemberRecordsToDelete(u.Id, oldGroups, userMembershipByGroupDeveloperNames));
                toInsert.addAll( createMembershipForUser(u.Id, newGroups, groupsByDeveloperNames));
            }

            for(User u : deactivatedUsersByIds.values()){
                Set<String> oldGroups = extractGroupDeveloperNames(oldUsersByIds.get(u.Id));
                toDelete.addAll( getGroupMemberRecordsToDelete(u.Id, oldGroups, userMembershipByGroupDeveloperNames));
            }

            if(toDelete.size() > 0){
                delete toDelete;
            }

            if(toInsert.size() > 0){
                insert toInsert;
            }
        }

    }

    private static GroupMember[] createMembershipForUsers(Map<Id, User> usersByIds, Map<String, Group> groupsByDeveloperNames){
        GroupMember[] newMembers = new GroupMember[]{};
        for(Id userId: usersByIds.keySet()){
            Set<String> enabledGroups = extractGroupDeveloperNames(usersByIds.get(userId));
            newMembers.addAll(createMembershipForUser(userId, enabledGroups, groupsByDeveloperNames));
        }
        return newMembers;
    }

    private static GroupMember[] createMembershipForUser(Id userId, Set<String> enabledGroups, Map<String, Group> groupsByDeveloperNames){
        GroupMember[] newMembers = new GroupMember[]{};
        for(String groupName : enabledGroups){
            if(groupsByDeveloperNames.containsKey(groupName) && groupsByDeveloperNames.get(groupName) != NULL){
                Group g = groupsByDeveloperNames.get(groupName);
                newMembers.add(new GroupMember(GroupId = g.Id, UserOrGroupId = userId));
            }
        }
        return newMembers;
    }

    private static GroupMember[] getGroupMemberRecordsToDelete(Id userId, Set<String> groupsToDelete, Map<Id, Map<String, GroupMember>> userMembershipByGroupDeveloperNames){
        GroupMember[] toDelete = new GroupMember[]{};
        for(String groupName : groupsToDelete){
            if(userMembershipByGroupDeveloperNames.containsKey(userId) && userMembershipByGroupDeveloperNames.get(userId).containsKey(groupName)){
                toDelete.add( userMembershipByGroupDeveloperNames.get(userId).get(groupName) );
            }
        }
        return toDelete;
    }

    private static Set<String> extractGroupDeveloperNames(Map<Id, User> usersByIds){
        Set<String> groupDeveloperNames = new Set<String>();
        for(Id userId : usersByIds.keySet()) {
            groupDeveloperNames.addAll(extractGroupDeveloperNames(usersByIds.get(userId)));
        }
        return groupDeveloperNames;
    }

    private static Set<String> extractGroupDeveloperNames(User u){
        String[] groups = u.EnabledForMarketSalesOfficeProgram__c != NULL ? u.EnabledForMarketSalesOfficeProgram__c.split(USER_GROUPS_SEPARATOR) : new List<String>();
        if(!String.isBlank(u.EnabledForMarkets__c)){
            groups.addAll(u.EnabledForMarkets__c.split(USER_GROUPS_SEPARATOR));
        }
        Set<String> result = new Set<String>();
        for(String g : groups){
            result.add(g.trim());
        }
        return result;
    }

    public static Map<String, Group> getGroupsByDeveloperNames(Set<String> groupDeveloperNames){
        Map<String, Group> result = new Map<String, Group>();
        for(Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupDeveloperNames AND Type='Regular']){
            result.put(g.DeveloperName, g);
        }
        return result;
    }
}