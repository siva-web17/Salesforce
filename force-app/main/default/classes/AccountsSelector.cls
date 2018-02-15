/**************************************************************************************
Apex Class Name    : AccountsSelector
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * shravan.boddula                 07/12/2017              Original Version
*******************************************************************************/
public class AccountsSelector {


    public static Account getAccountOnId(Id accountId) {
        return [
                select id, FirstName,LastName,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,
                        PersonMailingStreet,RecalculateRanking__c, PersonEmail,Email2__c,PersonHomePhone,PersonMobilePhone,
                        PersonOtherPhone,PersonBirthdate,Market__c,Region__c,
                        HasBooking__c
                from Account
                where Id = :accountId
                limit 1
        ];
    }
    

   public static List<Account> getAccountsWithOpportunitiesByContactIds(Set<Id> contactIds){
       return [SELECT Id, PersonContactId,
                (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE)
                FROM Account
                WHERE PersonContactId IN :contactIds
       ];
   }
}