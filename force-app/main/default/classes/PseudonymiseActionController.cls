public class PseudonymiseActionController {
    @AuraEnabled
    public static String PseudonymiseAccount(String recordId) {
        System.debug('Am here');
        Set<Id> accountIdSet=new Set<Id>();
        accountIdSet.add(recordId);
        Map<Id,Account> accountMap = AccountsSelector.getAccountBasedonAccountId(accountIdSet);
        //System.debug(accountMap.size());
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