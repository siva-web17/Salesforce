/**************************************************************************************
Apex Class Name    : publicGroupsSelector
Version            : 1.0
Created Date       : June 09 2017
Function           : return the details of public groups here.
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/09/2017              Original Version
 *************************************************************************************/
public class PublicGroupsSelector {
    
    //For getting details of public groups.
    public static Map<String, Id> getRegularPublicGroupsByName(List<String> groupNameList){
        List<Group> publicGroupList = new List<Group>();
        publicGroupList = [Select Id, Name
                           from Group
                           where type = 'Regular'
                           and name in :groupNameList];

        Map<String,ID> publicGroupMap= new Map<String,ID>();
        for(Group grp:publicGroupList){
            publicGroupMap.put(grp.name,grp.ID);
        }
        return publicGroupMap;
    }

    public static list<Group> getPublicGroupsByNameAndType(String developerName, String type){
        list<Group> publicGroup = [Select Id, Name, DeveloperName
                                   from Group where type = :type and DeveloperName = :developerName
                                   LIMIT 1];
        return publicGroup ;
    }
}