/******************************************************************************
Apex Class Name    : DCDiscardsTest
Version            : 1.0
Created Date       : 7/7/2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * shravan.boddula                  7/7/2017              Original Version
 * Adam Osiecki                   17/05/2017              Class rewritten from scratch
*******************************************************************************/
@isTest
public class DCDiscardsTest {

    private static User adminUser = TestDataFactory.createAdminUser(true);
    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    @isTest
    static void when_DcDiscardsAreInserted_Expect_QueueClassJobIsScheduled(){

        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            Integer numOfLeads = 4;
            List<Lead> leadList = new List<Lead>();
            Set<Id> leadIds = new Set<Id>();
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();

            //given
            for(Integer i = 0; i < numOfLeads; i++){
                leadBuilder.build().withRecordType('Customer');
                Lead lead = (Lead)leadBuilder.getRecord();
                lead.Market__c = picklistValuesHelper.market;
                lead.Language__c = picklistValuesHelper.language;
                lead.IsDupe__c = true;
                leadList.add(lead);
            }
            insert leadList;

            for(Lead lead : leadList){
                leadIds.add(lead.Id);
            }
            leadList = [
                    SELECT Id, Ranking__c, IsDupe__c, ReadyForRanking__c
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            dupcheck__dcJob__c dcJob = new dupcheck__dcJob__c(
                    dupcheck__name__c = 'Test DcJobName',
                    dupcheck__sourceObject__c = '0000',
                    dupcheck__Started__c = Datetime.now()
            );
            insert dcJob;

            dupcheck__dcGroup__c dcGroup = new dupcheck__dcGroup__c(
                    dupcheck__Display__c = FALSE,
                    dupcheck__group__c = 1,
                    dupcheck__handled__c = FALSE,
                    dupcheck__dcJob__c = dcJob.Id
            );
            insert dcGroup;

            Set<Id> dupcheckDiscardsIds = new Set<Id>();
            List<dupcheck__dcDiscard__c> dcDiscards = new List<dupcheck__dcDiscard__c>();

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.CallForRankingMock(leadList));
            Test.stopTest();

            dupcheck__dcDiscard__c dupcheckDiscard = createDupcheckDiscard(leadList[0].id,leadList[1].id);
            dcDiscards.add(dupcheckDiscard);
            dupcheck__dcDiscard__c dupcheckDiscard2 = createDupcheckDiscard(leadList[2].id,leadList[3].id);
            dcDiscards.add(dupcheckDiscard2);

            //when
            insert dcDiscards;

            leadList = [
                    SELECT Id, Ranking__c, IsDupe__c, ReadyForRanking__c
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            //then
            List<AsyncApexJob> asyncBatchApexJobs = [
                    SELECT JobType
                    FROM AsyncApexJob
            ];

            System.assertEquals(1, asyncBatchApexJobs.size(), 'Expecting exactly one job is queued');
            System.assertEquals('Queueable', asyncBatchApexJobs[0].JobType, 'Expecting specific type of job is queued');
        }
    }

    @isTest
    static void when_WebServiceCallForRankingAfterFalseDupe_Expect_LeadsAreUpdated(){

        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{adminUser.Id},true,true);
        System.runAs(adminUser){

            Integer numOfLeads = 4;
            List<Lead> leadList = new List<Lead>();
            Set<Id> leadIds = new Set<Id>();
            TestDataFactory.LeadBuilder leadBuilder = new TestDataFactory.LeadBuilder();

            //given
            for(Integer i = 0; i < numOfLeads; i++){
                leadBuilder.build().withRecordType('Customer');
                Lead lead = (Lead)leadBuilder.getRecord();
                lead.Market__c = picklistValuesHelper.market;
                lead.Language__c = picklistValuesHelper.language;
                lead.IsDupe__c = true;
                leadList.add(lead);
            }
            insert leadList;

            for(Lead lead : leadList){
                leadIds.add(lead.Id);
            }
            leadList = [
                    SELECT Id, Ranking__c, IsDupe__c, ReadyForRanking__c
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            dupcheck__dcJob__c dcJob = new dupcheck__dcJob__c(
                    dupcheck__name__c = 'Test DcJobName',
                    dupcheck__sourceObject__c = '0000',
                    dupcheck__Started__c = Datetime.now()
            );
            insert dcJob;

            dupcheck__dcGroup__c dcGroup = new dupcheck__dcGroup__c(
                    dupcheck__Display__c = FALSE,
                    dupcheck__group__c = 1,
                    dupcheck__handled__c = FALSE,
                    dupcheck__dcJob__c = dcJob.Id
            );
            insert dcGroup;

            Set<Id> dupcheckDiscardsIds = new Set<Id>();
            List<dupcheck__dcDiscard__c> dcDiscards = new List<dupcheck__dcDiscard__c>();

            dupcheck__dcDiscard__c dupcheckDiscard = createDupcheckDiscard(leadList[0].id,leadList[1].id);
            dcDiscards.add(dupcheckDiscard);
            dupcheck__dcDiscard__c dupcheckDiscard2 = createDupcheckDiscard(leadList[2].id,leadList[3].id);
            dcDiscards.add(dupcheckDiscard2);
            insert dcDiscards;

            //when
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CalloutHandlerMocks.CallForRankingMock(leadList));
            DcDiscardsHelper.WebServiceCallForRankingAfterFalseDupe(leadIds);
            Test.stopTest();

            //then
            leadList = [
                    SELECT ranking__c, IsDupe__c, IsDupeProcessed__c
                    FROM Lead
                    WHERE Id IN :leadIds
            ];

            for(Lead lead : leadList){
                System.assertEquals(5, lead.ranking__c, 'Expecting lead ranking was set to specific value');
                System.assert(!lead.IsDupe__c, 'Expecting lead.IsDupe__c is set to false');
                System.assert(lead.IsDupeProcessed__c, 'Expecting lead.IsDupe__c is set to false');
            }
        }
    }

    private static dupcheck__dcDiscard__c createDupcheckDiscard(String objectA,String objectB) {
        dupcheck__dcDiscard__c dupcheckdiscard = new dupcheck__dcDiscard__c(
                dupcheck__objectA__c =objectA,
                dupcheck__Relation__c='Duplicate',
                dupcheck__objectB__c = objectB,
                dupcheck__recordA__c= objectA,
                dupcheck__recordB__c= objectB
        );
        return dupcheckdiscard;
    }
}