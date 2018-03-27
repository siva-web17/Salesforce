/**
 * Created by arjun.mohan on 3/9/2018.
 */

public class CreateBookingController {

    @AuraEnabled
    public static IntermediateScreenWrapper dataBind(String recordId) {
        System.debug('Opportunity is ' + recordId);
        try {
            if (!String.isEmpty(recordId) && Id.valueOf(recordId).getSobjectType() == Opportunity.getSObjectType()) {
                List<Account> fetchAccount = new List<Account>();
                IntermediateScreenWrapper bindData = new IntermediateScreenWrapper();
                List<Opportunity> fetchopp = new List<Opportunity>();
                fetchopp = [
                        select id,SalesOffice__c,Market__c,Program__c,AccountId,IsActive__c
                        from Opportunity
                        where ID = :Id.valueOf(recordId) AND IsActive__c = TRUE
                        LIMIT 1
                ];
                System.debug('Opportunity is ' + fetchopp);
                bindData.opp = fetchopp[0];
                bindData.SalesOfficePickList = GetSalesOffice();
                if (fetchopp.size() > 0) {
                    fetchAccount = [
                            select id,Salutation,FirstName,MiddleName,LastName,PersonBirthdate,PersonOtherCity,PersonOtherState,
                                    PersonOtherPostalCode,PersonOtherStreet,PersonEmail,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,
                                    FirstNameEn__c,LastNameEn__c,Age__c,ParentEmail__c,PersonalID__c,PassportNumber__c,PassportType__c,OtherNationalities__c,
                                    PassportIssueDate__c,PassportExpiryDate__c,Nationality__c,NickName__c,Gender__c,BirthCountry__c,
                                    Email2__c,PersonMailingStreet,PersonMailingPostalCode,PersonMailingCity,PersonMailingCountry,InvoiceEmail__c,
                                    PersonMailingState
                            from Account
                            where ID = :bindData.opp.AccountId
                            LIMIT 1
                    ];
                    bindData.personAcc = fetchAccount[0];
                    System.debug('Account is ' + fetchAccount[0]);
                    bindData.age = fetchAccount[0].Age__c;
                    bindData.GenderPickList = GetGender();
                    bindData.NationalityPickList = GetNationality();
                    bindData.OtherNationalityPickList = GetOtherNationality();
                    bindData.PassportPickList = GetPassportType();
                    bindData.MailingCountryPickList = GetMailingCountry();
                    bindData.BirthCountryPickList = GetBirthCountry();
                    return bindData;
                } else {
                    throw new AuraHandledException('Label.NoActiveOpportunity');
                }
            } else {
                throw new AuraHandledException('InValid Record for create Booking');
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'CreatePriceQuoteController', 'openPoseidonToCreateQuote', null);
            throw new AuraHandledException(ex.getMessage());
        }

    }

    @AuraEnabled
    public static String updateAccountDetails(String wrapperData) {
        String retValue = '';
        System.debug('Sending data ' + wrapperData);
        Id currentrecord;
        IntermediateScreenWrapper BindWrapper = (IntermediateScreenWrapper) JSON.deserialize(wrapperData, IntermediateScreenWrapper.class);
        try {
            update BindWrapper.personAcc;
            retValue = SyncToPoseidonController.SyncComplicatedBookingToPoseidon(String.ValueOf(BindWrapper.personAcc.Id), true);
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'CreateBookingController', 'updateAccountDetails', currentrecord);
            System.debug('Dml exception :' + ex.getMessage());
        }
        return retValue;
    }

/*    @AuraEnabled
    public static String CreateBookingInPoseidon(String AccountId) {
        return SyncToPoseidonController.SyncComplicatedBookingToPoseidon(AccountId);
    }*/

    public static Map<String, String> GetGender() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Gender__c');
        //return JSON.serialize(genderMap);
    }

    public static Map<String, String> GetSalesOffice() {
        return FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'SalesOffice__c');
        //return JSON.serialize(genderMap);
    }

    public static Map<String, String> GetNationality() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Nationality__c');
        //return JSON.serialize(NationalityMap);
    }

    public static Map<String, String> GetOtherNationality() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'OtherNationalities__c');
        // return JSON.serialize(OtherNationalityMap);
    }

    public static Map<String, String> GetPassportType() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'PassportType__c');
        // return JSON.serialize(PassportMap);
    }

    public static Map<String, String> GetBirthCountry() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'BirthCountry__c');
        // return JSON.serialize(PassportMap);
    }

    public static Map<String, String> GetMailingCountry() {
        return FieldUtilityClass.getPickListValues(Contact.getSObjectType(), 'MailingCountryCode');
        // return JSON.serialize(PassportMap);
    }


    Public class IntermediateScreenWrapper {
        @AuraEnabled
        public Account personAcc { get; set; }
        @AuraEnabled
        public Opportunity opp { get; set; }
        @AuraEnabled
        public Decimal age { get; set; }
        @AuraEnabled
        public Map<String, String> GenderPickList { get; set; }
        @AuraEnabled
        public Map<String, String> MailingCountryPickList { get; set; }
        @AuraEnabled
        public Map<String, String> NationalityPickList { get; set; }
        @AuraEnabled
        public Map<String, String> OtherNationalityPickList { get; set; }
        @AuraEnabled
        public Map<String, String> PassportPickList { get; set; }
        @AuraEnabled
        public Map<String, String> SalesOfficePickList { get; set; }
        @AuraEnabled
        public Map<String, String> BirthCountryPickList { get; set; }

    }


}