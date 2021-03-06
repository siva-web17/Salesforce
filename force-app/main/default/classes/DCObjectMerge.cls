/**
 * Created by shravan.boddula on 9/6/2017.
 */


public class DCObjectMerge {
    //lead to lead merge
    public static Lead leadToLeadFieldMerge(Lead existingLead, Lead incomingLead) {
        System.debug('existingLead '+existingLead.Id);
        System.debug('incomingLead Lead '+incomingLead.Id);
        //1. first Name
        String sFirstName = valueLength(existingLead.FirstName,incomingLead.FirstName);
        String sLastname = valueLength(existingLead.LastName,incomingLead.LastName);
        if(sFirstName==sLastname)
        {
            Map<String,String> existingNamesMap=New Map<String,String>();
            	existingNamesMap.put('FirstName', existingLead.FirstName);
                existingNamesMap.put('LastName', existingLead.LastName);
            Map<String,String> retainedNamesMap=New Map<String,String>();
                retainedNamesMap.put('FirstName', sFirstName);
                retainedNamesMap.put('LastName', sLastname);
           retainedNamesMap = getValidNames(retainedNamesMap,existingNamesMap);
            sFirstName=retainedNamesMap.get('FirstName');
            sLastname=retainedNamesMap.get('LastName');
        }
            
        existingLead.FirstName = sFirstName;
        //2. lastname
        existingLead.LastName=sLastname;
        //3. DOB
        existingLead.DOB__c = calculateAge(existingLead.DOB__c,incomingLead.DOB__c);
        //4. Mobile Phone, Home phone, Oher phone
        existingLead = phoneMerge(existingLead,incomingLead);
        //5. email merge
        existingLead = emailMerge(existingLead,incomingLead);
        //6. address mergealeim
        existingLead = addressMerge(existingLead,incomingLead);
         existingLead.status = existingLead.status=='closed'?'open':existingLead.status;
        //7. program merge
        
        //if(existingLead.Program__c == 'MULTI' || programMerge(DCBusinessFlow.sourceCustomerRequstType,DCBusinessFlow.latestCustomerRequsetType)) {
        if((existingLead.Program__c == Label.MULTI) || (incomingLead.RequestType__c != 'CAM')) {
            existingLead.Product__c = incomingLead.Product__c;
            existingLead.Program__c = incomingLead.Program__c;
        }
        existingLead.HasOptedOutOfEmail = false;
        existingLead.Email2OptOut__c = false;
        existingLead.DoNotMail__c = false;

        return existingLead;
    }

    //Lead to account merge
    public static Account leadtoAccountFieldMerge(Account duplicateAccount, Lead sourceLead) {
         //1. first Name
        String sFirstName = valueLength(duplicateAccount.FirstName,sourceLead.FirstName);
        String sLastname = valueLength(duplicateAccount.LastName,sourceLead.LastName);
        if(sFirstName==sLastname)
        {
            Map<String,String> existingNamesMap=New Map<String,String>();
            	existingNamesMap.put('FirstName', duplicateAccount.FirstName);
                existingNamesMap.put('LastName', duplicateAccount.LastName);
            Map<String,String> retainedNamesMap=New Map<String,String>();
                retainedNamesMap.put('FirstName', sFirstName);
                retainedNamesMap.put('LastName', sLastname);
           retainedNamesMap = getValidNames(retainedNamesMap,existingNamesMap);
            sFirstName=retainedNamesMap.get('FirstName');
            sLastname=retainedNamesMap.get('LastName');
        }
            
        duplicateAccount.FirstName = sFirstName;
        //2. lastname
        duplicateAccount.LastName=sLastname;
        //3. DOB
        duplicateAccount.PersonBirthdate= calculateAge(duplicateAccount.PersonBirthdate,sourceLead.DOB__c);
        //4. Mobile Phone, Home phone, other phone
        duplicateAccount = phoneLeadToAccountMerge(duplicateAccount,sourceLead);
        //5. email merge
        duplicateAccount = emailLeadToAccountMerge(duplicateAccount,sourceLead);
        //6. address merge
        duplicateAccount = addressLeadtoAccountMerge(duplicateAccount,sourceLead);
         duplicateAccount.recalculateranking__c = true;
         duplicateAccount.EmailOptOut__c = false;
         duplicateAccount.Email2OptOut__c = false;
         duplicateAccount.DoNotMail__c = false;
       

        return duplicateAccount;
    }

