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
                        PersonMailingStreet, RecalculateRanking__c, PersonEmail,Email2__c,PersonHomePhone,PersonMobilePhone,
                        PersonOtherPhone,PersonBirthdate,Market__c,Region__c,
                        HasBooking__c
                from Account
                where Id = :accountId
                limit 1
        ];
    }

    public static List<Account> getAccountsWithOpportunitiesByIds(Set<Id> accountIds) {
        return [
                SELECT Id, PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE)
                FROM Account
                WHERE Id = :accountIds
        ];
    }

    public static List<Account> getAccountsWithOpportunitiesByContactIds(Set<Id> contactIds) {
        return [
                SELECT Id, PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE)
                FROM Account
                WHERE PersonContactId IN :contactIds
        ];
    }

    public static map<Id, Account> getAccountDetailsbasedonAccountId(Set<Id> accountIdSet) {
        List<String> accountMissingFields = new List<String>{
                'Name', 'Id', 'Market__c', 'CreatedById', 'LastModifiedById', 'firstname', 'lastname', 'ParentEmail__c', 'middlename', 'PersonMailingCity', 'PersonMailingPostalCode', 'PersonMailingCountryCode', 'PersonMailingState', 'ShippingCity', 'ShippingState', 'ShippingStreet', 'PersonOtherPostalCode'
        };
        List<Account> accList = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<String> fieldsToSelect = new Set<String>();
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.UpdatePersonalInfo.getFields()) {
            fieldsToSelect.add(f.getFieldPath());
            query += f.getFieldPath() + ', ';
        }
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Address.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
                query += f.getFieldPath() + ', ';
            }
        }

        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Customer.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
                query += f.getFieldPath() + ', ';
            }
        }
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.CustomerMarketingPref.getFields()) {
            if (!fieldsToSelect.contains(f.getFieldPath())) {
                fieldsToSelect.add(f.getFieldPath());
                query += f.getFieldPath() + ', ';
            }
        }
        for (String accountField : accountMissingFields) {
            if (!fieldsToSelect.contains(accountField)) {
                fieldsToSelect.add(accountField);
                query += accountField + ', ';
            }
        }
        if (query.endsWith(', ')) {
            query = query.substringBeforeLast(',');
        }
        query += ' from Account Where Id in   : ' + 'accountIdSet' + ' ' ;
        System.debug('Dynamic Query :' + query);
        accList = Database.query(query);
        for (Account accRecord : accList) {
            accountMap.put(accRecord.Id, accRecord);
        }
        return accountMap;
    }
}