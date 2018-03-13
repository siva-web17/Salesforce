/**
 * Created by thejasvi.a on 3/9/2018.
 */
@istest
public class DCMergeHelperTest {

    static testMethod void onManualMerge() {
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

            Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
            Map<String, String> leadValues = new Map<String, String>{
                    'Market__c' => 'DEB',
                    'Program__c' => 'AY',
                    'SalesOffice__c' => 'DEB',
                    'Email' => 'test@ef.com'
            };
            Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', '', leadValues, TRUE);
            system.debug('leadRecord>>' + leadRecord);

            for (integer i = 0; i < 6; i++) {
                Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', '', leadValues, FALSE);
                leadList.add(leadRec);
                system.debug('list>>' + leadList);
            }
            insert leadList;

            for (lead leadRecrd : leadList) {
                leadIds.add(leadRecord.Id);
            }
            DCMergeHelper.OnManualMerge('00Q', leadRecord, leadIds);
            DCMergeHelper.validationForHasBookingAccountMerge('00Q', leadRecord, leadList);

            Map<String, String> personAccountFieldValues = new Map<String, String>{
                    'Market__c' => 'DEB'
            };
            Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);

        string dateValue = string.valueof(System.today().addDays(3));
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'SalesOffice__c' =>'DEB',
                'Program__c' => 'AY',
                'StageName' => System.Label.LeadStageWon,
                'Closedate' => dateValue,
                'TimeOutDate__c'=> dateValue

        };
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);


            for (integer i = 0; i < 6; i++) {
                Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName' + i, 'TestAccountFirstName' + i, recordTypeId, personAccountFieldValues, FALSE);
                accountList.add(newAccount);
                system.debug('list>>' + accountList);
            }
            insert accountList;

            for (Account accountRecrd : accountList) {
                accountIds.add(accountRecrd.Id);
            }

        Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;

            DCMergeHelper.OnManualMerge('001P', accountRecord, accountIds);
            DCMergeHelper.validationForHasBookingAccountMerge('001P', accountRecord, accountList);

            //DCMergehelper.changeProgramOnOpportunityForPersonAccountMerge('001P', accountRecord, accountIds);
            DCMergeHelper.taskMergeReasonUpdateonMergeLead('00Q', leadRecord, leadList);
            DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q', leadRecord, leadList);
        }

    static testMethod void onManualMergeOpportunityStageFollowup() {
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> leadValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'Program__c' => 'AY',
                'SalesOffice__c' => 'DEB',
                'Email' => 'test@ef.com'
        };
        Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', '', leadValues, TRUE);
        system.debug('leadRecord>>' + leadRecord);

        for (integer i = 0; i < 6; i++) {
            Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', '', leadValues, FALSE);
            leadList.add(leadRec);
            system.debug('list>>' + leadList);
        }
        insert leadList;

        for (lead leadRecrd : leadList) {
            leadIds.add(leadRecord.Id);
        }
        DCMergeHelper.OnManualMerge('00Q', leadRecord, leadIds);
        DCMergeHelper.validationForHasBookingAccountMerge('00Q', leadRecord, leadList);

        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => 'DEB'
        };
        Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);

        string dateValue = string.valueof(System.today().addDays(3));
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'SalesOffice__c' =>'DEB',
                'Program__c' => 'AY',
                'StageName' => System.Label.LeadStageFollowup,
                'Closedate' => dateValue,
                'TimeOutDate__c'=> dateValue

        };
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);

        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunityPersonAccount);

        for (integer i = 0; i < 6; i++) {
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName' + i, 'TestAccountFirstName' + i, recordTypeId, personAccountFieldValues, FALSE);
            accountList.add(newAccount);
            system.debug('list>>' + accountList);
        }
        insert accountList;

        for (Account accountRecrd : accountList) {
            accountIds.add(accountRecrd.Id);
        }

        Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;

        DCMergeHelper.OnManualMerge('001P', accountRecord, accountIds);
        DCMergeHelper.validationForHasBookingAccountMerge('001P', accountRecord, accountList);
        //DCMergeHelper.OpportunityStageUpdateOnMergeAccount('001P',oppList);
        //DCMergehelper.changeProgramOnOpportunityForPersonAccountMerge('001P', accountRecord, accountIds);
        DCMergeHelper.taskMergeReasonUpdateonMergeLead('00Q', leadRecord, leadList);
        DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q', leadRecord, leadList);
    }

    static testMethod void onManualMergeStageTBC() {
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> leadValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'Program__c' => 'AY',
                'SalesOffice__c' => 'DEB',
                'Email' => 'test@ef.com'
        };
        Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', '', leadValues, TRUE);
        system.debug('leadRecord>>' + leadRecord);

        for (integer i = 0; i < 6; i++) {
            Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', '', leadValues, FALSE);
            leadList.add(leadRec);
            system.debug('list>>' + leadList);
        }
        insert leadList;

        for (lead leadRecrd : leadList) {
            leadIds.add(leadRecord.Id);
        }
        DCMergeHelper.OnManualMerge('00Q', leadRecord, leadIds);
        DCMergeHelper.validationForHasBookingAccountMerge('00Q', leadRecord, leadList);

        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => 'DEB'
        };
        Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);

        string dateValue = string.valueof(System.today().addDays(3));
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'SalesOffice__c' =>'DEB',
                'Program__c' => 'AY',
                'StageName' => System.Label.LeadStageTBC,
                'Closedate' => dateValue,
                'TimeOutDate__c'=> dateValue

        };
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);

        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunityPersonAccount);

        for (integer i = 0; i < 6; i++) {
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName' + i, 'TestAccountFirstName' + i, recordTypeId, personAccountFieldValues, FALSE);
            accountList.add(newAccount);
            system.debug('list>>' + accountList);
        }
        insert accountList;

        for (Account accountRecrd : accountList) {
            accountIds.add(accountRecrd.Id);
        }

        Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;

        DCMergeHelper.OnManualMerge('001P', accountRecord, accountIds);
        DCMergeHelper.validationForHasBookingAccountMerge('001P', accountRecord, accountList);
        //DCMergeHelper.OpportunityStageUpdateOnMergeAccount('001P',oppList);
        //DCMergehelper.changeProgramOnOpportunityForPersonAccountMerge('001P', accountRecord, accountIds);
        DCMergeHelper.taskMergeReasonUpdateonMergeLead('00Q', leadRecord, leadList);
        DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q', leadRecord, leadList);
    }

    static testMethod void onManualMergeOppStageClosedLost() {
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> leadValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'Program__c' => 'AY',
                'SalesOffice__c' => 'DEB',
                'Email' => 'test@ef.com'
        };
        Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', '', leadValues, TRUE);
        system.debug('leadRecord>>' + leadRecord);

        for (integer i = 0; i < 6; i++) {
            Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', '', leadValues, FALSE);
            leadList.add(leadRec);
            system.debug('list>>' + leadList);
        }
        insert leadList;

        for (lead leadRecrd : leadList) {
            leadIds.add(leadRecord.Id);
        }
        DCMergeHelper.OnManualMerge('00Q', leadRecord, leadIds);
        DCMergeHelper.validationForHasBookingAccountMerge('00Q', leadRecord, leadList);

        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => 'DEB'
        };
        Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);

        string dateValue = string.valueof(System.today().addDays(3));
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'SalesOffice__c' =>'DEB',
                'Program__c' => 'AY',
                'StageName' => System.Label.OppStageClosedLost,
                'Closedate' => dateValue,
                'TimeOutDate__c'=> dateValue

        };
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);

        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunityPersonAccount);

        for (integer i = 0; i < 6; i++) {
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName' + i, 'TestAccountFirstName' + i, recordTypeId, personAccountFieldValues, FALSE);
            accountList.add(newAccount);
            system.debug('list>>' + accountList);
        }
        insert accountList;

        for (Account accountRecrd : accountList) {
            accountIds.add(accountRecrd.Id);
        }

        Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;

        DCMergeHelper.OnManualMerge('001P', accountRecord, accountIds);
        DCMergeHelper.validationForHasBookingAccountMerge('001P', accountRecord, accountList);
        //DCMergeHelper.OpportunityStageUpdateOnMergeAccount('001P',oppList);
        //DCMergehelper.changeProgramOnOpportunityForPersonAccountMerge('001P', accountRecord, accountIds);
        DCMergeHelper.taskMergeReasonUpdateonMergeLead('00Q', leadRecord, leadList);
        DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q', leadRecord, leadList);
    }



    static testMethod void ChangeProgramOrStatusForMasterREcord() {
        User tstandardUser= Testdatafactory.createUser( 'Marketing User', TRUE);
        system.debug('tstandardUser>>>'+tstandardUser);
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        string dateValue = string.valueof(System.today().addDays(3));

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> leadValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'Program__c' => 'AY',
                'SalesOffice__c' => 'DEB',
                'Email' => 'test@ef.com',
                'Status'=>'Closed',
                'RequestType__c'=>'BR'

        };

        Id leadrecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
        Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', leadrecordTypeId, leadValues, TRUE);
        system.debug('leadRecord>>' + leadRecord);

        for (integer i = 0; i < 6; i++) {
            Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', leadrecordTypeId, leadValues, FALSE);
            leadList.add(leadRec);
            system.debug('list>>' + leadList);
        }
        insert leadList;

        for (lead leadRecrd : leadList) {
            leadIds.add(leadRecord.Id);
        }
        DCMergeHelper.OnManualMerge('00Q', leadRecord, leadIds);
        DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q', leadRecord, leadList);
    }

    static testMethod void changeProgramOnOpportunityForPersonAccountMergeTest(){
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => 'DEB'
        };
        Account accountRecord = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, TRUE);
        accountRecord = [SELECT PersonContactId FROM Account WHERE Id =:accountRecord.Id LIMIT 1];
        system.debug('accountrecord>>>'+accountRecord.PersonContactId);
        string dateValue = string.valueof(System.today().addDays(3));
        Map<String, String> opportunityFieldValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'SalesOffice__c' =>'DEB',
                'Program__c' => 'MULTI',
                'StageName' => System.Label.OpportunityBookingStage,
                'Closedate' => dateValue,
                'TimeOutDate__c'=> dateValue

        };
        Opportunity newOpportunityPersonAccount = TestDataFactory.createOpportunityForAccount(accountRecord.id, 'testOpportunityName', opportunityFieldValues, True);

        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunityPersonAccount);

        for (integer i = 0; i < 6; i++) {
            Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName' + i, 'TestAccountFirstName' + i, recordTypeId, personAccountFieldValues, FALSE);
            accountList.add(newAccount);
            system.debug('list>>' + accountList);
        }
        insert accountList;

        for (Account accountRecrd : accountList) {
            accountIds.add(accountRecrd.Id);
        }

        Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;
        system.debug('event>>>'+imEvent);

        DCMergeHelper.changeProgramOnOpportunityForPersonAccountMerge('001P',accountRecord,accountIds);
        DCMergeHelper.OnManualMerge('001P', accountRecord, accountIds);
    }

    static testMethod void changeProgramOnOpportunityBooking(){
        List<Lead> leadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        string dateValue = string.valueof(System.today().addDays(3));

        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        Map<String, String> leadValues = new Map<String, String>{
                'Market__c' => 'DEB',
                'Program__c' => 'MULTI',
                'SalesOffice__c' => 'DEB',
                'Email' => 'test@ef.com',
                'Status'=>'Closed',
                'RequestType__c'=>''

        };

        Id leadrecordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Lead.SobjectType).get('Customer').Id;
        Lead leadRecord = TestDataFactory.createLead('FirstName', 'strLastName', '', leadrecordTypeId, leadValues, TRUE);
        system.debug('leadRecord>>' + leadRecord);

        for (integer i = 0; i < 6; i++) {
            Lead leadRec = TestDataFactory.createLead('FirstName' + i, 'strLastName' + i, '', leadrecordTypeId, leadValues, FALSE);
            leadList.add(leadRec);
            system.debug('list>>' + leadList); 
        }
        insert leadList;

        for (lead leadRecrd : leadList) {
            leadIds.add(leadRecord.Id);
        }

        /*Event imEvent = new Event();
        imEvent.WhoId = accountRecord.PersonContactId;
        imEvent.DurationInMinutes = 30;
        imEvent.ActivityDateTime = DateTime.now();
        imEvent.Type = 'RES';
        insert imEvent;
        system.debug('event>>>'+imEvent);*/

        DCMergeHelper.ChangeProgramOrStatusForMasterREcord('00Q',leadRecord,leadList);

    }



}