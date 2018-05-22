public class PseudonymiseActionController {
    @AuraEnabled
    public static String PseudonymiseAccount(String recordId) {       
        Set<Id> accountIdSet=new Set<Id>();
        accountIdSet.add(recordId);
        Map<Id,Account> accountMap = AccountsSelector.getAccountBasedonAccountId(accountIdSet);        
        if(accountMap.containsKey(recordId))
        {
            if(accountMap.get(recordId).hasbooking__c){
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
