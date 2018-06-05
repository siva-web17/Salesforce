/**
 * Created by Arkadiusz Celej on 22.01.2018.
 */

public class GroupMembersSelector {
    
    public static GroupMember[] getGroupMembersByUserIds(Set<Id> userIds){
        return [
                SELECT GroupId, UserOrGroupId, Group.DeveloperName
                FROM GroupMember
                WHERE UserOrGroupId IN :userIds
        ];
    }
}