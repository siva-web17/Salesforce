/**************************************************************************************
 Apex Class Name    : TestDataFactory
 Version            : 1.0
 Created Date       : Oct 10 2017
 Function           : Factory class for Creating  TestData.
 Modification Log   : Draft created by Manos
 -----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Manos S                  25/10/2017              Original Version
 *************************************************************************************/

@isTest
public class TestDataFactory {
    public static string suffix;

    private static final String EMAIL_SUFFIX = '@ef.com.lang.dev.tst';
    private static final String USERNAME_SUFFIX = '@ef.com.lang.dev.tst';
    private static Integer countUsersCreated = 0; //Use this to avoid duplicate Test User names

    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Creates an admin user with 'default' values for required fields
    *
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static User createAdminUser(boolean doInsert) {
        Profile uProfile = getProfile(Label.ProfileSystemAdmin, true);
        if (uProfile==null)
            return null;

        Long i = System.Now().getTime();
        User tUser = new User();
        tUser.ProfileId = uProfile.Id;
        tUser.alias = 'admnTU';
        tUser.email = tUser.alias + EMAIL_SUFFIX;
        tUser.emailencodingkey = 'UTF-8';
        tUser.lastname = 'admTU'+system.now();
        tUser.languagelocalekey = 'en_US';
        tUser.localesidkey = 'en_US';
        tUser.timezonesidkey = 'Europe/Berlin';
        tUser.username = 'TestAdmin'+ i + '_'+(++countUsersCreated) + USERNAME_SUFFIX;
        system.debug('tUser.username:'+ tUser.username);
        if (doInsert)
            insert tUser;

        system.debug('User:'+tUser);
        return tUser;
    }
    /****************************************************************************************************/


   /********************************************************************************************************************************
    *
    * ver 1.0 2017.12.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create the Bypass Custom Setting for a List of Users
    *
    * @param bypassValidations true we want to bypass Validations for these Users
    * @param bypassTriggers true we want to bypass Triggers for these Users
    *
    */
    