    public static void inActiveOpportunity(Opportunity opportunityRecord) {
        opportunityRecord.isActive__c = false;
        try{
            SObjectUnitOfWork.modifyOpportunity(opportunityRecord);
        }catch(exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'DCObjectMerge', 'inActiveOpportunity', opportunityRecord.Id);
        }
    }

    //return the longest string
    public static String valueLength(String oldValue,String newValue) {
        String temp = '';
        if((oldValue != null && oldValue.length() > 0) &&
                (newValue != null && newValue.length() > 0 )) {
            temp = oldValue.length() > newValue.length()?oldValue:newValue;
        }
        else if(oldValue == null) {
            temp = newValue;
        }
        else if(newValue == null) {
            temp = oldValue;
        }
        return temp;
    }

      private static Map<String,String> getValidNames(Map<String,String> retainedNamesMap,
                                                     Map<String,String> existingNamesMap)
    {
       for(String keyName:retainedNamesMap.KeySet())
       {
           if( retainedNamesMap.get(keyName)!=existingNamesMap.get(keyName))
           {
               retainedNamesMap.put(keyName, existingNamesMap.get(keyName));
           }
       }
       return retainedNamesMap;
    }
    //age calculation
    public static Date calculateAge(Date oldDate, Date newDate) {
        if(newDate != null) {
            return system.today().year() - newDate.year() > 50 ? oldDate : newDate;
        }
        return oldDate;
    }

    public static Boolean programMerge(String sourceLeadRequestType,String dulicateProgram) {
        Boolean isupdate= false;
        if(sourceLeadRequestType != null &&
                (sourceLeadRequestType == Label.Reservation || dulicateProgram == Label.MULTI)
               ) {
            isupdate = true;
        }
        return isupdate;
    }

    //mobile phone

    public static Lead phoneMerge(Lead extLead, Lead duplicateLead) {
        
        //Mobile Phone
        system.debug('My home phone>>>>>'+duplicateLead.Phone +extLead.phone);
        if(duplicateLead.MobilePhone != extLead.MobilePhone &&
                duplicateLead.MobilePhone != extLead.Phone &&
                duplicateLead.MobilePhone != extLead.OtherPhone__c &&
                duplicateLead.MobilePhone != NULL && duplicateLead.MobilePhone !='') {
            if(extLead.OtherPhone__c == NULL || extLead.OtherPhone__c =='') {
                extLead.OtherPhone__c = extLead.MobilePhone;
            }else if(extLead.Phone == NULL || extLead.Phone ==''){
                extLead.Phone = extLead.MobilePhone;
            }
            extLead.MobilePhone = duplicateLead.MobilePhone;
        }
        //HOme phone
        system.debug('The duplead phone'+duplicateLead.Phone +extLead.phone);
        if(duplicateLead.Phone != extLead.MobilePhone &&
                duplicateLead.Phone != extLead.Phone &&
                duplicateLead.Phone != extLead.OtherPhone__c &&
                duplicateLead.Phone != NULL && duplicateLead.Phone != '') {
                system.debug('hey hi i am here'+duplicateLead.Phone +extLead.phone);
            if(extLead.OtherPhone__c == NULL || extLead.OtherPhone__c=='') {
                extLead.OtherPhone__c = extLead.Phone;
            }else if(extLead.MobilePhone == NULL ||extLead.MobilePhone == ''){
                extLead.MobilePhone = extLead.Phone;
            }
            extLead.Phone = duplicateLead.Phone;
        }
        system.debug('The duplead phone1'+duplicateLead.Phone +extLead.phone);
        //other phone
        if(duplicateLead.OtherPhone__c != extLead.MobilePhone &&
                duplicateLead.OtherPhone__c != extLead.Phone &&
                duplicateLead.OtherPhone__c != extLead.OtherPhone__c &&
                duplicateLead.OtherPhone__c != NULL &&  duplicateLead.OtherPhone__c !='') {
            if(extLead.MobilePhone == NULL || extLead.MobilePhone == '') {
                extLead.MobilePhone = extLead.OtherPhone__c;
            }else if(extLead.Phone == NULL || extLead.Phone == ''){
                extLead.Phone = extLead.OtherPhone__c;
            }
            extLead.OtherPhone__c = duplicateLead.OtherPhone__c;
        }
         system.debug('The duplead phone2'+duplicateLead.Phone +extLead.phone);
        return extLead;
    }



    //Email merge logic
    public static Lead emailMerge(Lead extLead, Lead duplicateLead) {
        //Email 1
        if(duplicateLead.Email != extLead.Email &&
                duplicateLead.Email != extLead.Email2__c &&
                duplicateLead.Email != NULL) {
            if(extLead.Email2__c == NULL) {
                extLead.Email2__c = extLead.Email;
            }
            extLead.Email = duplicateLead.Email;
        }
        //Email 2
        if(duplicateLead.Email2__c != extLead.Email2__c &&
                duplicateLead.Email2__c != extLead.Email &&
                duplicateLead.Email2__c != NULL) {
            if(extLead.Email == NULL){
                extLead.Email = duplicateLead.Email2__c;
            }
            else {
                extLead.Email2__c = duplicateLead.Email2__c;
            }
        }
        return extLead;
    }


    //Address merge logic
    public static Lead addressMerge(Lead sourceLead, Lead duplicateLead) {
        if(sourceLead.Street == NULL && (
                duplicateLead.PostalCode != NULL ||
                        duplicateLead.City  != NULL ||
                        duplicateLead.Region__c != NULL
        )) {
            sourceLead.Street = duplicateLead.Street!=null ?
                    duplicateLead.Street : valueLength(sourceLead.Street, duplicateLead.Street);
            sourceLead.PostalCode = duplicateLead.PostalCode!=null?duplicateLead.PostalCode:sourceLead.PostalCode;
            sourceLead.City = duplicateLead.City!=null?duplicateLead.City:sourceLead.City;
            sourceLead.Region__c = duplicateLead.Region__c!=null?duplicateLead.Region__c:sourceLead.Region__c;
        }else if(duplicateLead.Street == NULL && sourceLead.Street != NULL){
            //
        }
        else if(!(sourceLead.Street == duplicateLead.Street &&
                ((sourceLead.PostalCode == duplicateLead.PostalCode
                        && sourceLead.Region__c == duplicateLead.Region__c
                        && sourceLead.City != duplicateLead.City)
                        ||
                        (sourceLead.PostalCode == duplicateLead.PostalCode
                                && sourceLead.Region__c != duplicateLead.Region__c
                                && sourceLead.City == duplicateLead.City)
                        ||
                        (sourceLead.PostalCode != duplicateLead.PostalCode
                                && sourceLead.Region__c == duplicateLead.Region__c
                                && sourceLead.City == duplicateLead.City))
        )){
            sourceLead.Street = duplicateLead.Street!=null?
                    duplicateLead.Street:valueLength(sourceLead.Street,duplicateLead.Street);
            sourceLead.PostalCode = (duplicateLead.PostalCode!=null && duplicateLead.PostalCode.isNumeric())?duplicateLead.PostalCode:sourceLead.PostalCode;
            sourceLead.City = duplicateLead.City!=null?duplicateLead.City:sourceLead.City;
            sourceLead.Region__c = duplicateLead.Region__c!=null?duplicateLead.Region__c:sourceLead.Region__c;
        }
        else{
            sourceLead.PostalCode = sourceLead.PostalCode!=null?sourceLead.PostalCode:duplicateLead.PostalCode;
            sourceLead.City = sourceLead.City!=null?sourceLead.City:duplicateLead.City;
            sourceLead.Region__c = sourceLead.Region__c!=null?sourceLead.Region__c:duplicateLead.Region__c;
        }

        return sourceLead;
    }


    public static Account phoneLeadToAccountMerge(Account extAccount, Lead duplicateLead) {

        //Mobile Phone 
        if(duplicateLead.MobilePhone != extAccount.PersonMobilePhone &&
                duplicateLead.MobilePhone != extAccount.PersonHomePhone &&
                duplicateLead.MobilePhone != extAccount.PersonOtherPhone &&
                duplicateLead.MobilePhone != NULL && duplicateLead.MobilePhone != '') {
            if(extAccount.PersonOtherPhone == NULL || extAccount.PersonOtherPhone =='') {
                extAccount.PersonOtherPhone = extAccount.PersonMobilePhone;
            }else if(extAccount.PersonHomePhone == NULL || extAccount.PersonHomePhone ==''){
                extAccount.PersonHomePhone = extAccount.PersonMobilePhone;
            }
            extAccount.PersonMobilePhone = duplicateLead.MobilePhone;

        }
        //HOme phone
        if(duplicateLead.Phone != extAccount.PersonMobilePhone &&
                duplicateLead.Phone != extAccount.PersonHomePhone &&
                duplicateLead.Phone != extAccount.PersonOtherPhone &&
                duplicateLead.Phone != NULL &&  duplicateLead.Phone !='') {
            if(extAccount.PersonOtherPhone == NULL || extAccount.PersonOtherPhone == '') {
                extAccount.PersonOtherPhone = extAccount.PersonHomePhone;
            }else if(extAccount.PersonMobilePhone == NULL || extAccount.PersonMobilePhone ==''){
                extAccount.PersonMobilePhone = extAccount.PersonHomePhone;
            }
            extAccount.PersonHomePhone = duplicateLead.Phone;

        }
        //other phone
        if(duplicateLead.OtherPhone__c != extAccount.PersonMobilePhone &&
                duplicateLead.OtherPhone__c != extAccount.PersonHomePhone &&
                duplicateLead.OtherPhone__c != extAccount.PersonOtherPhone &&
                duplicateLead.OtherPhone__c != NULL && duplicateLead.OtherPhone__c !='') {
            if(extAccount.PersonMobilePhone == NULL || extAccount.PersonMobilePhone =='') {
                extAccount.PersonMobilePhone = extAccount.PersonOtherPhone;
            }else if(extAccount.PersonHomePhone == NULL || extAccount.PersonHomePhone ==''){
                extAccount.PersonHomePhone = extAccount.PersonOtherPhone;
            }
            extAccount.PersonOtherPhone = duplicateLead.OtherPhone__c;
        }


        return extAccount;
    }

    public static Account emailLeadToAccountMerge(Account extAccount, Lead duplicateLead) {
        //Email 1
        if(duplicateLead.Email != extAccount.PersonEmail &&
                duplicateLead.Email != extAccount.Email2__c &&
                duplicateLead.Email != NULL) {
            if(extAccount.Email2__c == NULL) {
                extAccount.Email2__c = extAccount.PersonEmail;
            }
            extAccount.PersonEmail = duplicateLead.Email;
        }
        //Email 2
        if(duplicateLead.Email2__c != extAccount.Email2__c &&
                duplicateLead.Email2__c != extAccount.PersonEmail &&
                duplicateLead.Email2__c != NULL) {
            if(extAccount.PersonEmail == NULL){
                extAccount.PersonEmail = duplicateLead.Email2__c;
            }
            else {
                extAccount.Email2__c = duplicateLead.Email2__c;
            }
        }
        return extAccount;
    }


    public static Account addressLeadtoAccountMerge(Account duplicateAccount,Lead sourceLead) {
        if(duplicateAccount.PersonMailingStreet == NULL && (
                sourceLead.PostalCode != NULL ||
                        sourceLead.City  != NULL ||
                        sourceLead.Region__c != NULL
        )) {
            duplicateAccount.PersonMailingStreet = sourceLead.Street!=null?sourceLead.Street:duplicateAccount.PersonMailingStreet;
            duplicateAccount.PersonMailingPostalCode = (sourceLead.PostalCode!=null && sourceLead.PostalCode.isNumeric())?sourceLead.PostalCode:duplicateAccount.PersonMailingPostalCode;
            duplicateAccount.PersonMailingCity = sourceLead.City!=null?sourceLead.City:duplicateAccount.PersonMailingCity;
            duplicateAccount.Region__c = sourceLead.Region__c!=null?sourceLead.Region__c:duplicateAccount.Region__c;
        }else if(sourceLead.Street == NULL && duplicateAccount.PersonMailingStreet != NULL){
            //
        }

        else if(!(duplicateAccount.PersonMailingStreet == sourceLead.Street &&
                ((duplicateAccount.PersonMailingPostalCode == sourceLead.PostalCode
                        && duplicateAccount.Region__c == sourceLead.Region__c
                        && duplicateAccount.PersonMailingCity != sourceLead.City)
                        ||
                        (duplicateAccount.PersonMailingPostalCode == sourceLead.PostalCode
                                && duplicateAccount.Region__c != sourceLead.Region__c
                                && duplicateAccount.PersonMailingCity == sourceLead.City)
                        ||
                        (duplicateAccount.PersonMailingPostalCode != sourceLead.PostalCode
                                && duplicateAccount.Region__c == sourceLead.Region__c
                                && duplicateAccount.PersonMailingCity == sourceLead.City)
                ))){
           duplicateAccount.PersonMailingStreet = sourceLead.Street!=null?sourceLead.Street:duplicateAccount.PersonMailingStreet;
            duplicateAccount.PersonMailingPostalCode = (sourceLead.PostalCode!=null  && sourceLead.PostalCode.isNumeric())?sourceLead.PostalCode:duplicateAccount.PersonMailingPostalCode;
            duplicateAccount.PersonMailingCity = sourceLead.City!=null?sourceLead.City:duplicateAccount.PersonMailingCity;
            duplicateAccount.Region__c = sourceLead.Region__c!=null?sourceLead.Region__c:duplicateAccount.Region__c;
        }
        else{
             duplicateAccount.PersonMailingStreet = duplicateAccount.PersonMailingStreet!=null?duplicateAccount.PersonMailingStreet:sourceLead.Street;
            duplicateAccount.PersonMailingPostalCode = duplicateAccount.PersonMailingPostalCode!=null?duplicateAccount.PersonMailingPostalCode:sourceLead.PostalCode;
            duplicateAccount.PersonMailingCity = duplicateAccount.PersonMailingCity!=null?duplicateAccount.PersonMailingCity:sourceLead.City;
            duplicateAccount.Region__c = duplicateAccount.Region__c!=null?duplicateAccount.Region__c:sourceLead.Region__c;
        }
        return duplicateAccount ;
    }

}