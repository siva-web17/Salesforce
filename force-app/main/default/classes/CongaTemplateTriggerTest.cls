@isTest
public class CongaTemplateTriggerTest {
private static TestDataFactory.DefaultPicklistValuesHelper picklistValuesHelper = new TestDataFactory.DefaultPicklistValuesHelper();
        Public static ID recordId;
        Public static ID userOrGroupId; 
        Public static String accessLevel;
    
    @testSetup
    static void testDataSetup(){
        Profile SystemAdminProfile = TestDataFactory.getProfile('System Administrator', true);
        User tAdminUser = TestDataFactory.createAdminUser(True);
         Group	group1	=	new Group(name = 'NOO',type	=	'Regular');
        	insert group1;
        Group group2 = new Group(name = 'CNB', Type='Regular');
        	insert group2;
        
        
        APXTConga4__Conga_Template__c Conga = new APXTConga4__Conga_Template__c();
        Conga.Market__c = 'NOO';
        Conga.Program__c = 'ILS';
        Conga.Language__c = 'NO';
       
        insert Conga;
    
	}
    
    static testMethod void WhenCreateShareOnInsert(){
      Test.startTest();
        Map<Id, String> templateMap = new Map<Id, String>();
        Map<String, Id> publicGroupMap = publicGroupsSelector.getRegularPublicGroupsByName(templateMap.values());        
        List<APXTConga4__Conga_Template__share> templateShareList = new List<APXTConga4__Conga_Template__share>();
        
        List<APXTConga4__Conga_Template__c> templateList1 = [SELECT ID,APXTConga4__Template_Type__c,APXTConga4__Template_Group__c,
                                                                     APXTConga4__Template_Extension__c,APXTConga4__Name__c,
                                                                     APXTConga4__Master_Field_to_Set_3__c,Market__c,
                                                                     APXTConga4__Master_Field_to_Set_2__c,Program__c,
                                                                     APXTConga4__Master_Field_to_Set_1__c,
                                                                     Language__c,CurrencyIsoCode, RecordSharingKey__c,OwnerId
                                                            FROM APXTConga4__Conga_Template__c];
      
       
        List<APXTConga4__Conga_Template__c> templateList2 = [SELECT ID,APXTConga4__Template_Type__c,APXTConga4__Template_Group__c,
                                                                     APXTConga4__Template_Extension__c,APXTConga4__Name__c,
                                                                     APXTConga4__Master_Field_to_Set_3__c,Market__c,
                                                                     APXTConga4__Master_Field_to_Set_2__c,Program__c,
                                                                     APXTConga4__Master_Field_to_Set_1__c,
                                                                     Language__c,CurrencyIsoCode, RecordSharingKey__c,OwnerId	
                                                              FROM APXTConga4__Conga_Template__c];
        templateList2[0].Market__c = 'CNB';
        templateList2[0].Language__c = 'ZH';
        templateList2[0].Program__c = 'ILS';
        update templateList2[0];
        
        Map<Id,String> temMap = new Map<Id,String>();
            for(APXTConga4__Conga_Template__c ct : templateList1){
                temMap.put(ct.id, 'test');
            }
        
        CongaTemplateHelper.createShareOnInsert(templateList1);
        CongaTemplateHelper.createShareRecord(recordId, userOrGroupId, accessLevel);
        CongaTemplateHelper.createTemplateShareRec(temMap, publicGroupMap);
        CongaTemplateHelper.createShareOnUpdateTypes(templateList2, templateList1);
        system.assertEquals(1, templateList1.size());
      Test.stopTest();  
        
    }
   

}