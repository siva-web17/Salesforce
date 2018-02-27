public class BindSobject {
    //Create list of wrapper to grab all sobject records.

    @AuraEnabled
    public static SobjectBindWrapper dataBind(String QuoteId){
        Id currentrecord;
        System.debug('&&&&&&&&&&&QuoteId&&&&&&&&&'+QuoteId);
        SobjectBindWrapper bindData = new SobjectBindWrapper();
        try{
            List<Apttus_Proposal__Proposal__c> fetchQuote = new List<Apttus_Proposal__Proposal__c>();
            fetchQuote = [select id,Apttus_QPConfig__PriceListId__c,CurrencyIsoCode,BookingType__c,BookingChannel__c ,SalesMadeby__c,SalesMadeby__r.name,
                    Apttus_Proposal__Account__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.AccountId from Apttus_Proposal__Proposal__c where id=: QuoteId LIMIT 1];
            if(fetchQuote == null || fetchQuote.size() == 0) {
                return null;
            }
                bindData.Quote = fetchQuote[0];
                bindData.BookingTypePickList = GetBookingType();
                bindData.BookingChannelPickList = GetBookingChannel();
                bindData.CurrencyPickList = GetCurrency();
                System.debug('&&&&&&&&&&&Quote&&&&&&&&&' + bindData.Quote);

            List<Account> fetchAccount = new List<Account>();
            fetchAccount = [select id,Salutation,FirstName,MiddleName,LastName,PersonBirthdate,PersonOtherCity,PersonOtherState,
                    PersonOtherPostalCode,PersonOtherStreet,PersonEmail,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,
                    FirstNameEn__c,LastNameEn__c,Age__c,ParentEmail__c,PersonalID__c,PassportNumber__c,PassportType__c,OtherNationalities__c,
                    PassportIssueDate__c,PassportExpiryDate__c,Nationality__c,NickName__c,Gender__c,BirthCountry__c,
                    Email2__c,PersonMailingStreet,PersonMailingPostalCode,PersonMailingCity,PersonMailingCountry,
                    PersonMailingState from Account where ID =: bindData.Quote.Apttus_Proposal__Opportunity__r.AccountId LIMIT 1];
            System.debug('^^^^^^^^^^^^^^^'+fetchAccount);
            bindData.personAcc = fetchAccount[0];
            bindData.age = fetchAccount[0].Age__c;
            bindData.GenderPickList=GetGender();
            bindData.NationalityPickList=GetNationality();
            bindData.OtherNationalityPickList=GetOtherNationality();
            bindData.PassportPickList=GetPassportType();
            bindData.MailingCountryPickList=GetMailingCountry();
            bindData.BirthCountryPickList=GetBirthCountry();
            System.debug('^^^^^^^^ bindData.personAcc^^^^^^^'+ bindData.personAcc);

            List<Opportunity> fetchopp = new List<Opportunity>();
            fetchopp = [select id,SalesOffice__c,Market__c,Program__c
            from Opportunity where ID =: bindData.Quote.Apttus_Proposal__Opportunity__c LIMIT 1];
            bindData.opp =   fetchopp[0];
            bindData.SalesOfficePickList = GetSalesOffice();
            System.debug('^^^^^^^^ bindData.opp^^^^^^^'+ bindData.opp);


            List<Apttus_Config2__PriceList__c> fetchPrice = new List<Apttus_Config2__PriceList__c>();
            fetchPrice = [select id,Year__c,Apttus_Config2__AccountId__c,Version__c from Apttus_Config2__PriceList__c
            where ID=: bindData.Quote.Apttus_QPConfig__PriceListId__c LIMIT 1];
            bindData.PriceList =   fetchPrice[0];
            System.debug('^^^^^^^^ bindData.PriceList^^^^^^^'+ bindData.PriceList);

        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'dataBind', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
        return bindData;
    }

    public static Map<String,String> GetGender() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Gender__c');
        //return JSON.serialize(genderMap);
    }

    public static Map<String,String> GetSalesOffice() {
        return FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'SalesOffice__c');
        //return JSON.serialize(genderMap);
    }

    public static Map<String, String> GetBookingType() {
        return FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'BookingType__c');
        //return JSON.serialize(BookingMap);
    }

    public static Map<String, String> GetBookingChannel() {
        return FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'BookingChannel__c');
        //return JSON.serialize(BookingChannelMap);
    }

    public static Map<String, String> GetCurrency() {
        return FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'CurrencyIsoCode');
        //return JSON.serialize(CurrencyMap);
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


    @AuraEnabled
    public static boolean createRecord(String wrapperData,Boolean isFinishBooking, String QuoteId){
        system.debug('QuoteIdincreateRecord>>'+QuoteId);
        Id currentrecord;

        System.debug('*************'+isFinishBooking);
        System.debug('*************'+wrapperData);

        SobjectBindWrapper BindWrapper = (SobjectBindWrapper)JSON.deserialize(wrapperData, SobjectBindWrapper.class);
        try{
            update BindWrapper.personAcc;
            System.debug('After updating account :'+BindWrapper.personAcc);
            System.debug('After updating Opportunity :'+BindWrapper.opp);
            System.debug('After updating Opportunity :'+BindWrapper.opp.SalesOffice__c);
            System.debug('After updating PriceList :'+BindWrapper.PriceList);

        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }

        Apttus_Proposal__Proposal__c QuoUpdate = new Apttus_Proposal__Proposal__c();
        QuoUpdate.Id = BindWrapper.Quote.ID;
        system.debug('PriceList version '+BindWrapper.Quote.Apttus_QPConfig__PriceListId__c );

        QuoUpdate.CurrencyIsoCode = BindWrapper.Quote.CurrencyIsoCode;
        QuoUpdate.BookingType__c = BindWrapper.Quote.BookingType__c;
        QuoUpdate.BookingChannel__c = BindWrapper.Quote.BookingChannel__c;
        system.debug('Before Integration ' +isFinishBooking);
        QuoUpdate.IntegrationStatus__c = (isFinishBooking) ? System.Label.Sent_To_Poseidon : '';
        system.debug('After Integration '+QuoUpdate );
        try{
            update QuoUpdate;
            System.debug('QuoUpdate :'  +QuoUpdate);
            //Call Scribe Service after updating the quote
            InvokeScribe.InvokeScribeAfterFinishBooking_Async(QuoUpdate.Id);
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
        try{

            Apttus_Proposal__Proposal__c QuoteAfterUpdate = new Apttus_Proposal__Proposal__c();
            QuoteAfterUpdate = [select id,SalesMadeby__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id=: QuoteId LIMIT 1];
            system.debug('QuoteAfterUpdate'+QuoteAfterUpdate);
            Booking__c bookingRecord = new Booking__c();
            bookingRecord.BrochureSeason__c = BindWrapper.PriceList.Version__c;
            bookingRecord.BrochureYear__c =Decimal.valueOf(BindWrapper.PriceList.Year__c);
            bookingRecord.AccountId__c = BindWrapper.personAcc.id;
            System.debug('SalesMadeby__c before :'  + QuoteAfterUpdate.SalesMadeby__c);
            bookingRecord.MainSalesResponsible__c = QuoteAfterUpdate.SalesMadeby__c;
            System.debug('MainSalesResponsible__c after :'  + bookingRecord.MainSalesResponsible__c);
            bookingRecord.Program__c = BindWrapper.opp.Program__c;
            bookingRecord.CurrencyIsoCode = QuoUpdate.CurrencyIsoCode;
            bookingRecord.SalesOffice__c = BindWrapper.opp.SalesOffice__c;
            System.debug('bookingRecord.SalesOffice__c :'  + bookingRecord.SalesOffice__c);
            System.debug('BindWrapper.opp.SalesOffice__c :'  + BindWrapper.opp.SalesOffice__c);
            bookingRecord.OpportunityId__c=BindWrapper.opp.Id;
            bookingRecord.QuoteId__c=QuoUpdate.Id;
            bookingRecord.Integrationstatus__c = System.Label.Sent_To_Poseidon;
            insert bookingRecord;
            System.debug('bookingRecord :'  + bookingRecord);
            return true;
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
            return false;
        }
    }
    //Wrapper for binding all sobject to reduce multiple DML transaction and to avoid Mixed DML
    Public class SobjectBindWrapper{
        @AuraEnabled
        public Account personAcc {get;set;}
        @AuraEnabled
        public Opportunity opp {get;set;}
        @AuraEnabled
        public Apttus_Config2__PriceList__c PriceList {get;set;}
        @AuraEnabled
        public Apttus_Proposal__Proposal__c Quote {get;set;}
        @AuraEnabled
        public Decimal age {get;set;}
        @AuraEnabled
        public Map<String,String> GenderPickList{get;set;}
        @AuraEnabled
        public Map<String,String> MailingCountryPickList{get;set;}
        @AuraEnabled
        public Map<String,String> NationalityPickList{get;set;}
        @AuraEnabled
        public Map<String,String> OtherNationalityPickList{get;set;}
        @AuraEnabled
        public Map<String,String> PassportPickList{get;set;}
        @AuraEnabled
        public Map<String,String> BookingChannelPickList{get;set;}
        @AuraEnabled
        public Map<String,String> BookingTypePickList{get;set;}
        @AuraEnabled
        public Map<String,String> SalesOfficePickList{get;set;}
        @AuraEnabled
        public Map<String,String> CurrencyPickList{get;set;}
        @AuraEnabled
        public Map<String,String> BirthCountryPickList{get;set;}

    }

}