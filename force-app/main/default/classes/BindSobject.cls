public class BindSobject {
    //Create list of wrapper to grab all sobject records

    @AuraEnabled
    public static SobjectBindWrapper dataBind(String QuoteId){
        Id currentrecord;
        SobjectBindWrapper bindData = new SobjectBindWrapper();
        try{

        Apttus_Proposal__Proposal__c fetchQuote = new Apttus_Proposal__Proposal__c();
        fetchQuote = [select id,Apts_Price_List__c,Apts_Price_List__r.Name,CurrencyIsoCode,Apttus_QPConfig__PriceListId__c,Apttus_QPConfig__PriceListId__r.year__c,
                     Apttus_QPConfig__PriceListId__r.Version__C,BookingType__c,BookingChannel__c ,SalesMadeby__c,SalesMadeby__r.name,
                     Apttus_Proposal__Account__c,Apttus_Proposal__Opportunity__c
                     from Apttus_Proposal__Proposal__c where id=:QuoteId];
            bindData.Quote =   fetchQuote;
            bindData.BookingTypePickList=GetBookingType();
            bindData.BookingChannelPickList=GetBookingChannel();
            bindData.CurrencyPickList=GetCurrency();
            System.debug('&&&&&&&&&&&Quote&&&&&&&&&'+bindData.Quote);

        Account fetchAccount = new Account();
        fetchAccount = [select id,Name,Salutation,RecordTypeID,RecordType.Name,FirstName,MiddleName,LastName,PersonBirthdate,PersonOtherCity,PersonOtherState,
                        PersonOtherPostalCode,PersonOtherStreet,PersonEmail,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,
                        FirstNameEn__c,LastNameEn__c,Language__C,Age__c,ParentEmail__c,PersonalID__c,PassportNumber__c,PassportType__c,OtherNationalities__c,
                        PassportIssueDate__c,PassportExpiryDate__c,Nationality__c,NickName__c,Gender__c,BirthCountry__c,
                        Email2__c,PersonMailingStreet,PersonMailingPostalCode,PersonMailingCity,PersonMailingCountry,
                        PersonMailingState from Account where ID =:fetchQuote.Apttus_Proposal__Account__c LIMIT 1];
            System.debug('^^^^^^^^^^^^^^^'+fetchAccount);
            bindData.personAcc = fetchAccount;
            bindData.age = fetchAccount.Age__c;
            bindData.GenderPickList=GetGender();
            bindData.NationalityPickList=GetNationality();
            bindData.OtherNationalityPickList=GetOtherNationality();
            bindData.PassportPickList=GetPassportType();
            bindData.MailingCountryPickList=GetMailingCountry();
            bindData.BirthCountryPickList=GetBirthCountry();
            System.debug('^^^^^^^^ bindData.personAcc^^^^^^^'+ bindData.personAcc);

        Opportunity fetchopp = new Opportunity();
        fetchopp = [select id,Name,StageName,AccountID,SalesOffice__c,OwnerId,Owner.Name,CloseDate,Market__c
                    from Opportunity where AccountID =: fetchAccount.Id];
            bindData.opp =   fetchopp;
            //bindData.SalesOfficePickList=GetSalesOffice();


            Apttus_Config2__PriceList__c fetchPrice = new Apttus_Config2__PriceList__c();
            fetchPrice = [select id,Year__c,Apttus_Config2__AccountId__c,Version__c from Apttus_Config2__PriceList__c
                          where id=:fetchQuote.Apttus_QPConfig__PriceListId__c];
            bindData.PriceList =   fetchPrice;
            System.debug('^^^^^^^^ bindData.PriceList^^^^^^^'+ bindData.PriceList);

            }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'dataBind', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
            }
        return bindData;
    }

//    public static Map<String, String> GetSalesOffice() {
//        return FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'SalesOffice__c');
//        return JSON.serialize(SalesOfficeMap);
//    }

    public static Map<String,String> GetGender() {
        return FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Gender__c');
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
       Map<String, String> MailingCountryMap = FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'MailingCountryCode');
       // Map<String,String> maplabelVal=new Map<String,String>();
//      Get the object type of the SObject.
        Schema.sObjectType objType = Contact.getSObjectType();
