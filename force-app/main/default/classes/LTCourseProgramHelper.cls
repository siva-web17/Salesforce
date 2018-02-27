/**
* Created by arjun.mohan on 02/1/2018.
*/

public  class LTCourseProgramHelper {


    public static Apttus_CPQApi.CPQ.AddOptionsResponseDO addSelectedLTCourseProgramLineItemToCart(Id cartId,
            List<Apttus_Config2__LineItem__c> lineItemList,
            Id selectedCourse,
            Date startDate,
            Date endDate,
            Double coursePrice){
        Id productId;
        Integer lineNumber = 0;
        Id priceListId;
        List<Id> confiigIdList=new List<Id>();
        List<Decimal> lineNumberLisr = new List<Decimal>();
        Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO;

        if (lineItemList != null  && lineItemList.size()>0){
            System.debug('Current price List is'+lineItemList[0].Apttus_Config2__PriceListId__c);

            System.debug('Selected product group'+lineItemList[0].Apttus_Config2__ProductId__c);
            productId = lineItemList[0].Apttus_Config2__ProductId__c;

            //productId=Id.valueOf('01t0E000001IILN');
            lineNumber = Integer.valueOf(lineItemList[0].Apttus_Config2__LineNumber__c);
            priceListId = lineItemList[0].Apttus_Config2__PriceListId__c;
            //priceListId=Id.valueOf('a280E000000JcdW');
            confiigIdList.add(cartId);
            lineNumberLisr.add(lineNumber);
        }
        //Here we are deleting the current Course Line item from the Bundle
        Apttus_Config2__LineItem__c deletecurrentCourseLineItem=null;
        for (Apttus_Config2__LineItem__c lineitemrecord:lineItemList) {
            System.debug('lineitemrecord'+lineitemrecord);
            if (lineitemrecord.APTS_Product_Type__c==Label.ProductTypeCourse) {
                deletecurrentCourseLineItem=new Apttus_Config2__LineItem__c();
                deletecurrentCourseLineItem=lineitemrecord;
                break;
            }
        }
        if (deletecurrentCourseLineItem!=null) {
            delete deletecurrentCourseLineItem;
        }
        List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptDOList = new List<Apttus_CPQApi.CPQ.SelectedOptionDO>();
        //Execute the getoptionGroups API to fetch the options with option groups
        Apttus_CPQApi.CPQ.ProductOptionGroupSearchResultDO result = Apttus_CPQApi.CPQWebService.getOptionGroupsForPriceListProduct(priceListId, ProductId);
        System.debug(' result  Line Item'+result);
        if (result.HasOptionGroups) {
            List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> prodOptGrpDOList = result.OptionGroups;
            for (Apttus_CPQApi.CPQ.ProductOptionGroupDO prodOptGrpDO : prodOptGrpDOList) {
                if (prodOptGrpDO.HasOptionComponents) {
                    List<Apttus_CPQApi.CPQ.ProductOptionComponentDO> prodOptCompDOList = new List<Apttus_CPQApi.CPQ.ProductOptionComponentDO>();
                    prodOptCompDOList = prodOptGrpDO.OptionComponents;
                    //Fetch all the option components for a particular option group.
                    for (Apttus_CPQApi.CPQ.ProductOptionComponentDO prodOptCompDO : prodOptCompDOList) {
                        if (prodOptCompDO.ComponentProductId==selectedCourse) {
                            Apttus_CPQApi.CPQ.SelectedOptionDO selectedOptDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
                            selectedOptDO.ComponentId = prodOptCompDO.ComponentId;
                            selectedOptDO.ComponentProductId = prodOptCompDO.ComponentProductId;
                            Double dQuantity = 1;
                            selectedOptDO.Quantity = dQuantity;
                            selectedOptDO.StartDate = startDate;
                            selectedOptDO.EndDate = endDate;
                            selectedOptDO.Comments = 'Added by Code';
                            selectedOptDOList.add(selectedOptDO);
                            break;
                        }

                    }
                }
            }
        }

        //Invoke the addOptions API and pass the cartID, selected product line number, and the Option List retrieved from the getoptiongroups API
        if (!selectedOptDOList.isEmpty()) {
            addOptRespDO  = Apttus_CPQApi.CPQWebService.addOptions(cartId, lineNumber, selectedOptDOList);
            Apttus_Config2__LineItem__c lineItem = addOptRespDO.addedOptionLineItems[0];
            lineItem.Apttus_Config2__BasePrice__c=coursePrice;

            //lineItem.updatePrice();
            System.debug('After Calling API' +lineItem);
        }
        return addOptRespDO;
    }



    public static list<Apttus_Config2__LineItem__c> getLineItems(Id currentCartId) {
        list<Apttus_Config2__LineItem__c> LineItems=new list<Apttus_Config2__LineItem__c>();
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Apttus_Config2__LineItem__c.FieldSets.EditStartEndDateFieldSet.getFields()) {
            query += f.getFieldPath() + ', ';
        }

        query += 'Id, Product_Subtype__c, Name, Beginner__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__LineType__c, APTS_EnableStartDateEndDate__c, Program__c, ';
        query += 'Apttus_Config2__Uom__c, Apttus_Config2__EndDate__c, APTS_QunatityModifiable__c, Apttus_Config2__StartDate__c, Apttus_Config2__Quantity__c, ';
        query += 'DestinationCode__c, Apttus_Config2__AttributeValueId__c,Apttus_Config2__ProductId__r.APTS_Destination_Location__c, Apttus_Config2__OptionId__r.APTS_AY_Course_Type__c,Apttus_Config2__OptionId__r.Available_Programs__c,Apttus_Config2__LineNumber__c, Apttus_Config2__OptionId__c, ';
        query += 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Market__c,Apttus_Config2__PriceListId__c ';
        query += 'from Apttus_Config2__LineItem__c ';
        query += 'where Apttus_Config2__ConfigurationId__c = : ' + 'currentCartId' + ' ' ;
        query += '  ORDER BY Apttus_Config2__LineNumber__c,Product_Code__c' ;
        System.debug('#################################### ' + query);
        LineItems = Database.query(query);

        return LineItems;
    }
}