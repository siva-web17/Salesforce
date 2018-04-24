/**************************************************************************************
Apex Class Name    : SObjectsSelector
Version            : 1.0
Created Date       : July 21 2017
Function           : Returns sObjects
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Aneesh B                  07/21/2017              Original Version
 *************************************************************************************/
public class SObjectsSelector {

    public static List<ContentWorkSpace> getTemplateDocuments(String libraryFolder) {
        return [Select Id, Name,
                (Select Id, ContentDocument.Title, ContentDocument.LatestPublishedVersionId, ContentDocument.FileType, ContentDocument.Description
                 from AttachedContentDocuments order by ContentDocument.Title)
                from ContentWorkspace
                where Name like :libraryFolder];
    }

}