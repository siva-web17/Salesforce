/**
 * Created by aditi.sharma on 12/27/2017.
 */
@IsTest(seealldata=false)
private class LogACallControllerTest {
    private static String market = 'DEB';
    private static String salesOffice1 = 'DEB';
    private static String gender = 'Male';
    private static String language='DE';
    private static String nationality ='DE';
    private static String creationMethod='EnteredByUser';
    private static String openStage='Open';
    private static String salesClosedStage='Sales Closed';
    private static List<String> likelihoodToBookOptions;
    private static List<String> hearAboutUsOptions;
    private static List<String> destinations;
    private static List<String> preferredDurations;
    private static List<String> closeReasons;
    private static List<String> programs;
    private static List<String> salesActions;
    private static List<String> callResults;
    private static List<string> subActions;

    public static final String testOpportunityName = 'TestOpportunityRecord';
    public static List<LogACallTestInput> logACallTestInputs ;
    @testsetup static void setup(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(currentUser) {
            User tAdminUser = TestDataFactory.createAdminUser(True);
            Lead lead = createLeadRecord();
            Opportunity opp1 = createOpportunityRecord(openStage);
            Opportunity opp2 = createOpportunityRecord(salesClosedStage);
            Destination__c destination1 = new Destination__c();
            destination1.IsLT__c = true;
            destination1.GroupedLTDestinationName__c = 'Destination1';
            insert destination1;
            Destination__c destination2 = new Destination__c();
            destination2.IsLT__c = false;
            destination2.GroupedLTDestinationName__c = 'Destination2';
            insert destination2;
        }
    }
    public static void setupPicklistValues(Id recordId){
        LogACallController.getInitialData(recordid);
        likelihoodToBookOptions = (List<String>)JSON.deserialize(LogACallController.getLikelihoodToBookOptions(recordid),List<String>.class);
        hearAboutUsOptions = (List<String>)JSON.deserialize(LogACallController.getHearAboutUsOptions(recordid),List<String>.class);
        destinations = LogACallController.getDestinations(recordid);
        programs = LogACallController.getProgramsForChange(recordid);
        preferredDurations = LogACallController.getDurations(recordid,'');
        closeReasons = (List<String>)JSON.deserialize(LogACallController.getCloseReasons(recordid),List<String>.class);
        LogACallController.isCustomerReached(recordid);
        subActions = (List<String>)JSON.deserialize(LogACallController.getSubActions(),List<String>.class);
        salesActions = (List<String>)JSON.deserialize(LogACallController.getSalesActions(),List<String>.class);
        callResults =  (List<String>)JSON.deserialize(LogACallController.getCallResults(Label.CallNotReached,recordId),List<String>.class);
        logACallTestInputs  = new List<LogACallTestInput>
        {
                new LogACallTestInput(Label.CallReached,'','comments', Label.CallBack,system.now(),closeReasons[0],recordId,programs[0],system.now(),likelihoodToBookOptions[0],hearAboutUsOptions[0],'','','','',system.now())
        };
    }

