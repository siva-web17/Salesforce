/**
 * Created by Aditi.a on 5/23/2018.
 */
@isTest
public with sharing class PseudonymiseActionControllerTest {

    static testMethod void OnPseudomizeAccountCreatePseudoAccount(){
        Id recordTypeId = RecordTypesSelector.getActiveRecTypesByDevName(Account.SobjectType).get('PersonAccount').Id;
        String market = 'NOO';
        Map<String, String> personAccountFieldValues = new Map<String, String>{
                'Market__c' => market
        };
        Account newAccount = TestDataFactory.createPersonAccount('TestAccountFirstName', 'TestAccountFirstName', recordTypeId, personAccountFieldValues, True);
        test.starttest();
        PseudonymiseActionController.PseudonymiseAccount(newAccount.id);
        test.stoptest();
    }
}