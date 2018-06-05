@isTest
private class FieldUtilityClassTest{
     @testSetup static void setup(){
         FieldUtilityClass obj01 = new FieldUtilityClass();
        FieldUtilityClass.PicklistDetails obj11 = new FieldUtilityClass.PicklistDetails();
        obj11.active = 'test data';
        obj11.defaultValue = 'test data';
        obj11.label = 'test data';
        obj11.value = 'test data';
        obj11.validFor = 'test data'; 
     }
  static testMethod void testHasFieldAccess(){
    FieldUtilityClass.hasFieldAccess(new Lead(),'Program__c');
  }
  static testMethod void testGetPickListValues(){
    FieldUtilityClass.getPickListValues(Lead.getSObjectType(),'test data');
  }
  static testMethod void testgetDependentOptions(){
    FieldUtilityClass.getDependentOptions('Lead','Program__c','PreferredDuration__c');
  }
  static testMethod void testGetFieldDependencies(){
    FieldUtilityClass.getFieldDependencies('Lead','Market__c','Program__c');
  }
  static testMethod void testGetFieldDependenciesMap(){
    FieldUtilityClass.getFieldDependenciesMap('Lead','Market__c','Program__c');
  }
}