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
                select id,Name,FirstName,LastName,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,
                        PersonMailingStreet, RecalculateRanking__c, PersonEmail,Email2__c,PersonHomePhone,PersonMobilePhone,
                        PersonOtherPhone,PersonBirthdate,Market__c,Region__c,
                        HasBooking__c, NumberOfUnreachedHappyCalls__c,CurrencyIsoCode,DoNotCall__c
                from Account
                where Id = :accountId
                limit 1
        ];
    }


    public static List<Account> getAccountsWithOpportunitiesByContactIds(Set<Id> contactIds) {
        return [
                SELECT Id, Name, Market__c, PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE)
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

    public static Map<ID,Account> getAccountsWithActiveOpportunitiesByIds(Set<Id> accountIds){
        Map<ID,Account> accountWithActiveOpportunities = new Map<ID,Account>([
                SELECT Id, Name, Market__c, PersonContactId, (SELECT Id FROM Opportunities WHERE IsActive__c = TRUE limit 1)
                FROM Account
                WHERE id IN :accountIds]);
        return accountWithActiveOpportunities;
    }
    
    public static map<Id, Account> getAccountBasedonAccountId(Set<Id> accountIds) {
        Map<ID,Account> accountMap = new Map<ID,Account>([
                SELECT Id,IsPseudonymised__pc, Email2__c, hasBooking__c,FirstName, InvoiceEmail__c, LastName,ParentEmail__c,PersonEmail,PersonHomePhone,
                        PersonMailingCity,PersonMailingCountry,PersonMailingCountryCode, PersonMailingPostalCode,
                        PersonMailingState, PersonMailingStateCode,PersonMailingStreet,PersonMobilePhone,PersonOtherPhone,Gender__c
                FROM Account
                WHERE id IN :accountIds]);
        return accountMap;
    }
}