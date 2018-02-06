/**
 * Created by Arkadiusz Celej on 04.01.2018.
 */

@IsTest
private class AccountTriggerTest {

    private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();

    static testMethod void whenDateOfBirthOrLanguageChangeResetLetterAndLabelOnOpportunity() {
        //given
        TestDataFactory.TemplateSettingBuilder templateSettingBuilder = new TestDataFactory.TemplateSettingBuilder();
        //
        templateSettingBuilder.setField('Market__c', picklistValuesHelper.market);
        templateSettingBuilder.setField('Program__c', picklistValuesHelper.program);
        templateSettingBuilder.withAge(10);
        templateSettingBuilder.withLetter();
        templateSettingBuilder.withLabel();
        templateSettingBuilder.save();
        TestDataFactory.OpportunityBuilder oppBuilder = new TestDataFactory.OpportunityBuilder();
        oppBuilder.setField('Market__c', picklistValuesHelper.market);
        oppBuilder.setField('SalesOffice__c', picklistValuesHelper.salesOffice);
        oppBuilder.setField('Program__c', picklistValuesHelper.program);
        oppBuilder.setField('Product__c', picklistValuesHelper.product);
        oppBuilder.withPersonAccount().save();
        Account personAccount = oppBuilder.getAccount();
        TestDataFactory.TaskBuilder sbrTaskBuilder = new TestDataFactory.TaskBuilder();
        sbrTaskBuilder.withRecordType(TasksHelper.SBR_TASK_DEVELOPER_NAME);
        sbrTaskBuilder.setWhat(oppBuilder.getRecord().Id);
        sbrTaskBuilder.save();
        //when
        Test.startTest();
        personAccount.PersonBirthdate = System.today().addYears(-10);

        update personAccount;
        Test.stopTest();
        //then

        Opportunity opp = [SELECT Id, Letter__c, Label__c FROM Opportunity WHERE Id = :oppBuilder.getRecord().Id];
        System.assertEquals(templateSettingBuilder.templateLetter.Id, opp.Letter__c, 'Invalid Letter');
        System.assertEquals(templateSettingBuilder.templateLabel.Id, opp.Label__c, 'Invalid Label');
    }
}