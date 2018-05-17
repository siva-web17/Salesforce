/**
 * Created by thejasvi.a on 9/11/2017.
 * Records are loaded from Static Resources 'File_CampaignRecords'.
 */

@isTest(SeeAllData=false)
private class InviteToCampaignTest {
    private static Map<String,List<String>> campaignPicklistValues = new Map<String,List<String>>();
    public static String programFilter1 = 'ILSH';
    public static String programFilter2 = 'AY';
    public static String salesOffice1 = 'DEB';
    public static String salesOffice2 = 'DEF';
    public static String meetingType1 = 'ONM';
    public static String meetingType2 = 'INF';
    public static String meetingCity1 = 'Berlin';
    public static String meetingCity2 = 'Frankfurt';
    public static String market = 'DEB';
    public static final Integer initialLoadRecords = 8;
    public static final Integer programFilter1Size = 7;
    public static final Integer programFilter2Size = 8;
    public static final Integer programFilter3Size = 15;
    public static final Integer salesOffice1Size = 9;
    public static final Integer salesOffice2Size = 7;
    public static final Integer salesOffice3Size = 16;
    public static final Integer meetingType1Size = 7;
    public static final Integer meetingType2Size = 9;
    public static final Integer meetingType3Size = 16;
    public static final Integer meetingCity1Size = 6;
    public static final Integer meetingCity2Size = 10;
    public static final Integer meetingCity3Size = 16;
    public static final Integer dateToSize = 16;
    public static final Integer dateFromSize = 16;
    public static final Integer recordsWithoutFilterSize = 16;
    public static final Integer campaignSelectedSize = 2;
    public static final String testOpportunityName = 'TestOpportunityRecord';

