/**
 * Created by britenet-patrykzak on 13/02/2018.
 */

public with sharing class CustomProfilePermissionsUtil {
    private static final CustomProfilePermissions__c SETTINGS = CustomProfilePermissions__c.getInstance();

    public static Boolean getSkipProposalQuoteDeletePrevent(){
        return SETTINGS != null ? SETTINGS.CanDeleteAllProposalQuotes__c : false;
    }
}
