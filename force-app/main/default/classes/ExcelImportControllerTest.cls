/**************************************************************************************
Apex Class Name    : ExcelImportControllertest
Version            : 1.0
Created Date       : July 21 2017
Function           : Test class for ExcelImportController
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Aneesh B                  08/02/2017              Original Version
 *************************************************************************************/
@IsTest(seealldata=true)
//Checking seealldata to true to get the templates stored in the content library
public class ExcelImportControllerTest {

    static testMethod void when_ExcelImportGroupMember_Expect_LeadOpportunityTemplate() {
        User groupMember = createUser(true);
       
            System.assert(createUser(true)!=null, 'Excel Import group member not present');
      
        test.starttest();
        system.runAs(createUser(true)) {            
            List<ContentDocument> lstOfTemplateFiles= getTemplates();
           // AssertCollectionContainsDocument();
            System.assert(IsDocumentPresent('Lead Template',lstOfTemplateFiles), 'Lead template is not present');
            System.assert(IsDocumentPresent('Opportunity Template',lstOfTemplateFiles), 'Opportunity template is not present');
        }
        test.stoptest();
    }
 /*   public static void AssertCollectionContainsDocument(String documentName,List<ContentDocument> documents){
      map<string,ContentDocument> ContentDocumentMap = new map<string,ContentDocument>();
        for (ContentDocument document:documents) {
            ContentDocumentMap.put(document.Title,document);
        }
        system.assert(ContentDocumentMap.containskey(documentName),'There are less than two tmplates present');
    }*/
   public static Boolean IsDocumentPresent(String documentName,List<ContentDocument> documents){
        map<string,ContentDocument> ContentDocumentMap = new map<string,ContentDocument>();
        for (ContentDocument document:documents) {
            ContentDocumentMap.put(document.Title,document);
        }
        return ContentDocumentMap.containskey(documentName);
         
    }
    private static User createUser(Boolean isGroupMember){
        User adminUser = TestDataFactory.createAdminUser(false);
        adminUser.UserPermissionsSFContentUser = true;
        insert adminUser;
        if(isGroupMember){
            List<Group> publicGroup = PublicGroupsSelector.getPublicGroupsByNameAndType(Label.ExcelImportPublicGroupName,'Regular');
            if(publicGroup == null || publicGroup.size() ==0){
                System.assert(false, 'Excel Import group not present');
            }
            GroupMember excelImportGroupMember = new GroupMember();
            excelImportGroupMember.GroupId = publicGroup[0].id;
            excelImportGroupMember.UserOrGroupId = adminUser.id;
            insert excelImportGroupMember;            
        }
        return adminUser;
    }
    static testMethod void when_NonExcelImportGroupMember_Expect_NoTemplate() {
        User nonExcelImportGroupMember = createUser(false);
            system.runAs(createUser(false)) {
            test.starttest();
            List<ContentDocument> lstOfTemplateFiles= getTemplates();
            System.assert(lstOfTemplateFiles.size() == 0, 'The files are accessible outside the group as well');
        }
        test.stoptest();
    }
    static testMethod List<ContentDocument> getTemplates() {
      string templateFilesListAsJson = ExcelImportController.getTemplates();           
      return (List<ContentDocument>) JSON.deserialize(templateFilesListAsJson , List<ContentDocument>.class);
    }
}