    public static void bypassValidationsTriggersForUsers(Set<String> userIds, boolean bypassValidations, boolean bypassTriggers)
    {
        List<BypassTriggersValidation__c> bpTrValids = new List<BypassTriggersValidation__c>();
        for (String uId:userIds)
        {
            bypassTriggersValidation__c bpv=new BypassTriggersValidation__c();
            bpv.DisableTrigger__c = bypassTriggers;
            bpv.DisableValidation__c =bypassValidations; 
            bpv.SetupOwnerId=uId;
            bpTrValids.add(bpv);
            
        }
        if (bpTrValids.size()>0)
        {
            insert bpTrValids;
        }
    }
    /****************************************************************************************************/
    
    
    /**** PLEASE REMOVE THESE METHODS !!! !THEY DON'T BELONG HERE THEY SHOULD BE SELECTORS IF REQUIRED !!! 
    
    
    public static Group getRegularTypeGroupByLabel(string developerName){
    
     Group publicGroup = [select id,name,DeveloperName from Group where type='Regular' and DeveloperName = :developerName LIMIT 1];
     return publicGroup ;
    }
    /*****************************************************************************************************
    public static user getGroupmemberbyGroup(group publicGroup){
     GroupMember member = [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id LIMIT 1];
            User user = [SELECT Id,Name FROM User WHERE Id = :member.UserOrGroupId LIMIT 1];
            return user;
    }
    
    */
    
    
    
    
    
    
    
    
    
    
    
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Creates a User with the given profile name. If the profile doesn't exist it will not continue and will return null
    *
    * @param strProfileName The required profile name
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static User createUser(String strProfileName, boolean doInsert) {

        Profile uProfile = getProfile(strProfileName,false);
        if (uProfile==null)
            return null;

        User tUser = new User();
        tUser.ProfileId = uProfile.Id;
        tUser.alias = 'TUsr'+countUsersCreated;
        tUser.email = tUser.alias + EMAIL_SUFFIX;
        tUser.emailencodingkey = 'UTF-8';
        tUser.lastname = 'cdtUsr'+system.now();
        tUser.languagelocalekey = 'en_US';
        tUser.localesidkey = 'en_US';
        tUser.timezonesidkey = 'Europe/Berlin';
        tUser.username = 'TestUser'+ (countUsersCreated++) + USERNAME_SUFFIX;

        if (doInsert)
            insert tUser;

        system.debug('User:'+tUser);
        return tUser;
    }
    /*********************************************************************************************************************************/

    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Return the profile with the name specified in the input parameter. If the parameter onMisMatchReturnAdmin is set to true it will
    *                    return the default Salesforce system administrator profile (provided it exists !!!)
    *
    * @param strProfileName The required profile name
    * @param onMisMatchReturnAdmin Boolean to return the system administrator profile in case the required profile name is not found
    *
    */
    public static Profile getProfile(String strProfileName, boolean onMisMatchReturnAdmin) {
        profile p = new profile();
        try {
            p = [SELECT Id, Name FROM profile WHERE name like :strProfileName LIMIT 1];
        }
        catch (system.Queryexception exc) {
            if (onMisMatchReturnAdmin)
                p = [SELECT Id, Name FROM profile WHERE name like 'system%administrator' LIMIT 1];
        }

        system.debug('Profile:' +p);

        return  p;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
     *
     * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
     *
     *                    Create a Lead with specified parameters
     *
     * @param strFirstName Lead first name
     * @param strLastName Lead last name
     * @param strCompanyName Lead company name HINT:leave empty in case you plan to convert to Person Account
     * @param strRecordTypeId The recordtypeId of the to be created accounts
     * @param doInsert true if the method should also insert the object,
     *                 if set to false no DML operations will be executed
     *
     */
    public static Lead createLead(String strFirstName, String strLastName, String strCompanyName, String strRecordTypeId, boolean doInsert) {
        Lead tLead = new Lead();

        tLead.FirstName = strFirstName;
        tLead.LastName = strLastName;
        tLead.Company = strCompanyName;

        String strEmail = strFirstName  + 'test' + strLastName + EMAIL_SUFFIX ;
        tLead.Email = strEmail.trim().replaceAll(' ', '_');

        if (doInsert)
            insert tLead;
        return tLead;
    }
    /*********************************************************************************************************************************/
    
      /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.31 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create a Campaign with specified parameters
    *
    * @param strCampaignName Account name
    * @param mFieldNameToVal a map to specify additional fields during the Campaign creation. Map Key is the field API name and Map value the respective field value.
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Lead createLead(String strFirstName, String strLastName, String strCompanyName, String strRecordTypeId, Map<String, String> mFieldNameToVal,boolean doInsert) {
        Lead tLead = createLead(strFirstName,strLastName,strCompanyName,strRecordTypeId,doInsert);
        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Lead.fields.getMap();
        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)
                    tLead.put(strFieldName, Date.valueOf(strVal) );
                else
                        tLead.put(strFieldName, strVal);
            }
        }

        if(doInsert){
            update tLead;
        }

        return tLead;
    }


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create an account with specified parameters
    *
    * @param strAccountName Account name
    * @param strRecordTypeId The recordtypeId of the to be created accounts
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Account createAccount(String strAccountName, String strRecordTypeId,boolean doInsert) {
        Account tAccount = new Account();
        tAccount.name = strAccountName;
       // tAccount.RecordTypeId=strRecordTypeId;
        if (doInsert)
            insert tAccount;
        return tAccount;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    * @param strAccountName Account name
    * @param strRecordTypeId The recordtypeId of the to be created accounts
    * @param mFieldNameToVal a map to specify additional fields during the Account creation. Map Key is the field API name and Map value the respective field value.
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Account createAccount(String strAccountName,  Map<String, String> mFieldNameToVal,boolean doInsert) {
        Account tAccount = new Account();
        tAccount.name = strAccountName;

        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Account.fields.getMap();
        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)

                    tAccount.put(strFieldName, Date.valueOf(strVal) );
                else
                    tAccount.put(strFieldName, strVal);
            }
        }

        if (doInsert)
            insert tAccount;
        return tAccount;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Creates numAccounts with the given prefix as the name, and the specified recordtypeId
    *
    * @param strAccountName the prefix for the created accounts. Full name would be strAccountName + ' ' + counter
    * @param strRecordTypeId The recordtypeId of the accounts to be created
    * @param numAccounts the number of accounts to be created
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static List<Account> createAccounts(String strAccountName, String strRecordTypeId, Integer numAccounts, boolean doInsert) {

        List<Account> lAccounts = new List<Account>();

        for (Integer i=0;i<numAccounts;i++)
        {
            Account tAccount = createAccount(strAccountName+ ' ' + i,strRecordTypeId,false);
            lAccounts.add(tAccount);
        }

        if (doInsert && lAccounts.size()>0)
            insert lAccounts;
        return lAccounts;
    }
    /*********************************************************************************************************************************/


    /*******************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create a Business Account with a Contact. Returns the created Account
    *
    * @param strAccountName The name of the Account
    * @param strAccountRecordTypeId the record type of the Account
    * @param strContactFirstName the first name of the contact
    * @param strContactLastName the last name of the contact
    * @param strContactRecordTypeId the record type id of the contact
    *
    */
    public static Account createAccountWithContact(String strAccountName, String strAccountRecordTypeId, String strContactFirstName, String strContactLastName, String strContactRecordTypeId) {
        Account tAccount = createAccount(strAccountName,strAccountRecordTypeId,true);
        Contact tContact = new Contact();
        insert tContact;
        return tAccount;

    }
    /*********************************************************************************************************************************/


    /*******************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create  Accounts with Opportunities. Returns the Accounts created
    *
    * @param numAccounts The number of Accounts to create
    * @param strAccountNamePrefix the Prefix of the account name. The final name will be Prefix + Iterator
    * @param mAccountFieldNameToVal a map to specify additional fields during the Account creation. Map Key is the field API name and Map value the respective field value.
    * @param numOppsPerAccount The number of Opportunities per Account to create
    * @param strOppNamePrefix the Prefix of the Opportunity name. The final name will be Prefix + '-' + Account.Name + Iterator
    * @param mOppFieldNameToVal a map to specify additional fields during the Opportunity creation. Map Key is the field API name and Map value the respective field value.
    *
    */
    public static List<Account> createAccountsWithOpportunities(Integer numAccounts, String strAccountNamePrefix, Map<String,String> mAccountFieldNameToVal,
                                                                Integer numOppsPerAccount, String strOppNamePrefix, Map<String,String> mOppFieldNameToVal)
    {

        List<Account> tAccounts = new List<Account>();
        for(Integer i=0;i<numAccounts;i++) {
            Account tAccount = createAccount(strAccountNamePrefix + ' ' + i,  mAccountFieldNameToVal,true);
            tAccounts.add(tAccount);
        }
        if (tAccounts.size()>0)
            insert tAccounts;


        List<Opportunity> tOpps = new List<Opportunity>();

        for (Integer j=0;j<numAccounts;j++) {
            Account tAccount = tAccounts[j];
            // For each account just inserted, add opportunities
            for (Integer k=0;k<numOppsPerAccount;k++) {
                Opportunity tOpp = createOpportunityForAccount(tAccount.Id,strOppNamePrefix + ' - ' + tAccount.name + ' ' + k ,mOppFieldNameToVal, false);
                tOpps.add(tOpp);
            }
        }
        // Insert all opportunities for all accounts.

        if(tOpps.size()>0)
            insert tOpps;

        return tAccounts;
    }
    /*********************************************************************************************************************************/


    /*******************************************************************************************************************************
    *
    * ver 1.0 2017.10.27 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Creates an Opportunity with specified parameters for the Account strAccountId
    *
    * @param strAccountId The related Account Id
    * @param strOpportunityName the Opportunity name    
    * @param mFieldNameToVal a map to specify additional fields during the Opportunity creation. Map Key is the field API name and Map value the respective field value.
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    */
    public static Opportunity createOpportunityForAccount(String strAccountId,String strOpportunityName, Map<String, String> mFieldNameToVal, boolean doInsert ) {
        Opportunity tOpp = new Opportunity();
        tOpp.name = strOpportunityName;
        tOpp.AccountId= strAccountId;

        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Opportunity.fields.getMap();

        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)

                    tOpp.put(strFieldName, Date.valueOf(strVal) );
                else
                    tOpp.put(strFieldName, strVal);
            }
        }
        if (doInsert)
            insert tOpp;
        return tOpp;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.31 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create a Campaign with specified parameters
    *
    * @param strCampaignName Account name
    * @param strRecordTypeId The recordtypeId of the to be created accounts
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Campaign createCampaign(String strCampaignName, String strRecordTypeId,boolean doInsert) {
        Campaign tCampaign = new Campaign();
        tCampaign.name = strCampaignName;
        tCampaign.RecordTypeId=strRecordTypeId;
        tCampaign.isActive = true;
        tCampaign.dateFrom__c = Date.today().addDays(5);
        tCampaign.dateTo__c = tCampaign.dateFrom__c.addHours(1);
        if (doInsert)
            insert tCampaign;
        return tCampaign;
    }
    /*********************************************************************************************************************************/

    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.31 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create a Campaign with specified parameters
    *
    * @param strCampaignName Account name
    * @param mFieldNameToVal a map to specify additional fields during the Campaign creation. Map Key is the field API name and Map value the respective field value.
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Campaign createCampaign(String strCampaignName, Map<String, String> mFieldNameToVal,boolean doInsert) {
        Campaign tCampaign = new Campaign();
        tCampaign.name = strCampaignName;

        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Campaign.fields.getMap();

        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.DateTime)

                    tCampaign.put(strFieldName, DateTime.valueOf(strVal)); else
                        tCampaign.put(strFieldName, strVal);
            }
        }
        if (doInsert)
            insert tCampaign;
        return tCampaign;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.10.31 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    *                    Create a Campaign with specified parameters
    *
    * @param strCampaignId Related Campaign Id
    * @param lPersonAccountsToAdd The list of Person Accounts to be added as Campaign Members
    * @param strCampaignMemberStatus The campaign member status
    * @param doInsert true if the method should also insert the Campaign Members,
    *                                if set to false no DML operations will be executed
    *
    */
    public static List<CampaignMember> createCampaignMembersForCampaign(String strCampaignId,
                                                                        List<Account> lPersonAccountsToAdd,
                                                                        String strCampaignMemberStatus,
                                                                        boolean doInsert) {
        List<CampaignMember> lCampaignMembers = new List<CampaignMember>();

        if (lPersonAccountsToAdd.size()>0) {
            for (Integer i = 0; i<lPersonAccountsToAdd.size(); i++) {
                CampaignMember tCampaignMember = new CampaignMember();
                tCampaignMember.CampaignId = strCampaignId;
                tCampaignMember.contactId = lPersonAccountsToAdd[i].personContactId;
                tCampaignMember.Status = strCampaignMemberStatus;
                lCampaignMembers.add(tCampaignMember);
            }
        }

        if (doInsert &&  lCampaignMembers.size() >0)
            insert lCampaignMembers;
        return lCampaignMembers;
    }

    public static campaign createNewCampaign() {
        DateTime dateAndTime = DateTime.now();
        system.debug('dateAndTime' + dateAndTime);
        campaign newCampaignRecord = new campaign();
        newCampaignRecord.name = 'TestClass1';
        List<String> markets = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Market__c').values();
        if (markets != null && markets.size() > 0) {
            newCampaignRecord.Market__c = markets[0];
        }
        List<String> product = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Product__c').values();
        if (product != null && product.size() > 0) {
            newCampaignRecord.Product__c = product[0];
        }
        List<String> MeetingType = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'MeetingType__c').values();
        if (MeetingType != null && MeetingType.size() > 0) {
            newCampaignRecord.MeetingType__c = MeetingType[0];
        }
        newCampaignRecord.DateFrom__c = dateAndTime.addHours(3);
        newCampaignRecord.DateTo__c = dateAndTime.addHours(5);
        newCampaignRecord.MeetingSize__c = 10;
        newCampaignRecord.SendtoEFCOM__c = true;
        newCampaignRecord.Description = 'Test record';
        newCampaignRecord.SalesOffice__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'SalesOffice__c').get(markets[0])[0];
        newCampaignRecord.MeetingCity__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'MeetingCity__c').get(markets[0])[0];
        newCampaignRecord.EFCOMMarket__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'EFCOMMarket__c').get(markets[0])[0];
        return newCampaignRecord;
    }

    /*
    * ver 1.0 07-dec-2017
    * @author Arkadiusz Celej
    *
    * Method creates and returns task record.
    *
    * @param opportunityId Task parent ID
    * @param taskRecordTypeId Task RecordTypeId
    * @param subject Subject
    * @param taskType Type of task
    * @param toInsert To insert or to not Insert
    * */
    public static Task createTaskForSobject(Id recordid, Map<String, String> mFieldNameToVal, Boolean toInsert){
        Task tTask = new Task();
        if (String.valueOf(recordId).substring(0, 3) == '006') {
            tTask.WhatId = recordId;
        } else if (String.valueOf(recordId).substring(0, 3) == '00Q') {
            tTask.WhoId = recordId;
        }
        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Task.fields.getMap();

        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)
                    tTask.put(strFieldName, Date.valueOf(strVal) );
                else
                    tTask.put(strFieldName, strVal);
            }
        }
        if(toInsert){
            insert tTask;
        }
        return tTask;
    }

    /*** METHODS FOR CREATING CUSTOM SETTINGS GO HERE ****/



    /*****   ***/
     /********************************************************************************************************************************
    *
    * ver 1.0 2017.12.15 Thejasvi <thejasvi.a@ef.com>
    *
    *                    Create an account with specified parameters
    *
    * @param strAccountName Account name
    * @param strRecordTypeId The recordtypeId of the to be created accounts
    * @param doInsert true if the method should also insert the object,
    *                 if set to false no DML operations will be executed
    *
    */
    public static Account createPersonAccount(String strAccountFirstName,String strAccountLastName, String strRecordTypeId, Map<String, String> mFieldNameToVal,boolean doInsert) {
        Account tAccount = new Account();
        tAccount.FirstName = strAccountFirstName;
        tAccount.LastName = strAccountLastName;
        tAccount.RecordTypeId=strRecordTypeId;
        
        Map<String, Schema.SObjectField> mSobjFields = Schema.SObjectType.Account.fields.getMap();
        if (mFieldNameToVal != null) {
            for (String strFieldName : mFieldNameToVal.keySet()) {
                String strVal = mFieldNameToVal.get(strFieldName);

                //Might require to  do the same for other data types !
                if (mSobjFields.get(strFieldName).getDescribe().getType() == Schema.DisplayType.Date)

                    tAccount.put(strFieldName, Date.valueOf(strVal) );
                else
                    tAccount.put(strFieldName, strVal);
            }
        }

        if (doInsert)
            insert tAccount;
        return tAccount;
    }
    /*********************************************************************************************************************************/


    /**
    * @uathor Arkadiusz Celej
    *
    * Set of builder classes used in Unit tests
    * */

    public class OpportunityBuilder extends RecordBuilder {
        private Account account;
        public OpportunityBuilder() {
            super(Opportunity.SObjectType);
        }

        override
        private void setDefaultFieldValues(){
            this.setField('Name', 'Test Opportunity '+RecordBuilderCounter).setField('StageName','Prospecting').setField('CloseDate', System.today());
            this.setField('IsActive__c', true);
        }

        public RecordBuilder withPersonAccount(String firstName, String lastName){
            PersonAccountBuilder pab = new PersonAccountBuilder();
            pab.setField('FirstName', firstName).setField('LastName', lastName);
            pab.setField('Market__c', this.record.get('Market__c'));
            pab.setField('PersonBirthdate', System.today().addYears(-50));
            this.account = (Account)pab.getRecord();
            return this;
        }

        override
        public RecordBuilder save(){
            if(this.account != NULL) {
                upsert this.account;
                this.setField('AccountId', this.account.Id);
            }
            upsert this.record;
            return this;
        }

        public RecordBuilder withPersonAccount(){
            return this.withPersonAccount('TestFirstName'+RecordBuilderCounter, 'TestLastName'+RecordBuilderCounter);
        }

        public Account getAccount(){
            return this.account;
        }
    }

    public class CongaTemplateBuilder extends RecordBuilder {
        public CongaTemplateBuilder() {
            super(APXTConga4__Conga_Template__c.SObjectType);
        }

        override
        private void setDefaultFieldValues(){

        }

        public CongaTemplateBuilder withType(String val){
            this.setField('APXTConga4__Template_Type__c', val);
            return this;
        }

        public CongaTemplateBuilder withMarket(String val){
            this.setField('Market__c', val);
            return this;
        }

        public CongaTemplateBuilder withLanguage(String val){
            this.setField('Language__c', val);
            return this;
        }

        public CongaTemplateBuilder withProgram(String val){
            this.setField('Program__c', val);
            return this;
        }
    }

    public class TemplateSettingBuilder extends RecordBuilder {
        public APXTConga4__Conga_Template__c templateLetter;
        public APXTConga4__Conga_Template__c templateLabel;
        public TemplateSettingBuilder() {
            super(TemplateSetting__c.SObjectType);
        }

        override
        private void setDefaultFieldValues(){

        }

        override
        public RecordBuilder save(){
            if(templateLetter != null){
                upsert templateLetter;
                this.setField('Letter__c', templateLetter.Id);
            }
            if(templateLabel != null){
                upsert templateLabel;
                this.setField('Label__c', templateLabel.Id);
            }

            upsert this.record;

            return this;
        }

        public RecordBuilder withAge(Integer age){
            this.setField('AgeFromYears__c', age-1);
            this.setField('AgeToYears__c', age+1);
            this.setField('AgeFromMonths__c', 8);
            this.setField('AgeToMonths__c', 8);
            return this;
        }
        public RecordBuilder withLetter() {
            CongaTemplateBuilder ctb = new CongaTemplateBuilder();
            TemplateSetting__c r = (TemplateSetting__c)this.record;
            ctb.withType('Letter').withLanguage(r.Language__c).withMarket(r.Market__c).withProgram(r.Program__c);
            this.templateLetter = (APXTConga4__Conga_Template__c)ctb.getRecord();
            return this;
        }
        public RecordBuilder withLabel() {
            CongaTemplateBuilder ctb = new CongaTemplateBuilder();
            TemplateSetting__c r = (TemplateSetting__c)this.record;
            ctb.withType('Label').withLanguage(r.Language__c).withMarket(r.Market__c).withProgram(r.Program__c);
            this.templateLabel = (APXTConga4__Conga_Template__c)ctb.getRecord();
            return this;
        }
    }

    public class PersonAccountBuilder extends RecordBuilder{
        public PersonAccountBuilder(){
            super(Account.SObjectType);
        }

        override
        private void setDefaultFieldValues(){
            this.withRecordType('PersonAccount');
        }
    }

    public class CampaignBuilder extends RecordBuilder{
        public CampaignBuilder(){
            super(Campaign.SObjectType);
        }

        override
        private void setDefaultFieldValues(){
            Datetime tomorrow = System.today().addDays(1);
            this.setField('Name', 'Test '+RecordBuilderCounter);
            this.setField('DateFrom__c', tomorrow.addHours(1));
            this.setField('DateTo__c', tomorrow.addHours(2));
        }
    }

    public class LeadBuilder extends RecordBuilder{
        public List<Task> tasks = new List<Task>();

        public LeadBuilder(){
            super(Lead.SObjectType);
        }

        override
        private void setDefaultFieldValues(){
            this.setField('FirstName', 'Test ');
            this.setField('LastName', 'Test Lead '+RecordBuilderCounter);
            this.setField('Email', 'testEmail'+RecordBuilderCounter+'@email'+RecordBuilderCounter+'.com');
            if(this.picklistHelper != NULL){
                this.setField('Market__c', this.picklistHelper.market);
                this.setField('SalesOffice__c', this.picklistHelper.salesOffice);
                this.setField('Program__c', this.picklistHelper.program);
                this.setField('Product__c', this.picklistHelper.product);
            }

        }

        public RecordBuilder withSystemCallTask(){
            return this;
        }
    }

    public class TaskBuilder extends RecordBuilder{

        final String reachedSalesAction = 'Call reached';
        final TaskStatus[] closedStatuses = [select MasterLabel from TaskStatus WHERE IsClosed=TRUE];

        public TaskBuilder(){
            super(Task.SObjectType);
        }

        override
        public void setDefaultFieldValues(){
            this.setField('Subject', 'Test Task - '+RecordBuilderCounter);
        }

        public TaskBuilder closeTask(){
            this.setField('Status', this.closedStatuses[0].MasterLabel);
            return this;
        }

        public TaskBuilder reachedTask(){
            this.setField('SalesAction__c', reachedSalesAction);
            return this;
        }

        public TaskBuilder setWho(Id whoId){
            this.setField('WhoId', whoId);
            return this;
        }

        public TaskBuilder setWhat(Id whatId){
            this.setField('WhatId', whatId);
            return this;
        }
    }

    public class DefaultPicklistValuesHelper{
        public String market;
        public String salesOffice;
        public String product;
        public String program;
        public String program2;
        public String language;

        public DefaultPicklistValuesHelper(){
            String[] values = Label.TestDependentPicklistValues.split(';');
            this.market = values[0];
            this.salesOffice = values[1];
            this.product = values[2];
            this.program = values[3];
            this.program2 = values[4];
            this.language = values[5];
        }
    }

    public static Integer RecordBuilderCounter = 0;
    public abstract class RecordBuilder {
        private SObject record;
        private Schema.SObjectType objectType;
        private Map<String, Schema.SObjectField> fieldsMap;

        public DefaultPicklistValuesHelper picklistHelper;

        protected RecordBuilder(Schema.SObjectType objectType){
            this.objectType = objectType;
            this.build();
        }

        protected void init() {
            this.fieldsMap = this.objectType.getDescribe().fields.getMap();
            this.record = this.objectType.newSObject();
        }

        abstract void setDefaultFieldValues();

        public void setDefaultPicklistHelper(DefaultPicklistValuesHelper helper){
            this.picklistHelper = helper;
        }

        public virtual RecordBuilder save() {
            upsert record;
            return this;
        }

        public sObject getRecord() {
            return this.record;
        }

        public RecordBuilder build() {
            RecordBuilderCounter++;
            this.init();
            this.setDefaultFieldValues();
            return this;
        }

        public RecordBuilder withRecordType(String recordType){
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(this.objectType).get(recordType).Id;
            this.setField('RecordTypeId', recordTypeId);
            return this;
        }

        public RecordBuilder setField(String fieldName, Object fieldValue) {
            if(this.fieldsMap.containsKey(fieldName)) {
                this.record.put(fieldName, fieldValue);
            }else{
                throw new RecordBuilderException(this.record.getSObjectType()+ ' does not have '+fieldName+' field.');
            }
            return this;
        }

        public RecordBuilder setFields(Map<String, Object> fieldsToSet) {
            for (String fieldName : fieldsToSet.keySet()) {
                this.setField(fieldName, fieldsToSet.get(fieldName));
            }
            return this;
        }
    }

    public class RecordBuilderException extends Exception{}

    /***** END of Set of builder classes used in Unit tests ***********/
}