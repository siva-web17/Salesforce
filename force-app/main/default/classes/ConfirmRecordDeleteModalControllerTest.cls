/**************************************************************************************
Apex Class Name    : ConfirmRecordDeleteModalControllerTest
Version            : 1.0
Created Date       : March 13 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Osiecki A                  03/13/2018              Original Version
*******************************************************************************/

@isTest
public with sharing class ConfirmRecordDeleteModalControllerTest{

    @testSetup
    static void testDataSetup(){
        TestDataFactory.OpportunityBuilder ob = new TestDataFactory.OpportunityBuilder();
        ob.withPersonAccount();
        ob.save();
    }

    @isTest
    static void When_DeleteOpportunity_Expect_OpportunityIsDeleted(){
        //given
        Opportunity testOpportunityToDelete = [SELECT Id FROM Opportunity LIMIT 1];
        TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
        oppBuilder.withPersonAccount().save();
        Opportunity createdOpp = (Opportunity)oppBuilder.getRecord();

        //when
        Test.startTest();
        ConfirmRecordDeleteModalController.deleteRecord(testOpportunityToDelete.Id);
        Test.stopTest();

        //then
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunities.size(),'');
        System.assert(testOpportunityToDelete.Id != opportunities[0].id);
    }

    @isTest
    static void When_DeleteIncorrectOpportunity_Expect_DMLException(){

        //given
        Opportunity testOpportunityToDelete =[SELECT Id FROM Opportunity LIMIT 1];
        delete testOpportunityToDelete;

        //when
        Test.startTest();
        try{
            ConfirmRecordDeleteModalController.deleteRecord(testOpportunityToDelete.Id);
            System.assert(false, 'Exception expected');
        }catch(Exception exc){}
        Test.stopTest();
    }

    @isTest
    static void When_GetSobjectTypeFromId_Expect_ObjectNameReturned(){
        //given
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        //when
        Test.startTest();
        String objectName = ConfirmRecordDeleteModalController.getSObjectType(oppId);
        Test.stopTest();

        //then
        System.assertEquals('Opportunity', objectName);
    }
}