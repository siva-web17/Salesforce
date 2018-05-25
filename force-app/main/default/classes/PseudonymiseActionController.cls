public class PseudonymiseActionController {
    @AuraEnabled
    public static String PseudonymiseAccount(String recordId) {
        System.debug('Am here');
        Set<Id> accountIdSet=new Set<Id>();
        accountIdSet.add(recordId);
        Map<Id,Account> accountMap = AccountsSelector.getAccountBasedonAccountId(accountIdSet);
         Map<Id,List<Booking__c>> accountWithBookingMap = BookingsSelector.getBookingForAccountIds(accountIdSet);
        //System.debug(accountMap.size());
        if(accountMap.containsKey(recordId))
        {
            if(accountMap.get(recordId).IsPseudonymised__pc){
                throw new AuraHandledException(Label.AlreadyPseudonymised);                
            }
            if(accountMap.get(recordId).hasbooking__c || accountWithBookingMap.containsKey(recordId)){
                throw new AuraHandledException(Label.ErrorOnPseudonymisingBookingAccount);                
            }            
           boolean pseudonymisedSuccessfully = GDPRHelper.PseudonymiseAccount(accountMap);
            if(!pseudonymisedSuccessfully){
                throw new AuraHandledException(Label.AuraErrorMessage);           
            }          
        }    
        
        return '';
    }
}
