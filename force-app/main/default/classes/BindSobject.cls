public class BindSobject {
    //Create list of wrapper to grab all sobject records
    //@AuraEnabled
    //Public List<SobjectBindWrapper> bindbedSobjectsToBeInserted;
    @AuraEnabled
    public static SobjectBindWrapper dataBind(String QuoteId){
        Id currentrecord;
        System.debug('&&&&&&&&&&&QuoteId&&&&&&&&&'+QuoteId);
        SobjectBindWrapper bindData = new SobjectBindWrapper();
        try{
        
        Apttus_Proposal__Proposal__c fetchQuote = new Apttus_Proposal__Proposal__c();
        fetchQuote = [select id,Apts_Price_List__c,Apts_Price_List__r.Name,CurrencyIsoCode,Apttus_QPConfig__PriceListId__c,Apttus_QPConfig__PriceListId__r.year__c,                     
                     Apttus_QPConfig__PriceListId__r.Version__C,BookingType__c,BookingChannel__c ,SalesMadeby__c,SalesMadeby__r.name,
                     Apttus_Proposal__Account__c,Apttus_Proposal__Opportunity__c
                     from Apttus_Proposal__Proposal__c where id=:QuoteId];
        bindData.Quote =   fetchQuote;
        System.debug('&&&&&&&&&&&Quote&&&&&&&&&'+bindData.Quote);
    
        Account fetchAccount = new Account();
        /*Id prsnRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        System.debug('*******************'+prsnRecordTypeId);*/
        fetchAccount = [select id,Name,Salutation,RecordTypeID,RecordType.Name,FirstName,MiddleName,LastName,PersonBirthdate,PersonOtherCity,PersonOtherState,
                        PersonOtherPostalCode,PersonOtherStreet,PersonEmail,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,
                        FirstNameEn__c,LastNameEn__c,Language__C,Age__c,ParentEmail__c,PersonalID__c,PassportNumber__c,PassportType__c,
                PassportIssueDate__c,PassportExpiryDate__c,Nationality__c,NickName__c,Gender__c,
                Email2__c,PersonMailingStreet,PersonMailingPostalCode,PersonMailingCity,PersonMailingCountry,
                        PersonMailingState from Account where ID =:fetchQuote.Apttus_Proposal__Account__c LIMIT 1];
            System.debug('^^^^^^^^^^^^^^^'+fetchAccount);
            bindData.personAcc = fetchAccount;
            bindData.age = fetchAccount.Age__c;
            System.debug('^^^^^^^^ bindData.personAcc^^^^^^^'+ bindData.personAcc);
 
        Opportunity fetchopp = new Opportunity();
        fetchopp = [select id,Name,StageName,AccountID,SalesOffice__c,OwnerId,Owner.Name,CloseDate
                    from Opportunity where AccountID =: fetchAccount.Id];
        bindData.opp =   fetchopp;
        
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
    
    @AuraEnabled
    public static String GetSalesOffice() {
        Map<String, String> SalesOffice = FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(), 'SalesOffice__c');
        return JSON.serialize(SalesOffice.keySet());
    }
    
    @AuraEnabled
    public static String GetGender() {
        Map<String, String> Gender = FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Gender__c');
        return JSON.serialize(Gender.keySet());
    }

    @AuraEnabled
    public static String GetBookingType() {
        Map<String, String> BookingType = FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'BookingType__c');
        return JSON.serialize(BookingType.keySet());
    }


   /* @AuraEnabled
    public static String GetBookingType() {
        Map<String, String> BookingType = FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'BookingType__c');

        Schema.SObjectField F = BookingType.get(Apttus_Proposal__Proposal__c.BookingType__c); //where fieldAPIName is API name of field
        Schema.DescribeFieldResult R = F.getDescribe();
        String fieldLabel=R.getLabel();
        return fieldLabel;
    }
    
        /*@AuraEnabled

	public static List<SelectOption> GetBookingType() {

        List<SelectOption> options = new List<SelectOption>();

        Schema.SObjectField F = fieldNameMap.get(fieldAPIName); //where fieldAPIName is API name of field
Schema.DescribeFieldResult R = F.getDescribe();
String fieldLabel=R.getLabel();
return fieldLabel;
    
        Schema.DescribeFieldResult fieldResult = Apttus_Proposal__Proposal__c.BookingType__c.getDescribe();
    
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
		
		}*/

    @AuraEnabled
    public static String GetBookingChannel() {
        Map<String, String> BookingChannel = FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'BookingChannel__c');
        return JSON.serialize(BookingChannel.keySet());
    }
    
    
    @AuraEnabled
    public static String GetCurrency() {
        Map<String, String> CurrencyVal = FieldUtilityClass.getPickListValues(Apttus_Proposal__Proposal__c.getSObjectType(), 'CurrencyIsoCode');
        return JSON.serialize(CurrencyVal.keySet());
    }
    
    @AuraEnabled
    public static String GetNationality() {
        Map<String, String> Nationality = FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'Nationality__c');
        return JSON.serialize(Nationality.keySet());
    }
    @AuraEnabled
    public static String GetPassportType() {
        Map<String, String> PassportType = FieldUtilityClass.getPickListValues(Account.getSObjectType(), 'PassportType__c');
        return JSON.serialize(PassportType.keySet());
    }
    
    @AuraEnabled
    public static String GetCountryValues() {
        Map<String, String> maillingCountry = FieldUtilityClass.getCountryPickListValues();
        system.debug('return=====>' +JSON.serialize(maillingCountry.keySet()));
        return JSON.serialize(maillingCountry.keySet());
        
    }
    
     @AuraEnabled
    public static String GetStateValues() {
        Map<String, String> maillingState = FieldUtilityClass.getStatePickListValues();
        system.debug('return=====>' +JSON.serialize(maillingState.keySet()));
        return JSON.serialize(maillingState.keySet());
        
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
        //AccountUpdate.PersonOtherState = listToSave.personAcc.PersonOtherState;
        AccountUpdate.PersonOtherStreet = listToSave.personAcc.PersonOtherStreet;
        AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        System.debug('Before Update MiddleName=============> ' +AccountUpdate.MiddleName);
        AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        System.debug('Updated MiddleName=============> ' +listToSave.personAcc.MiddleName);
        System.debug('After Update MiddleName=============> ' +AccountUpdate.MiddleName);
        AccountUpdate.LastName = listToSave.personAcc.LastName;
        AccountUpdate.Salutation = listToSave.personAcc.Salutation;

        if(listToSave.personAcc.FirstName <> null){
            AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        }
        if(listToSave.personAcc.MiddleName <> null){
            AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        }
        if(listToSave.personAcc.LastName <> null){
            AccountUpdate.LastName = listToSave.personAcc.LastName;
        }
        AccountUpdate.PersonBirthdate = listToSave.personAcc.PersonBirthdate;
        AccountUpdate.PersonHomePhone = listToSave.personAcc.PersonHomePhone;
        AccountUpdate.Language__C = listToSave.personAcc.Language__C;
        AccountUpdate.PersonMobilePhone = listToSave.personAcc.PersonMobilePhone;
        AccountUpdate.PersonOtherPhone = listToSave.personAcc.PersonOtherPhone;
        if(listToSave.personAcc.Salutation <> null){
            AccountUpdate.Salutation = listToSave.personAcc.Salutation;
        }
        AccountUpdate.Nationality__c = listToSave.personAcc.Nationality__c;
        AccountUpdate.FirstName = listToSave.personAcc.FirstName;
        AccountUpdate.MiddleName = listToSave.personAcc.MiddleName;
        AccountUpdate.LastName = listToSave.personAcc.LastName;
        AccountUpdate.Gender__c = listToSave.personAcc.Gender__c;
       // AccountUpdate.Age__c = listToSave.personAcc.Age__c;
        AccountUpdate.NickName__c = listToSave.personAcc.NickName__c;
        AccountUpdate.PersonMailingCountry = listToSave.personAcc.PersonMailingCountry;
        AccountUpdate.PersonMailingCity = listToSave.personAcc.PersonMailingCity;
        AccountUpdate.PersonMailingState = listToSave.personAcc.PersonMailingState;
        AccountUpdate.PersonMailingStreet = listToSave.personAcc.PersonMailingStreet;
       // AccountUpdate.BirthCountry__pc = listToSave.personAcc.BirthCountry__pc;
        AccountUpdate.PersonEmail = listToSave.personAcc.PersonEmail;
        AccountUpdate.Email2__c = listToSave.personAcc.Email2__c;
        AccountUpdate.ParentEmail__c = listToSave.personAcc.ParentEmail__c;
        AccountUpdate.PersonalID__c = listToSave.personAcc.PersonalID__c;
        AccountUpdate.PassportNumber__c = listToSave.personAcc.PassportNumber__c;
        AccountUpdate.PassportType__c = listToSave.personAcc.PassportType__c;
        AccountUpdate.PassportIssueDate__c = listToSave.personAcc.PassportIssueDate__c;
        AccountUpdate.PassportExpiryDate__c = listToSave.personAcc.PassportExpiryDate__c;
        try{
            update AccountUpdate;
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'BindSobject', 'createRecord', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
                
        Opportunity oppUpdate = new Opportunity();
        oppUpdate.Id = listToSave.opp.ID;
        oppUpdate.SalesOffice__c = listToSave.opp.SalesOffice__c;
        // oppUpdate.OwnerId = listToSave.opp.OwnerId;
        oppUpdate.IntegrationStatus__c = 'Sent To Poseidon';
        oppUpdate.BookingCreationTime__c = System.now();
        try{
            update oppUpdate;
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
        system.debug('Null here '+listToSave.Quote.Apttus_QPConfig__PriceListId__r.Version__c );
        /*if(listToSave.Quote.Apttus_QPConfig__PriceListId__r.Version__c != null){
         QuoUpdate.Apttus_QPConfig__PriceListId__r.Version__c = listToSave.Quote.Apttus_QPConfig__PriceListId__r.Version__c;
        }*/

        QuoUpdate.CurrencyIsoCode = listToSave.Quote.CurrencyIsoCode; 
        QuoUpdate.BookingType__c = listToSave.Quote.BookingType__c;
        QuoUpdate.BookingChannel__c = listToSave.Quote.BookingChannel__c;
                system.debug('Sales user ' +listToSave.Quote.SalesMadeby__c);
        QuoUpdate.SalesMadeby__c = listToSave.Quote.SalesMadeby__c;
                system.debug('QuoUpdate.SalesMadeby__c  ' +QuoUpdate.SalesMadeby__c);

        system.debug('Null here ' +isFinishBooking);

        QuoUpdate.IntegrationStatus__c =(isFinishBooking)? 'Sent To Poseidon':'';
        system.debug('Null here '+listToSave.Quote.IntegrationStatus__c );


        try{
            update QuoUpdate;
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
           
        }
    
    // For returning List in Aura Enable	
		public class SelectOption {
    public SelectOption(String value, String label) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.escapeItem = false;
    }

    public SelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = isDisabled;
        this.escapeItem = false;
    }

    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    @AuraEnabled
    public Boolean disabled { get;set; }
    @AuraEnabled
    public Boolean escapeItem { get;set; }

}
    
}