    public static lead createLeadRecord(){
        Map<String, String> markets = FieldUtilityClass.getPickListValues(Lead.getSObjectType(), 'Market__c');
        List<String> Programs = FieldUtilityClass.getFieldDependencies('Lead', 'Market__c', 'Program__c').get(markets.values()[0]);
        Map<String, String> leadFieldValues = new Map<String,String>{
                    'Market__c'=>market,
                    'Program__c'=>Programs[0],
                    'SalesOffice__c' =>salesOffice1,
                    'Gender__c'=>gender,
                    'Language__c'=>language,
                    'Nationality__c'=>nationality,
                    'CreationMethod__c'=>creationMethod
                };
        return TestDataFactory.createLead('LoganAction', 'Test', 'EF', '',leadFieldValues, true);
    }
    public static opportunity createOpportunityRecord(String stageName){
        Map<String, String> markets = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Market__c');
        List<String> products = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'Product__c').values();
        List<String> salesOffices = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'SalesOffice__c').get(markets.values()[0]);
        List<String> Programs = FieldUtilityClass.getFieldDependencies('Opportunity', 'Market__c', 'Program__c').get(markets.values()[0]);
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
                'StageName' => stageName,
                'Closedate' => dateValue
        };
        Opportunity opp =  TestDataFactory.createOpportunityForAccount(newAccount.id, testOpportunityName, opportunityFieldValues, True);
        return opp;
    }

    static testMethod void testSaveDataForOpportunity(){
        User tAdminUser = [SELECT Id,Name FROM User WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity opp = [Select Id FROM Opportunity WHERE StageName = 'Open' LIMIT 1];
            Map<String, String> stages = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'StageName');
            opp.StageName = stages.values()[0];
            update opp;
            setupPicklistValues(opp.Id);
            for(LogACallTestInput input : logACallTestInputs){
                LogACallController.saveData(
                        input.CallAction,
                        input.SubAction,
                        input.Comments,
                        input.CallResult,
                        input.ActionDateTime,
                        input.CloseReason,
                        opp.Id,
                        input.Program,
                        input.VisitDatetime,
                        input.LikelihoodToBook,
                        input.HearAboutUs,
                        input.Destination,
                        input.Duration,
                        input.WhenYear,
                        input.WhenMonth,
                        input.BookOn);
            }
        }
        Test.stopTest();
    }
    static testMethod void testSaveDataForClosedOpportunity(){
        User tAdminUser = [SELECT Id,Name FROM User  WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Opportunity opp = [Select Id FROM Opportunity WHERE StageName = 'Sales Closed' LIMIT 1];
            setupPicklistValues(opp.Id);
            for(LogACallTestInput input : logACallTestInputs){
                LogACallController.saveData(
                        input.CallAction,
                        input.SubAction,
                        input.Comments,
                        input.CallResult,
                        input.ActionDateTime,
                        input.CloseReason,
                        opp.Id,
                        input.Program,
                        input.VisitDatetime,
                        input.LikelihoodToBook,
                        input.HearAboutUs,
                        input.Destination,
                        input.Duration,
                        input.WhenYear,
                        input.WhenMonth,
                        input.BookOn);
            }
        }
        Test.stopTest();
    }

    static testMethod void testSaveDataForLead(){
        User tAdminUser = [SELECT Id,Name FROM User  WHERE alias = 'admnTU' LIMIT 1];
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        Test.startTest();
        system.runAs(tAdminUser) {
            Lead lead = [Select Id FROM Lead LIMIT 1];
            setupPicklistValues(lead.Id);
            for(LogACallTestInput input : logACallTestInputs){
                LogACallController.saveData(
                        input.CallAction,
                        input.SubAction,
                        input.Comments,
                        input.CallResult,
                        input.ActionDateTime,
                        input.CloseReason,
                        lead.Id,
                        input.Program,
                        input.VisitDatetime,
                        input.LikelihoodToBook,
                        input.HearAboutUs,
                        input.Destination,
                        input.Duration,
                        input.WhenYear,
                        input.WhenMonth,
                        input.BookOn);
            }
        }
        Test.stopTest();
    }

    static testMethod  void testForInvalidIdForLikelihoodToBook(){
        try {
            LogACallController.getLikelihoodToBookOptions(NULL);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForHearAboutUsOptions(){
        try {
            LogACallController.getHearAboutUsOptions(NULL);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForGetDestinations(){
        try {
            LogACallController.getDestinations(NULL);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForGetDurations(){
        try {
            LogACallController.getDurations(NULL,'');
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForGetProgramsForChange(){
        try {
            LogACallController.getProgramsForChange(NULL);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForGetCloseReasons(){
        try {
            LogACallController.getCloseReasons(NULL);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod  void testForInvalidIdForGetCallResults(){
        try {
            LogACallController.getCallResults(NULL,'');
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('System.NullPointerException: null input to JSON parser') ? true : false;
        }
    }

    static testMethod void testLogACallData(){
        LogACallData logACallData = new LogACallData(null,Date.today(),'','','','','','',True,0.0,'');
    }
}