/**************************************************************************************
Apex Class Name    : APTS_PriceMatrixEntrySelector
Version            : 1.0
Created Date       : September 15 2017
Function           : This is created for all SOQL queries on Price Matrix OOTB object.
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Mitul Parmar                 09/14/2017              Original Version
*******************************************************************************/
public  class APTS_PriceMatrixEntriesSelector {
    /*
    Description : Helper Method to select required field for course pricing, limit wil always be 2 since only higher and lower values will be selected
    Created by : Mitul Parmar
    Created Date : 15-Sep-2017
    Modified by:Arjun.M
    */
    public static List<Apttus_Config2__PriceMatrixEntry__c> getPriceMatrixForOptions(Id priceListItemId, String destinationCode){
        return [select id, Apttus_Config2__Dimension1Value__c, Apttus_Config2__AdjustmentAmount__c
        from Apttus_Config2__PriceMatrixEntry__c
        where Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c = :priceListItemId
        and Apttus_Config2__Dimension2Value__c = :destinationCode
        order by Apttus_Config2__Sequence__c  limit 2];
    }

    public static Map<String,List<Apttus_Config2__PriceMatrixEntry__c>> getMapOfPriceMatrixForOptions(List<Id> priceListItemIdList, List<String> destinationCodeList){
        Map<String,List<Apttus_Config2__PriceMatrixEntry__c>>  priceMatrixForOptionsMap=new  Map<String,List<Apttus_Config2__PriceMatrixEntry__c>>();
        List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList= [select id, Apttus_Config2__Sequence__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c,Apttus_Config2__Dimension2Value__c,Apttus_Config2__Dimension1Value__c, Apttus_Config2__AdjustmentAmount__c
        from Apttus_Config2__PriceMatrixEntry__c
        where Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c in :priceListItemIdList
        and Apttus_Config2__Dimension2Value__c in :destinationCodeList
        order by Apttus_Config2__Sequence__c  ];
system.debug('from soql'+priceMatrixEntryList);
        String priceMatrixKey='';

        for  ( Apttus_Config2__PriceMatrixEntry__c priceMatricRecord:priceMatrixEntryList) {
            List<Apttus_Config2__PriceMatrixEntry__c> temppriceMatrixEntryList=new  List<Apttus_Config2__PriceMatrixEntry__c>();
            priceMatrixKey=priceMatricRecord.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c +priceMatricRecord.Apttus_Config2__Dimension2Value__c;
            system.debug('Pricekey'+priceMatrixKey);
            if (priceMatrixForOptionsMap.containsKey(priceMatrixKey)) {
                system.debug('Before adding to List'+priceMatrixForOptionsMap.get(priceMatrixKey));
                temppriceMatrixEntryList= priceMatrixForOptionsMap.get(priceMatrixKey);
                temppriceMatrixEntryList.add(priceMatricRecord);
                system.debug('After adding to List'+temppriceMatrixEntryList);
                    priceMatrixForOptionsMap.put(priceMatrixKey,temppriceMatrixEntryList);
            }
            else
            {
                temppriceMatrixEntryList.add(priceMatricRecord);
                system.debug('First time to MAP'+priceMatricRecord);
                priceMatrixForOptionsMap.put(priceMatrixKey,temppriceMatrixEntryList);
            }
        }
        system.debug('Hello Test here eFinal'+priceMatrixForOptionsMap);
        return priceMatrixForOptionsMap;
    }
}