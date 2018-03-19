@isTest
public class UtilityTest {
string splitstringvalue; 
   string splitchar;
boolean TrueOrFalse {get;set;}    
    @testSetup
    static void testDataSetup(){
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        User tAdminUser = TestDataFactory.createAdminUser(True);
    } 
    
    static testMethod void getTriggerSettingsTest(){
        User tAdminUser = TestDataFactory.createAdminUser(True);
        TestDataFactory.bypassValidationsTriggersForUsers(new Set<String>{tAdminUser.Id},true,false);
        system.runAs(tAdminUser) {
        Boolean isDisable = false;
        Test.startTest();
        BypassTriggersValidation__c setupUser = BypassTriggersValidation__c.getInstance();
        setupUser.DisableTrigger__c = null;
        setupUser.DisableTrigger__c = true;
        setupUser.TriggerObject__c = 'Account';
        Utility.getTriggerSettings('setupUser');
        Utility.splitString('splitstringvalue', 'splitchar');
        Datetime inputDatetime = Datetime.newInstance(1960, 2, 19);
        Utility.ConvertDateTimeTodate(inputDatetime);
        isDisable= true;
        
        
        
        Test.stopTest();
        } 
        
    }
    
}