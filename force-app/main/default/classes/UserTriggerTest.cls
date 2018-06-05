/**
 * Created by Arkadiusz Celej on 22.01.2018.
 */

@IsTest
private class UserTriggerTest {

    private static String marketGroup = User.EnabledForMarkets__c.getDescribe().getPicklistValues()[0].getValue();
    private static String[] groupNames = new String[]{'DEB_DEB_AA', 'DEB_DEB_BB', 'DEB_DEB_CC', marketGroup};
    private static Map<String, Group> groupsByNames = new Map<String, Group>();
    private static Group[] groups = NULL;

    private static void setupGroups(){
        groups = new List<Group>();
        for(String gn : groupNames) {
            Group g = new Group(Name = gn, DeveloperName = gn, Type = 'Regular');
            groups.add(g);
            groupsByNames.put(gn, g);
        }
        insert groups;
    }

    private static User createUserWithMarketsSOProgEnabled(Boolean toInsert){
        groupsByNames = new Map<String, Group>();
        User createdUser = TestDataFactory.createAdminUser(false);
        createdUser.EnabledForMarketSalesOfficeProgram__c = groupNames[0];
        if(toInsert) {
            insert createdUser;
        }

        return createdUser;
    }

    static testMethod void onUserCreationMembershipShouldBeCreated() {
        setupGroups();
        Test.startTest();
        User createdUser = TestDataFactory.createAdminUser(false);
        createdUser.EnabledForMarketSalesOfficeProgram__c = groupNames[2];
        insert createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id];
        System.assertEquals(1, userGroups.size());
        System.assertEquals(groupNames[2], userGroups[0].Group.DeveloperName);
    }


    static testMethod void shouldAddUserToGroupOnAddedMarket() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(true);
        createdUser.EnabledForMarketSalesOfficeProgram__c += UsersHelper.USER_GROUPS_SEPARATOR+groupNames[1];
        Test.startTest();
        update createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id];
        System.assertEquals(2, userGroups.size());
    }

    static testMethod void shouldUpdateUsersGroups() {
        setupGroups();
        User createdUser1 = createUserWithMarketsSOProgEnabled(true);
        User createdUser2 = createUserWithMarketsSOProgEnabled(true);
        createdUser1.EnabledForMarketSalesOfficeProgram__c = groupNames[2];
        createdUser2.EnabledForMarketSalesOfficeProgram__c += UsersHelper.USER_GROUPS_SEPARATOR+groupNames[1];
        Test.startTest();
        update new List<User>{createdUser1, createdUser2};
        Test.stopTest();

        GroupMember[] user1Groups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser1.Id];
        System.assertEquals(1, user1Groups.size());
        System.assertEquals(groupNames[2], user1Groups[0].Group.DeveloperName);

        GroupMember[] user2Groups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser2.Id ORDER BY Group.DeveloperName];
        System.assertEquals(2, user2Groups.size());
        System.assertEquals(groupNames[0], user2Groups[0].Group.DeveloperName);
        System.assertEquals(groupNames[1], user2Groups[1].Group.DeveloperName);
    }

    static testMethod void shouldRemoveUserFromGroupOnChange() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(true);
        createdUser.EnabledForMarketSalesOfficeProgram__c = groupNames[1];
        Test.startTest();
        update createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id];
        System.assertEquals(1, userGroups.size());
        System.assertEquals(groupNames[1], userGroups[0].Group.DeveloperName);
    }

    static testMethod void shouldRemoveUserFromGroupOnDeactivation() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(true);
        Test.startTest();
        createdUser.IsActive = false;
        update createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id];
        System.assertEquals(0, userGroups.size());
    }

    static testMethod void shouldAddUserToGroupOnActivation() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(true);
        createdUser.EnabledForMarketSalesOfficeProgram__c += UsersHelper.USER_GROUPS_SEPARATOR+' '+groupNames[1]+' '+UsersHelper.USER_GROUPS_SEPARATOR+'FAKE_GROUP'+UsersHelper.USER_GROUPS_SEPARATOR+''+UsersHelper.USER_GROUPS_SEPARATOR;
        createdUser.IsActive = false;
        update createdUser;
        Test.startTest();
        createdUser.IsActive = true;
        update createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id ORDER BY Group.DeveloperName];
        System.assertEquals(2, userGroups.size());
        System.assertEquals(groupNames[0], userGroups[0].Group.DeveloperName);
        System.assertEquals(groupNames[1], userGroups[1].Group.DeveloperName);
    }


    static testMethod void shouldAddUserToGroupOnEnabledMarkets() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(true);
        createdUser.EnabledForMarkets__c = marketGroup;
        createdUser.IsActive = false;
        update createdUser;
        Test.startTest();
        createdUser.IsActive = true;
        update createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id ORDER BY Group.DeveloperName];
        System.assertEquals(2, userGroups.size());
        System.assert(
                (marketGroup == userGroups[0].Group.DeveloperName && groupNames[0] == userGroups[1].Group.DeveloperName)
                        ||
                        (marketGroup == userGroups[1].Group.DeveloperName && groupNames[0] == userGroups[0].Group.DeveloperName)
        );
    }

    static testMethod void shouldAddUserToGroupOnInsertWithEnabledMarkets() {
        setupGroups();
        User createdUser = createUserWithMarketsSOProgEnabled(false);

        Test.startTest();
        createdUser.EnabledForMarkets__c = marketGroup;
        insert createdUser;
        Test.stopTest();

        GroupMember[] userGroups = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :createdUser.Id ORDER BY Group.DeveloperName];
        System.assertEquals(2, userGroups.size());
        System.assert(
                (marketGroup == userGroups[0].Group.DeveloperName && groupNames[0] == userGroups[1].Group.DeveloperName)
                        ||
                        (marketGroup == userGroups[1].Group.DeveloperName && groupNames[0] == userGroups[0].Group.DeveloperName)
        );
    }

}