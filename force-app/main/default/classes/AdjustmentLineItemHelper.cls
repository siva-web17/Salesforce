/**
 * Created by arjun.mohan on 10/12/2017.
 */

public class AdjustmentLineItemHelper {

    public static void updateAdjustmentLineItemFieldsBeforeInsert(List<Apttus_Config2__AdjustmentLineItem__c> adjustmentLineItemNewList) {
        Id currentRecordId;
        try {
            String uniqueRecord = '';
            String[] defaultArrayString=Utility.splitString(Label.DefaultTranslation,'-');
            List<string> UniqueStrings = new List<string>();
            //List<String> productsList = new List<String>();
            for (Apttus_Config2__AdjustmentLineItem__c adjustmentLineItemRecord : adjustmentLineItemNewList) {
                UniqueStrings.add( adjustmentLineItemRecord.APTS_Market__c + ' ' +  adjustmentLineItemRecord.APTS_Language__c+' '+adjustmentLineItemRecord.Apttus_Config2__IncentiveId__r.Apttus_Config2__IncentiveCode__c);
                uniqueRecord=defaultArrayString[0]+' '+defaultArrayString[1]+ ' '+adjustmentLineItemRecord.Apttus_Config2__IncentiveId__r.Apttus_Config2__IncentiveCode__c;
                //if (!UniqueStrings.contains(uniqueRecord)) {
                    UniqueStrings.add(uniqueRecord);
                //}
                //UniqueStrings.add();
            }

            if (UniqueStrings.size()>0) {


                Map<string, Translation__C> translationsMap = TranslationsSelector.getTranslationRecodrDetailsForIncentive(UniqueStrings);

                for (Apttus_Config2__AdjustmentLineItem__c adjustmentLineItemRecord : adjustmentLineItemNewList) {
                    currentRecordId=adjustmentLineItemRecord.Id;
                    //Added If and else if coz we have "Misc as Picklist value for LineType" in Proposal Line item

                    uniqueRecord = adjustmentLineItemRecord.APTS_Market__c + ' ' +  adjustmentLineItemRecord.APTS_Language__c+' '+adjustmentLineItemRecord.Apttus_Config2__IncentiveId__r.Apttus_Config2__IncentiveCode__c;
                    if (!translationsMap.containsKey(uniqueRecord)) {
                        //String[] defaultArrayString=Utility.splitString(Label.DefaultTranslation,'-');
                        if (defaultArrayString.size()>0 && defaultArrayString.size()>1) {
                            uniqueRecord=defaultArrayString[0]+' '+defaultArrayString[1]+ ' '+adjustmentLineItemRecord.Apttus_Config2__IncentiveId__r.Apttus_Config2__IncentiveCode__c;
                        }
                    }
                    system.debug('==uniqueRecord=='+uniqueRecord);
                    system.debug('==translationsMap=='+translationsMap);
                    if (translationsMap.containsKey(uniqueRecord)) {
                        system.debug('==uniqueRecord11=='+translationsMap.containsKey(uniqueRecord));
                        for (Schema.FieldSetMember f : SObjectType.Translation__c.FieldSets.ProductTranslationfieldSet.getFields()) {
                            adjustmentLineItemRecord.put(f.getFieldPath(), translationsMap.get(uniqueRecord).get(f.getFieldPath()));
                        }
                    }
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(),
                    'AdjustmentLineItemHelper', 'updateAdjustmentLineItemFieldsBeforeInsert', currentRecordId);
        }

    }
}