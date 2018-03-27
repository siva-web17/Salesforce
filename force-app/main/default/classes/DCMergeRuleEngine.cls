public with sharing class DCMergeRuleEngine {
    /*This function has the logic of deciding what rule gets applied when there is an
    incoming Lead based on Bussiness logic
     */

    public static Map<String, LeadAccountMapping__c> leadAccountMapping = new Map<String, LeadAccountMapping__c>();
    public static Map<String, String> fieldAPIAndLabelMap = new Map<String, String>();
    public static Map<String,MergeRuleConfig__c> mergeRuleMap = new Map<String,MergeRuleConfig__c>();
    public static map<string, string> ruleNameAndTritonIdMap = new map<string, string>();
    public static String findAutoMergeRule(Lead sourceLead, Lead destLead, Account destAccount) {
        try {
            Boolean destHasBooking = destAccount != null ? destAccount.HasBooking__c : false;

            //query part is removed
            string resultantBinaryCode;
            string decision = '';
            string rulename;
            String binaryRuleCode = '';
            Map<String, LeadAccountMapping__c> leadAccountMapping = LeadAccountMapping__c.getAll();
            for (string field:fieldAPIAndLabelMap.keyset()) {
                //Lead
                 system.debug('Field is #####'+field);
                if (destLead != null) {
                    if (field == System.Label.HasBooking) {
                        binaryRuleCode += System.Label.StringZero;
                    } 
                    else if (field == System.Label.HomePhone|| field == System.Label.MobilePhone || field == System.Label.OtherPhone) {
                        if (
                                sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                        destLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ||

                                        sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                                destLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c)){

                            binaryRuleCode += System.Label.StringOne;
                        } 
                        else {
                            binaryRuleCode += System.Label.StringZero;
                        }
                    } 
                    else if(field == System.Label.EmailOneField || field == System.Label.EmailSecondField){
                        if(sourceLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ==
                                destLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ==
                                        destLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c) ==
                                        destLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c) ==
                                        destLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c)) {
                            binaryRuleCode+=System.Label.StringOne;

                        }
                        else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    }else {
                        if (sourceLead.get(leadAccountMapping.get(field).LeadAPIName__c) ==
                                destLead.get(leadAccountMapping.get(field).LeadAPIName__c) || (sourceLead.get(leadAccountMapping.get(field).LeadAPIName__c)==null || destLead.get(leadAccountMapping.get(field).LeadAPIName__c)==null)) {
                            binaryRuleCode+=System.Label.StringOne;
                        } else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    }
                }
                //Account
                else if (destAccount != null) {
                    if (field == System.Label.HasBooking) {
                        if (destAccount.HasBooking__c) {
                            binaryRuleCode+=System.Label.StringOne;
                        } else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    } else if (field == System.Label.HomePhone || field == System.Label.MobilePhone || field ==
                            System.Label.OtherPhone) {
                        if (sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                destAccount.get(leadAccountMapping.get(System.Label.HomePhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.MobilePhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.HomePhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.OtherPhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.MobilePhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.HomePhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.MobilePhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.OtherPhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.OtherPhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.MobilePhone).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.OtherPhone).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.HomePhone).AccountAPIName__c)
                                ) {
                            binaryRuleCode+=System.Label.StringOne;
                        } else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    }
                    else if(field == System.Label.EmailOneField || field == System.Label.EmailSecondField) {
                        if(sourceLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ==
                                destAccount.get(leadAccountMapping.get(System.Label.EmailOneField).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.EmailOneField).AccountAPIName__c) ||

                                sourceLead.get(leadAccountMapping.get(System.Label.EmailOneField).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.EmailSecondField).AccountAPIName__c) ||
                                sourceLead.get(leadAccountMapping.get(System.Label.EmailSecondField).LeadAPIName__c) ==
                                        destAccount.get(leadAccountMapping.get(System.Label.EmailSecondField).AccountAPIName__c)
                                ) {
                            binaryRuleCode += System.Label.StringOne;
                        }
                        else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    }
                    else {
                    system.debug('fieldval?????'+sourceLead.get(leadAccountMapping.get(field).LeadAPIName__c) +'accfieldval>>>>>'+destAccount.get(leadAccountMapping.get(field).AccountAPIName__c));
                        if (sourceLead.get(leadAccountMapping.get(field).LeadAPIName__c) ==
                                destAccount.get(leadAccountMapping.get(field).AccountAPIName__c) || (sourceLead.get(leadAccountMapping.get(field).LeadAPIName__c)==null || destAccount.get(leadAccountMapping.get(field).AccountAPIName__c)==null)) {
                            binaryRuleCode+=System.Label.StringOne;
                        } else {
                            binaryRuleCode+=System.Label.StringZero;
                        }
                    }
                }
                resultantBinaryCode =  binaryRuleCode;
            }
            //return the decision
            system.debug('My binary code is'+resultantBinaryCode);
            system.debug('My mregerulemapis@@@@@'+mergeRuleMap);
            if(mergeRuleMap.containsKey(resultantBinaryCode)) {

                if (ruleNameAndTritonIdMap.get(ruleName) != System.Label.StringNA && ruleNameAndTritonIdMap.get(ruleName) != null) {

                    if (sourceLead.TritonId__c == destLead.TritonId__c) {
                        if (ruleNameAndTritonIdMap.get(ruleName) == System.Label.StringTrue)
                            decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                    } else {
                        if (ruleNameAndTritonIdMap.get(ruleName) == System.Label.StringFalse) {
                            decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                        }
                    }
                } else {
                    decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                }


                system.debug('custom setting map contains binary key --- '+mergeRuleMap.get(resultantBinaryCode).name);
                system.debug('My decision is>>>>>'+mergeRuleMap.get(resultantBinaryCode).Decision__c);
               /* sourceLead.DuplicateRecordSets__c = mergeRuleMap.get(resultantBinaryCode).Decision__c + ' '+
                        mergeRuleMap.get(resultantBinaryCode).Name;*/
                return decision;
            }
            return '';
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'newIsMergeOrConvert', '');
            return '';
        }
    }

    public static void loadMergeConfigRuleData() {
        try {
            string [] customSettingRuleValues = new string[]{};
            String resultantBinaryCode = '';
            Map<String, Schema.SObjectField> fieldsMap = MergeRuleConfig__c.sObjectType.getDescribe().fields.getMap();
            for (String field : fieldsMap.keySet()) {
                Schema.SObjectField F = fieldsMap.get(field);
                Schema.DescribeFieldResult R = F.getDescribe();

                if (R.isCustom() && !(R.getLabel() == System.Label.Decision || R.getLabel() == System.Label.TritonId)) {
                    String fName = R.getName();
                    String fLabel = R.getLabel();
                    fieldAPIAndLabelMap.put(fLabel, fName);
                }
            }
            Map<String, MergeRuleConfig__c> mapCodes = new map<String, MergeRuleConfig__c>();
            //  mapcodes = MergeRuleConfig__c.getAll();
            mapcodes = CustomSettingsSelector.getMergeRuleConfig();
            for (MergeRuleConfig__c customSettng : mapCodes.values()) {
                ruleNameAndTritonIdMap.put(customSettng.name, String.valueOf(customSettng.TritonId__c));  //check with aditi..some deployment issues..
                String BinaryCode = '';
                for (String myFieldName:fieldAPIAndLabelMap.values()) {
                    binaryCode += string.valueof(customSettng.get(myFieldName)) == 'TRUE'?
                            System.Label.StringOne:System.Label.StringZero;
                }
                mergeRuleMap.put(binaryCode,customSettng);
                system.debug('custom setting map --- '+mergeRuleMap);
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'InitiateMergeConfigData', '');
        }
    }
}