//      Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
//      Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
//      Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get('MailingCountryCode').getDescribe().getPickListValues();
//      Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){
            MailingCountryMap.put(a.getLabel(), a.getValue());
        }
        system.debug('Hello from server '+MailingCountryMap);
        return MailingCountryMap;
    }



    @AuraEnabled
    public static boolean createRecord(String wrapperData,Boolean isFinishBooking){
        Id currentrecord;

        System.debug('*************'+isFinishBooking);
        System.debug('*************'+wrapperData);

        SobjectBindWrapper listToSave = (SobjectBindWrapper)JSON.deserialize(wrapperData, SobjectBindWrapper.class);
        System.debug('*************'+listToSave);

        Account AccountUpdate = new Account();
        AccountUpdate.id = listToSave.personAcc.Id;
        AccountUpdate.FirstNameEn__c = listToSave.personAcc.FirstNameEn__c;
        AccountUpdate.LastNameEn__c = listToSave.personAcc.LastNameEn__c;
        AccountUpdate.PersonOtherPostalCode = listToSave.personAcc.PersonOtherPostalCode;
        AccountUpdate.PersonOtherCity = listToSave.personAcc.PersonOtherCity;
        AccountUpdate.PersonOtherStreet = listToSave.personAcc.PersonOtherStreet;
        AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        //System.debug('Before Update MiddleName=============> ' +AccountUpdate.MiddleName);
        AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        //System.debug('Updated MiddleName=============> ' +listToSave.personAcc.MiddleName);
        //System.debug('After Update MiddleName=============> ' +AccountUpdate.MiddleName);
        AccountUpdate.LastName = listToSave.personAcc.LastName;
        AccountUpdate.Salutation = listToSave.personAcc.Salutation;
        AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        AccountUpdate.LastName = listToSave.personAcc.LastName;
        AccountUpdate.PersonBirthdate = listToSave.personAcc.PersonBirthdate;
        AccountUpdate.PersonHomePhone = listToSave.personAcc.PersonHomePhone;
        AccountUpdate.Language__C = listToSave.personAcc.Language__C;
        AccountUpdate.PersonMobilePhone = listToSave.personAcc.PersonMobilePhone;
        AccountUpdate.PersonOtherPhone = listToSave.personAcc.PersonOtherPhone;
        AccountUpdate.Salutation = listToSave.personAcc.Salutation;
        AccountUpdate.Nationality__c = listToSave.personAcc.Nationality__c;
        System.debug('Nationality__c Value :'  +AccountUpdate.Nationality__c);
        AccountUpdate.OtherNationalities__c = listToSave.personAcc.OtherNationalities__c;
        AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        AccountUpdate.LastName = listToSave.personAcc.LastName;
        AccountUpdate.Gender__c = listToSave.personAcc.Gender__c;
       // AccountUpdate.Age__c = listToSave.personAcc.Age__c;
        AccountUpdate.NickName__c = listToSave.personAcc.NickName__c;
        System.debug('listToSave.personAcc.PersonMailingCountry ' +listToSave.personAcc.PersonMailingCountry);
        AccountUpdate.PersonMailingCountry = listToSave.personAcc.PersonMailingCountry;
        System.debug('AccountUpdate.PersonMailingCountry ' +AccountUpdate.PersonMailingCountry);
        AccountUpdate.PersonMailingCity = listToSave.personAcc.PersonMailingCity;
        AccountUpdate.PersonMailingState = listToSave.personAcc.PersonMailingState;
        AccountUpdate.PersonMailingStreet = listToSave.personAcc.PersonMailingStreet;
        AccountUpdate.PersonMailingPostalCode = listToSave.personAcc.PersonMailingPostalCode;
        System.debug('PersonMailingPostalCode ' +AccountUpdate.PersonMailingPostalCode);
       // AccountUpdate.BirthCountry__pc = listToSave.personAcc.BirthCountry__pc;
        AccountUpdate.PersonEmail = listToSave.personAcc.PersonEmail;
        AccountUpdate.Email2__c = listToSave.personAcc.Email2__c;
        AccountUpdate.BirthCountry__c = listToSave.personAcc.BirthCountry__c;
        AccountUpdate.ParentEmail__c = listToSave.personAcc.ParentEmail__c;
        AccountUpdate.PersonalID__c = listToSave.personAcc.PersonalID__c;
        AccountUpdate.PassportNumber__c = listToSave.personAcc.PassportNumber__c;
        AccountUpdate.PassportType__c = listToSave.personAcc.PassportType__c;
        AccountUpdate.PassportIssueDate__c = listToSave.personAcc.PassportIssueDate__c;
        AccountUpdate.PassportExpiryDate__c = listToSave.personAcc.PassportExpiryDate__c;
        try{
            if(AccountUpdate <> null) {
                update AccountUpdate;
                System.debug('BeforeAccountUpdate :' + listToSave.personAcc);
            }
            update AccountUpdate;
            System.debug('AccountUpdate :' + AccountUpdate);
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }

        Opportunity oppUpdate = new Opportunity();
        oppUpdate.Id = listToSave.opp.ID;
        System.debug('SalesOffice Value :'  +listToSave.opp.SalesOffice__c);
        oppUpdate.SalesOffice__c = listToSave.opp.SalesOffice__c;
        System.debug('SalesOffice Value :'  +oppUpdate.SalesOffice__c);
        // oppUpdate.OwnerId = listToSave.opp.OwnerId;
        oppUpdate.IntegrationStatus__c = 'Sent To Poseidon';
        oppUpdate.Market__c = listToSave.opp.Market__c;
        System.debug('Market Value :'  +oppUpdate.Market__c);
        oppUpdate.BookingCreationTime__c = System.now();
        try{
            update oppUpdate;
            System.debug('AccountUpdate :'  +AccountUpdate);

        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }

        Apttus_Config2__PriceList__c PLUpdate = new Apttus_Config2__PriceList__c();
        //PLUpdate.Id = listToSave.PriceList.ID;
        PLUpdate.Version__c = listToSave.PriceList.Version__c;
        PLUpdate.Year__c = listToSave.PriceList.Year__c;
        if(listToSave.PriceList <> null){
                PLUpdate.Id = listToSave.PriceList.ID;
                PLUpdate.Version__c = listToSave.PriceList.Version__c;
        }
         if(listToSave.PriceList.Version__c <> null){
                PLUpdate.Version__c = listToSave.PriceList.Version__c;
         }
        if(PLUpdate.Id == null){
                PLUpdate.Id = listToSave.PriceList.ID;
        }
            try{
                update PLUpdate;
                System.debug('^^^^^^^^  Updated PriceList^^^^^^^'+ PLUpdate);

            }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
                }

        Apttus_Proposal__Proposal__c QuoUpdate = new Apttus_Proposal__Proposal__c();
        QuoUpdate.Id = listToSave.Quote.ID;
        system.debug('PriceList version '+listToSave.Quote.Apttus_QPConfig__PriceListId__r.Version__c );

        QuoUpdate.CurrencyIsoCode = listToSave.Quote.CurrencyIsoCode;
        QuoUpdate.BookingType__c = listToSave.Quote.BookingType__c;
        QuoUpdate.BookingChannel__c = listToSave.Quote.BookingChannel__c;
        system.debug('Sales user ' +listToSave.Quote.SalesMadeby__c);
        QuoUpdate.SalesMadeby__c = listToSave.Quote.SalesMadeby__c;
        system.debug('QuoUpdate.SalesMadeby__c  ' +QuoUpdate.SalesMadeby__r.name);
        system.debug('Before Integration ' +isFinishBooking);
        /*if(QuoUpdate.IntegrationStatus__c <> null) {
            QuoUpdate.IntegrationStatus__c = (isFinishBooking) ? System.Label.Sent_To_Poseidon : '';
        }
        else{
            QuoUpdate.IntegrationStatus__c = (isFinishBooking) ? System.Label.Sent_To_Poseidon : '';
        }*/
        QuoUpdate.IntegrationStatus__c = (isFinishBooking) ? System.Label.Sent_To_Poseidon : '';
        system.debug('After Integration '+QuoUpdate.IntegrationStatus__c );
        try{
            update QuoUpdate;
            System.debug('QuoUpdate :'  +QuoUpdate);
        }
        catch(Exception ex){
					ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
       try{
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