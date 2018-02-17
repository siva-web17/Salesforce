/**
 * Created by aditi.sharma on 12/27/2017.
 */
@IsTest(seealldata=false)
public with sharing class LogACallControllerTest {
    public static String market = 'DEB';
    static testmethod void when_AccountREcord_Return_Null(){
        account loagACallAccount = TestDataFactory.createAccount('logACallAccount', '', true);
        test.starttest();
        callControllerMethods(loagACallAccount.id);
        test.stoptest();
    }
    static testMethod void when_SystemCallTaskOnLead_Return_CallTask() {
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{TestDataFactory.createAdminUser(True).Id}, true, false);
        system.runAs(TestDataFactory.createAdminUser(True)) {
            lead leadRecord = createLeadRecord();
            insert leadRecord;
            createTakRecord(leadRecord.id);
            test.starttest();
            callControllerMethods(leadRecord.id);
            recordSave('Call Not Reached',
                    'Wrong Number',
                    'comments',
                    'call back',
                    system.now(),
                    'Had no intention',
                    leadRecord.id,
                    'ILSU',
                    system.now(),
                    'High',
                    'Social Media',
                    'Asia',
                    '1 - 16 weeks',
                    '2019',
                    'January',
                    system.now()

            );
            list<task> taskList = [select id, SalesAction__c from task where whoid=:leadRecord.id And SalesAction__c='Call Not Reached'];
             system.assert(taskList.size()>0,'Call Action is not  logged');
            test.stoptest();
        }
    }
    static testMethod void when_CallReached_Return_ConvertedOpportunity() {
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{TestDataFactory.createAdminUser(True).Id}, true, false);
        system.runAs(TestDataFactory.createAdminUser(True)) {
            lead leadRecord = createLeadRecord();
            insert leadRecord;
            createTakRecord(leadRecord.id);
            test.starttest();
            callControllerMethods(leadRecord.id);
            recordSave('Call Reached',
                    '',
                    'comments',
                    'call back',
                    system.now(),
                    'Had no intention',
                    leadRecord.id,
                    'ILSU',
                    system.now(),
                    'High',
                    'Social Media',
                    'Asia',
                    '1 - 16 weeks',
                    '2019',
                    'January',
                    system.now()

            );
            id convertedaccountid = [select id ,ConvertedAccountId  from lead where id=:leadRecord.id limit 1].ConvertedAccountId;
       system.assert(convertedaccountid !=null,'Lead Conversion Failed');
            test.stoptest();
        }
    }
    static testMethod void when_NoSystemCallTaskOnLead_Return_ZeroCallTask() {
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{TestDataFactory.createAdminUser(True).Id}, true, false);
        system.runAs(TestDataFactory.createAdminUser(True)) {
            lead leadRecord = createLeadRecord();
            insert leadRecord;
            test.starttest();
            callControllerMethods(leadRecord.id);
            recordSave('Call Reached',
                    '',
                    'comments',
                    'call back',
                    system.now(),
                    'Had no intention',
                    leadRecord.id,
                    'ILSU',
                    system.now(),
                    'High',
                    'Social Media',
                    'Asia',
                    '1 - 16 weeks',
                    '2019',
                    'January',
                    system.now()

            );
            list<task> taskList = [select id, SalesAction__c from task where whoid=:leadRecord.id And SalesAction__c='Call Reached'];
            system.assert(taskList.size()==0,'Call Action should not be logged');
            test.stoptest();
        }
    }
    static testMethod void when_SystemCallTaskonOpportunity_Return_callTask() {
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{TestDataFactory.createAdminUser(True).Id}, true, false);
        system.runAs(TestDataFactory.createAdminUser(True)) {
            opportunity logACallOpportunity = createOpportunityRecord();
            insert logACallOpportunity;
           task systemCalTask = createTakRecord(logACallOpportunity.id);
            test.starttest();
            callControllerMethods(logACallOpportunity.id);
            recordSave('Call Reached',
                    '',
                    'comments',
                    'call back',
                    system.now(),
                    'Had no intention',
                    logACallOpportunity.id,
                    'ILSU',
                    system.now(),
                    'High',
                    'Social Media',
                    'Dauntsey Residence',
                    '1 - 16 weeks',
                    '2019',
                    'January',
                    system.now()
            );
            list<task> taskList = [select id, SalesAction__c from task where whatid=:logACallOpportunity.id And SalesAction__c='Call Reached'];
//            list<task> systemCalltaskList = [select id, SalesAction__c,isexpresscall__c from task where whatid=:logACallOpportunity.id And recordid=:RecordTypeSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id];
            system.assert(taskList.size()>0,'Call Action is not logged');
//            system.assert(!systemCalltaskList[0].isexpresscall__c,'Is Express was not reset after call has reached');
            test.stoptest();
        }
    }
    static testMethod void when_NoSystemCallTaskOnOpportunity_return_zerocalltask() {
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{TestDataFactory.createAdminUser(True).Id}, true, false);
        system.runAs(TestDataFactory.createAdminUser(True)) {
            opportunity logACallOpportunity = createOpportunityRecord();
            insert logACallOpportunity;
            test.starttest();
            callControllerMethods(logACallOpportunity.id);
            recordSave('Call Reached',
                    '',
                    'comments',
                    'call back',
                    system.now(),
                    'Had no intention',
                    logACallOpportunity.id,
                    'ILSU',
                    system.now(),
                    'High',
                    'Social Media',
                    'Dauntsey Residence',
                    '1 - 16 weeks',
                    '2019',
                    'January',
                    system.now()
            );
            list<task> taskList = [select id, SalesAction__c from task where whatid=:logACallOpportunity.id And SalesAction__c='Call Reached'];
            system.assert(taskList.size()==0,'Call Action should not be logged');
            test.stoptest();
        }
    }

    // Change this method
    public static task createTakRecord(id recordId){
        Id systemCallTaskRecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Task.SObjectType).get(TasksHelper.SYSTEM_TASK_DEVELOPER_NAME).Id;
        Map<String, String> TaskFieldValues = new Map<String, String>{
                'type' => 'Call',
                'recordtypeid' => systemCallTaskRecordTypeId,
                'isexpresscall__c'  => 'TRUE',
                'NextCallType__c' => 'FUP'
        };
        task taskRecord = TestDataFactory.createTaskForSobject(recordId,TaskFieldValues,false);

        insert taskRecord;
        return taskRecord;

    }
    public static lead createLeadRecord(){
        Map<String, String> leadFieldValues = new Map<String, String>{
                'CloseDate__c' => string.valueof(system.today().adddays(3)),
                'LikelihoodToBook__c' => 'High',
                'HearAboutUs__c' => 'Social Media',
                'product__c' => 'ILS',
                'program__c' => 'ILSU',
                'Destinations__c' => 'Asia',
                'Duration__c' => '1 - 16 weeks',
                'WhenYear__c' => '2019',
                'WhenMonth__c' => 'January'
        };
        return TestDataFactory.createLead('LoganAction', 'Test', 'EF', '',leadFieldValues, false);
    }
    public static opportunity createOpportunityRecord(){
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'product__c' => 'ILS',
                'program__c' => 'ILSU',
                'stagename' => 'prospecting',
                'CloseDate' => string.valueof(system.today().adddays(3))
        };
        account loagACallAccount = TestDataFactory.createAccount('logACallAccount', '', true);
        opportunity logACallOpportunity = TestDataFactory.createOpportunityForAccount(loagACallAccount.id, 'logACallOpportunity', opportunityFieldValues, false);

        return logACallOpportunity;
    }
    public static void callControllerMethods(id recordid){
        LogACallController.getInitialData(recordid);
        LogACallController.getLikelihoodToBookOptions(recordid);
        LogACallController.getHearAboutUsOptions(recordid);
        LogACallController.getDestinations(recordid);
        LogACallController.getDurations(recordid);
        LogACallController.getCloseReasons(recordid);
        LogACallController.getProgramsForChange(recordid);
        LogACallController.isCustomerReached(recordid);
        LogACallController.getSalesActions();
        LogACallController.getSubActions();
        LogACallController.getCallResults('Call Reached',recordid);


    }
    public static void recordSave(String callAction,
            String subAction,
            string comments,
            String callResult,
            DateTime actionDateTime,
            string closeReason,
            Id recordId,
            String program,
            Datetime visitDatetime,
            String likelihoodToBook,
            String hearAboutUs,
            String destination,
            String duration,
            String whenYear,
            String whenMonth,
            DateTime bookOn){
        LogACallController.saveData(callAction,subAction,comments,callResult,actionDateTime, closeReason,recordId,program,visitDatetime,likelihoodToBook,hearAboutUs,destination,duration,whenYear,whenMonth,bookOn);
    }

}