    @testSetup static void setup(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(currentUser) {
            User tAdminUser = TestDataFactory.createAdminUser(True);
            Map<String, String> markets = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Market__c');
            List<String> products = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Product__c').values();
            List<String> salesOffices = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'SalesOffice__c').get(markets.values()[0]);
            List<String> Programs = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'Program__c').get(markets.values()[0]);
            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => market
            };
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, True);

            string dateValue = string.valueof(System.today());
            Map<String, String> opportunityFieldValues = new Map<String, String>{
                    'Market__c' => Market,
                    'Product__c' => products[0],
                    'SalesOffice__c' =>salesOffice1,
                    'Program__c' => programs[0],
                    'StageName' => 'Open',
                    'Closedate' => dateValue
            };
            Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues, True);
            Test.loadData(Campaign.sObjectType, 'File_CampaignRecords');
            InviteToCampaign.getMeetingTypes();
            InviteToCampaign.getMeetingCity(newOpportunityPersonAccount.id);
            InviteToCampaign.getProgram(newOpportunityPersonAccount.id);
            InviteToCampaign.getSalesOffice(newOpportunityPersonAccount.id);
            InviteToCampaign.getcampaigns();
            String  opportunityMarket = string.valueof(InviteToCampaign.getMarket(newOpportunityPersonAccount.id));
            string opportunityMarketValue = opportunityMarket.split('"')[1];
            system.assert(opportunityMarketValue == newOpportunityPersonAccount.Market__c,'getMarket() function does not return the right market');

        }
    }

    @isTest
    static void when_InitialLoad_LoadCampaignsWithMatchingMarketProgramAsOpportunity() {
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            List<InviteToCampaign.CampaignWrapper> camp =  InviteToCampaign.getInitialCampaignData(newOpportunity.Id,null);
            //Assert that checks if 12 records are loaded based on selected Market and Program
            System.assertEquals(initialLoadRecords, camp.size(),'The Campaigns are not loaded correctly during the initial load.');
        }
        Test.stopTest();
    }

    @isTest
    static void when_ProgramFiltered_DisplayRecordsThatBelongToProgram(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {

            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            String program1 = JSON.serialize(new String[]{programFilter1}); // Single program
            String program2= JSON.serialize(new String[]{programFilter2});
            String program3 = JSON.serialize(new List<String>{programFilter1,programFilter2}); // Multiple programs seprated by comma

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'',program1 ,'','',null,null);
            System.assertEquals(camp.size(),programFilter1Size, 'Campaigns are not filtered properly when Program Filter is '+ program1);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'',program2 ,'','',null,null);
            System.assertEquals(camp.size(),programFilter2Size,'Campaigns are not filtered properly when Program Filter is '+ program2);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'',program3 ,'','',null,null);
            System.assertEquals(camp.size(),programFilter3Size, 'Campaigns are not filtered properly when Program Filter is '+ program3);
        }
        Test.stopTest();
    }

    @isTest
    static void when_SalesOfficeFiltered_DisplayRecordsThatBelongToSalesOffice(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            string myJSONsalesoffice1 = JSON.serialize(new String[]{salesoffice1});
            string myJSONsalesoffice2 = JSON.serialize(new String[]{salesoffice2});
            string myJSONsalesoffice3 = JSON.serialize(new String[]{salesoffice1,salesoffice2});

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,myJSONsalesoffice1,'' ,'','',null,null);
            System.assertEquals(camp.size(),salesOffice1Size,'Campaigns are not filtered properly when SalesOffice Filter is '+ myJSONsalesoffice1);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,myJSONsalesoffice2,'','','',null,null);
            System.assertEquals(camp.size(),salesOffice2Size,'Campaigns are not filtered properly when SalesOffice Filter is '+ myJSONsalesoffice2);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,myJSONsalesoffice3,'','','',null,null);
            System.assertEquals(camp.size(),salesOffice3Size,'Campaigns are not filtered properly when SalesOffice Filter is '+ myJSONsalesoffice3);

        }
        Test.stopTest();
    }

    @isTest
    static void when_MeetingTypeFiltered_DisplayRecordsThatBelongToMeetingType() {
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            string myJSONmeetingType1 = JSON.serialize(new String[]{meetingType1});
            string myJSONmeetingType2 = JSON.serialize(new String[]{meetingType2});
            string myJSONmeetingType3 = JSON.serialize(new String[]{meetingType1,meetingType2});

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','' ,myJSONmeetingType1,'',null,null);
            System.assertEquals(camp.size(),meetingType1Size,'Campaigns are not filtered properly when MeetingType Filter is '+ myJSONmeetingType1);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','',myJSONmeetingType2,'',null,null);
            System.assertEquals(camp.size(),meetingType2Size,'Campaigns are not filtered properly when MeetingType Filter is '+ myJSONmeetingType2);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','',myJSONmeetingType3,'',null,null);
            System.assertEquals(camp.size(),meetingType3Size,'Campaigns are not filtered properly when MeetingType Filter is '+ myJSONmeetingType3);

        }
        Test.stopTest();
    }


    @isTest
    static void when_MeetingCityFiltered_DisplayRecordsThatBelongToMetingCity(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            string myJSONmeetingCity1 = JSON.serialize(new String[]{meetingCity1});
            string myJSONmeetingCity2 = JSON.serialize(new String[]{meetingCity2});
            string myJSONmeetingCity3 = JSON.serialize(new String[]{meetingCity1,meetingCity2});

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','','',myJSONmeetingCity1,null,null);
            System.assertEquals(camp.size(),meetingCity1Size,'Campaigns are not filtered properly when MeetingCity Filter is '+ myJSONmeetingCity1);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','','',myJSONmeetingCity2,null,null);
            System.assertEquals(camp.size(),meetingCity2Size,'Campaigns are not filtered properly when MeetingCity Filter is '+ myJSONmeetingCity2);

            camp = InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id,'','','',myJSONmeetingCity3,null,null);
            System.assertEquals(camp.size(),meetingCity3Size,'Campaigns are not filtered properly when MeetingCity Filter is '+ myJSONmeetingCity3);

        }
        Test.stopTest();
    }

    @isTest
    static void when_DateToFiltered_DisplayRecordsThatBelongToEnteredDate(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            Datetime dateto= DateTime.now().addyears(4);

            List<InviteToCampaign.CampaignWrapper> camp2= InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id, '', '', '', '',null, dateto);
            System.assertEquals(camp2.size(),dateToSize,'Campaigns are not filtered properly when DateTo Filter is '+ dateto);

        }
        Test.stopTest();
    }

    @isTest
    static void when_DateFromFiltered_DisplayRecordsThatBelongToEnteredDate(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            Datetime datefrom= DateTime.now().addHours(1);

            List<InviteToCampaign.CampaignWrapper> camp= InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id, '', '', '', '', datefrom, null);
            System.assertEquals(camp.size(),dateFromSize,'Campaigns are not filtered properly when DateFrom Filter is '+ datefrom);
        }
        Test.stopTest();
    }

    @isTest
    static void when_withoutAnyFilter_DisplayAllRecordsBasedonOpportunityMarketProgram(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity newOpportunity = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);

            List<InviteToCampaign.CampaignWrapper> camp= InviteToCampaign.getCampaignsWithFilter(newOpportunity.Id, '', '', '', '', null, null);
            System.assertEquals(camp.size(),recordsWithoutFilterSize,'Campaigns are not shown properly when there is no filter');

        }
        Test.stopTest();
    }

    @isTest
    static void when_OpportunitiesInvitedToCampaign_CampaignMembersShouldGetCreated(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            DateTime dateAndTime = DateTime.now();
            List<Campaign> campaignRecords =CampaignsSelector.queryCampaignRecords();
            string campaignRecordsAsJson = JSON.serialize(campaignRecords);
            Opportunity opportunityRecord = OpportunitiesSelector.getOpportunitiesOnName(new Set<String>{testOpportunityName}).get(0);
            InviteToCampaign.AddCampaigns(campaignRecordsAsJson ,opportunityRecord.Id);
            List<CampaignMember> campaignMembers =  CampaignMembersSelector.getCampaignMemberList(campaignRecords);
            System.assertEquals(campaignMembers.size(),campaignSelectedSize,'Campaign members are not invited properly');
        }
        Test.stopTest();
    }

    @isTest
    static void When_getInitialCampaignData_Expect_returnListSizeLimitedTo100AndOrderedByLastModifiedDate() {
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {

            List<Campaign> campaigns = new List<Campaign>();
            Integer numberOfRecords = 110;
            String campaignName = 'test Campaign';

            for (Integer i = 0; i < numberOfRecords; i++) {
                Map<String, String> campaignValues = new Map<String, String>{

                        'Market__c' => 'DEB',
                        'Program__c' => 'AY',
                        'Salesoffice__c' => 'DEB',
                        'Status' => 'Active',
                        'MeetingType__c' => 'ONM',
                        'MeetingCity__c' => 'Berlin',
                        'DateFrom__c' => String.valueOf(DateTime.now().addminutes(i)),
                        'DateTo__c' => String.valueOf(DateTime.now().addminutes(i))
                };
                Campaign campaignRecord = TestDataFactory.createCampaign(campaignName + i, campaignValues, False);
                campaigns.add(campaignRecord);
            }
            insert campaigns;

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = new Opportunity();
            opp = (Opportunity) oppBuilder.withPersonAccount().getRecord();
            opp.IsActive__c = true;
            opp.Market__c = '';
            opp.Program__c = '';
            insert opp;

            Datetime dateFrom = DateTime.now();

            Test.startTest();

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getInitialCampaignData(opp.Id, dateFrom);

            Test.stopTest();

            System.assert(camp.size() == 100, 'Limit 100 as expected');
            System.assert(camp[50].objWrapperCampaign.DateFrom__c < camp[60].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
            System.assert(camp[60].objWrapperCampaign.DateFrom__c < camp[70].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
            System.assert(camp[70].objWrapperCampaign.DateFrom__c < camp[80].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
        }
    }

    @isTest
    static void When_getCampaignsWithFilter_Expect_returnListSizeLimitedTo100AndOrderedByLastModifiedDate() {
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {

            List<Campaign> campaigns = new List<Campaign>();
            Integer numberOfRecords = 110;
            String campaignName = 'test Campaign';

            for (Integer i = 0; i < numberOfRecords; i++) {
                Map<String, String> campaignValues = new Map<String, String>{

                        'Market__c' => 'DEB',
                        'Program__c' => 'AY',
                        'Salesoffice__c' => 'DEB',
                        'Status' => 'Active',
                        'MeetingType__c' => 'ONM',
                        'MeetingCity__c' => 'Berlin',
                        'DateFrom__c' => String.valueOf(DateTime.now().addminutes(i)),
                        'DateTo__c' => String.valueOf(DateTime.now().addminutes(i))
                };
                Campaign campaignRecord = TestDataFactory.createCampaign(campaignName + i, campaignValues, False);
                campaigns.add(campaignRecord);
            }
            insert campaigns;

            TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
            Opportunity opp = new Opportunity();
            opp = (Opportunity) oppBuilder.withPersonAccount().getRecord();
            opp.IsActive__c = true;
            opp.Market__c = '';
            opp.Program__c = '';
            insert opp;

            Datetime dateFrom= DateTime.now();
            Datetime dateTo= DateTime.now().addYears(1);

            Test.startTest();

            List<InviteToCampaign.CampaignWrapper> camp = InviteToCampaign.getCampaignsWithFilter(opp.Id,null,null,null,null,dateFrom,dateTo);

            Test.stopTest();

            System.assert(camp.size() == 100, 'Limit 100 as expected');
            System.assert(camp[50].objWrapperCampaign.DateFrom__c < camp[60].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
            System.assert(camp[60].objWrapperCampaign.DateFrom__c < camp[70].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
            System.assert(camp[70].objWrapperCampaign.DateFrom__c < camp[80].objWrapperCampaign.DateFrom__c, 'OrderBy LastModifiedDate');
        }
    }
}