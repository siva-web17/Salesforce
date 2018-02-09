/**************************************************************************************
Apex Class Name    : EditStartEndDateController
Version            : 1.0
Created Date       : October 20 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arjun.Mohan                 10/1/2017              Original Version
*******************************************************************************/
//Class is global as we are using this class as we have remoting method in this class
global class EditStartEndDateController {
    public list<BundleWrapper> bundleWrapperList { get; set; }
    public Id currentRecordId { get; set; }
    public String selectedSite { get; set; }
    public Id currentLineItemId;
    public static String configId2 { get; set; }
    public String flowName;
    public static String configRequestId { get; set; }
    public static String cartStatus{ get; set; }
    public static String cartFlow{ get; set; }
    public static String backCartUrl{ get; set; }
    public static pageReference pr;
    public static Apttus_Config2__LineItem__c currentLineItem;
    public static String currentLineItemJSON { get; set; }
    public static List<Apttus_Config2__LineItem__c> configLineItemList { get; set; }
    public static String configLineItemListJSON { get; set; }
    public static String startdateJSONString { get; set; }
    Public static List<Start_Dates__c> startDateList { get; set; }
    public static final Integer COURSEOFFSET = 4;

    //This Constructor will get line items for all the selected bundles where start date is enabled
    public EditStartEndDateController() {
        System.debug('####################################  in constructor' );
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        this.bundleWrapperList = new list<BundleWrapper>();
        configLineItemList = new List<Apttus_Config2__LineItem__c>();
        prepareBundleWrapper();

        configId2 = ApexPages.currentPage().getParameters().get('id');
        configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        cartStatus = ApexPages.currentPage().getParameters().get('cartStatus');
        cartFlow = ApexPages.currentPage().getParameters().get('flow');
        backCartUrl = Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId;
              System.debug('Path:: '+Site.getPathPrefix());
        
        if(cartStatus != NULL){
            backCartUrl = backCartUrl +'&cartStatus=' + cartStatus;
        }
        if(cartFlow != NULL){
            backCartUrl = backCartUrl + '&flow=' +cartFlow;
        }
    }

    public PageReference prepareBundleWrapper() {
        if (currentRecordId != null) {
            configLineItemList = getLineItem();
            for (Apttus_Config2__LineItem__c lineItem : configLineItemList) {
                this.bundleWrapperList.add(new BundleWrapper(false, lineItem));
            }
        }
        return null;
    }

    //This Method will get available start dates for selected destination in startdate page
    public static void GetAvailableStartDates(String courseCode, String destination, Boolean isBeginner, String programCode) {
        startDateList = StartDateHelper.getAvailableStartDates(courseCode, destination, isBeginner, true, programCode);
        startdateJSONString = JSON.serialize(startDateList);
    }

    //Please revisit this method
    //This method will get the profile access for the user if he is system admin then he can get to see th previous start dates
    /*public static Boolean getUserProfileForAccess() {
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        Boolean canAccess = false;
        List<ProfileNamesForAdminAccess__mdt> adminmetdaDataList = StartDatesSelector.getProfilesForAdminAccess('Start_Dates__c');
        for (ProfileNamesForAdminAccess__mdt metaDataRecord : adminmetdaDataList) {
            string[] profiles = Utility.splitString(metaDataRecord.Profiles__c, ',');
            for (String profilename : profiles) {
                if (profilename == MyProflieName) {
                    canAccess = true;
                }
            }
        }
        return canAccess;
    }*/

    //Get the line items for selected config
    public list<Apttus_Config2__LineItem__c> getLineItem() {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.Apttus_Config2__LineItem__c.FieldSets.EditStartEndDateFieldSet.getFields()) {
            query += f.getFieldPath() + ', ';
        }

        query += 'Id, Product_Subtype__c, Name, Beginner__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__LineType__c, APTS_EnableStartDateEndDate__c, Program__c, ';
        query += 'Apttus_Config2__Uom__c, Apttus_Config2__EndDate__c, APTS_QunatityModifiable__c, Apttus_Config2__StartDate__c, Apttus_Config2__Quantity__c, ';
        query += 'DestinationCode__c, Apttus_Config2__ProductId__r.APTS_Destination_Location__c, Apttus_Config2__LineNumber__c, Apttus_Config2__OptionId__c, ';
        query += 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Market__c ';
        query += 'from Apttus_Config2__LineItem__c ';
        query += 'where Apttus_Config2__ConfigurationId__c = : ' + 'currentRecordId' + ' ' ;
        query += ' and APTS_EnableStartDateEndDate__c = TRUE ORDER BY Apttus_Config2__LineNumber__c,Product_Code__c' ;
        System.debug('#################################### ' + query);
        configLineItemList = Database.query(query);
        configLineItemListJSON = JSON.serialize(configLineItemList);
        return configLineItemList;
    }

    /*public List<SelectOption> getSitesOptions() {
        List<SelectOption> sitesOptions = new List<SelectOption>();
        sitesOptions.add(new SelectOption('', '-None-'));

        return sitesOptions;
    }*/

    //Get the selected item from check box in start date page
    public list<Apttus_Config2__LineItem__c> getSelectedLineItemsList {
        get {
            list<Apttus_Config2__LineItem__c> selectedLineItemsList = new list<Apttus_Config2__LineItem__c>();
            try {

                if (!this.bundleWrapperList.isEmpty()) {
                    for (BundleWrapper wrap : this.bundleWrapperList) {
                        if (wrap.selectedBundle) {
                            currentLineItem = wrap.lineItem;
                            currentLineItemJSON = JSON.serialize(currentLineItem);
                            this.currentLineItemId = wrap.lineItem.Id;
                            selectedLineItemsList.add(wrap.lineItem);
                            break;
                        }
                    }
                }
            }
            catch (Exception ex) {
                system.debug('Error Is #####################:-' + ex.getStackTraceString());
                ExceptionHandler.errorLogAsync(ex.getMessage(), ex.getStackTraceString(), 'EditStartEndDateController', 'getSelectedLineItemsList', this.currentRecordId);
            }

            return selectedLineItemsList;
        }
        set;
    }

    //Get available start dates for selected destination/course/program
    public void getSelectedLineItemStartdate() {
        list<Apttus_Config2__LineItem__c> lineItemToUpdateList = new list<Apttus_Config2__LineItem__c>();

        if (!getSelectedLineItemsList.isEmpty()) {
            for (Apttus_Config2__LineItem__c lineItem : getSelectedLineItemsList) {
                System.debug('######## DEstination code selected is:'+lineItem.DestinationCode__c +'@@@@@@@@@@@@@'+lineItem.Product_Code__c+'$$$$$$$$$$$$$$'+lineItem.Program__c);
                GetAvailableStartDates(lineItem.Product_Code__c, lineItem.DestinationCode__c, lineItem.Beginner__c, lineItem.Program__c);
                break;
            }
        }
    }

    @RemoteAction
    public static boolean RepriceCart(Id CartId) {
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        System.debug('CartId'+CartId);
        // add request parameters
        objUpdatePriceRequestDO.CartId = CartId;

        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);

        boolean hasPendingItems = result.IsPricePending;
        List<Integer> pendingLineNumbers = result.PendingLineNumbers;
        List<Integer> completedLineNumbers = result.CompletedLineNumbers;
        System.debug('hasPendingItems'+hasPendingItems);
        System.debug('pendingLineNumbers'+pendingLineNumbers);
        System.debug('completedLineNumbers'+completedLineNumbers);
        return hasPendingItems;
    }
    
    //Not used
    //cancel : return to cart page
    /*  public PageReference doRedirect() {
        if (configId2 != null) {
            pr = new PageReference(Site.getPathPrefix() + '/apex/Apttus_Config2__Cart?id=' + configId2 + '&configRequestId=' + configRequestId);
            //system.debug('==configId2==' + configId2 + '==flowName==' + flowName);
            pr.setRedirect(false);
            system.debug('==pr==' + pr);
            return pr;
        }

        return pr;
    }*/

    //If there is a change in quantity then we calculate the start date and end date in this method
    //we have to check  unit of measurement before we calculate the start date and end date
    @RemoteAction
    global static void calculateEndDate(String configLineItemListJSON, String currentItemId, String updatedQty) {
        Id currentId = Id.valueOf(currentItemId);
        Integer newQty = Integer.valueOf(updatedQty);
        if (newQty <= 0) {
            return;
        }
        String currentLineItemGroup = '';
        configLineItemList = (List<Apttus_Config2__LineItem__c>) JSON.deserialize(configLineItemListJSON, List<Apttus_Config2__LineItem__c>.Class);
        list<Apttus_Config2__LineItem__c> selectedLineItemsList = new list<Apttus_Config2__LineItem__c>();
        Date courseStartDate;
        Date courseEndDate;
        for (Apttus_Config2__LineItem__c lineItem : configLineItemList) {
            //here we get current line items destination
            currentLineItemGroup = lineItem.Apttus_Config2__ProductId__r.Name;
            if (lineItem.Id == currentId && lineItem.Apttus_Config2__StartDate__c != null) {
                List<StartDateSettings__mdt> startdateSettingsList = StartDatesSelector.getStartDateSettings(lineItem.DestinationCode__c);
                Integer SumOffset=0;
                System.debug('!!!!!!!!!!!!!!!!!!!!!! offset has value'+startdateSettingsList.size());
                if (startdateSettingsList.size()>0) {
                 Integer startdateoffset=(startdateSettingsList[0].StartDateOffSet__c < 0)?Integer.valueOf (startdateSettingsList[0].StartDateOffSet__c*-1):Integer.valueOf(startdateSettingsList[0].StartDateOffSet__c);
                    Integer enddateoffset=(startdateSettingsList[0].EndDateOffSet__c < 0)?Integer.valueOf(startdateSettingsList[0].EndDateOffSet__c*-1):Integer.valueOf(startdateSettingsList[0].EndDateOffSet__c);
                     SumOffset=startdateoffset+enddateoffset;
                }
                System.debug('!!!!!!!!!!!!!!!!!!!!!! SumOffset Off set sum is'+SumOffset);
                lineItem.Apttus_Config2__Quantity__c = newQty;
                System.debug('!!!!!!!!!!!!!!!!!!!!!! UOM is'+lineItem.Apttus_Config2__Uom__c);
                if (lineItem.Apttus_Config2__Uom__c != System.Label.LineItemUOMEach) {
                    // Hour Day Month Year
                    System.debug('!!!!!!!!!!!!!!!!!!!!!! startdateSettingsList is'+startdateSettingsList.size());
                    System.debug('!!!!!!!!!!!!!!!!!!!!!! Start Date is'+lineItem.Apttus_Config2__StartDate__c);
                    if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMWeek && startdateSettingsList.size() > 0) {
                        if (Integer.valueOf(lineItem.Apttus_Config2__Quantity__c) == 1) {
                            lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addDays(SumOffset + COURSEOFFSET);
                        }
                        else {
                            lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addDays(Integer.valueOf((SumOffset + COURSEOFFSET) + (7 * (Integer.valueOf(newQty) - 1))));
                        }
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMHour) {
                        if (Integer.valueOf(lineItem.Apttus_Config2__Quantity__c) < 24) {
                            lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c;
                        }
                        else {
                            Integer days = (Integer.valueOf(lineItem.Apttus_Config2__Quantity__c) / 24);
                            lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addDays(days);
                        }
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMMonth) {
                        lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addMonths(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMDay ) {
                        lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addDays(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMYear ) {
                        lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__StartDate__c.addYears(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                }
                selectedLineItemsList.add(lineItem);
                break;
            }
            else  if (lineItem.Id == currentId && lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMEach ){
                lineItem.Apttus_Config2__Quantity__c = newQty;
                selectedLineItemsList.add(lineItem);
                break;
            }
        }
        SObjectUnitOfWork.executeUpdateLineItemValues(selectedLineItemsList);
    }

    @RemoteAction
    global static String calculateEndDateForStartDate(String configLineItemListJSON, String currentItemId, String updatedStartDate) {
        Id currentId = Id.valueOf(currentItemId);
        Date newStartDate = Date.valueOf(updatedStartDate);
        String currentLineItemGroup = '';
        String validationError = '';
        configLineItemList = (List<Apttus_Config2__LineItem__c>) JSON.deserialize(configLineItemListJSON, List<Apttus_Config2__LineItem__c>.Class);
        list<Apttus_Config2__LineItem__c> selectedLineItemsList = new list<Apttus_Config2__LineItem__c>();
        Date courseStartDate;
        Date courseEndDate;
        System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +newStartDate);
        for (Apttus_Config2__LineItem__c lineItem : configLineItemList) {
            //here we get current line items destination
            currentLineItemGroup = lineItem.Apttus_Config2__ProductId__r.Name;
            System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +lineItem.Apttus_Config2__ProductId__r.Name);
            System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +currentId +'#########################'+lineItem.Id);
            if (lineItem.Id == currentId) {
                System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +currentId +'#########################'+lineItem.DestinationCode__c);
                List<StartDateSettings__mdt> startdateSettingsList = StartDatesSelector.getStartdateSettings(lineItem.DestinationCode__c);
                System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +currentId +'#########################'+startdateSettingsList.size());
                for (Apttus_Config2__LineItem__c lineItemrecord : configLineItemList) {
                    if (lineItemrecord.Apttus_Config2__ProductId__r.Name == currentLineItemGroup
                            && lineItemrecord.APTS_Product_Type__c == System.Label.ProductTypeCourse ) {
                        courseStartDate = lineItemrecord.Apttus_Config2__StartDate__c;
                        break;
                    }
                }
                //lineItem.Apttus_Config2__Quantity__c = newQty;
                System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&' +lineItem.Apttus_Config2__Uom__c);
                if (lineItem.Apttus_Config2__Uom__c != System.Label.LineItemUOMEach ) {
                    // Hour Day Month Year
                    if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMWeek && startdateSettingsList.size() > 0) {
                        Integer diff= lineItem.Apttus_Config2__StartDate__c.daysBetween(newStartDate);
                        lineItem.Apttus_Config2__StartDate__c=newStartDate;
                        lineItem.Apttus_Config2__EndDate__c = lineItem.Apttus_Config2__EndDate__c.addDays(diff);

                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMHour ) {
                        if (Integer.valueOf(lineItem.Apttus_Config2__Quantity__c) < 24) {
                            lineItem.Apttus_Config2__EndDate__c = newStartDate;
                        }
                        else {
                            Integer days = (Integer.valueOf(lineItem.Apttus_Config2__Quantity__c) / 24);
                            lineItem.Apttus_Config2__EndDate__c = newStartDate.addDays(days);
                        }
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMMonth ) {
                        lineItem.Apttus_Config2__EndDate__c = newStartDate.addMonths(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMDay ) {
                        lineItem.Apttus_Config2__EndDate__c = newStartDate.addDays(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                    else if (lineItem.Apttus_Config2__Uom__c == System.Label.LineItemUOMYear ) {
                        lineItem.Apttus_Config2__EndDate__c = newStartDate.addYears(Integer.valueOf(lineItem.Apttus_Config2__Quantity__c));
                    }
                }
                selectedLineItemsList.add(lineItem);
                //validationError=isValidDayForAccommodation(startdateSettingsList[0].ValidAccommodationDays__c,lineItem.Apttus_Config2__StartDate__c,lineItem.Apttus_Config2__EndDate__c);
                break;
            }
            else {
                System.debug('value is Null');
            }
        }
        if (String.isBlank(validationError)) {
            SObjectUnitOfWork.executeUpdateLineItemValues(selectedLineItemsList);
            return '';
        }
        else {
            return validationError;
        }
    }

    @RemoteAction
    global static String UpdateEndDateForAccommodation(String configLineItemListJSON, String currentItemId, String updatedEndDate) {
        Id currentId = Id.valueOf(currentItemId);
        Date newEndDate = Date.valueOf(updatedEndDate);
        configLineItemList = (List<Apttus_Config2__LineItem__c>) JSON.deserialize(configLineItemListJSON, List<Apttus_Config2__LineItem__c>.Class);
        list<Apttus_Config2__LineItem__c> selectedLineItemsList = new list<Apttus_Config2__LineItem__c>();
        for (Apttus_Config2__LineItem__c lineItem : configLineItemList) {
            //here we get current line items destination
            if (lineItem.Id == currentId
                    && lineItem.Apttus_Config2__StartDate__c != null
                    && lineItem.APTS_Product_Type__c == System.Label.ProductTypeAccommodation ) {
                lineItem.Apttus_Config2__EndDate__c = newEndDate;
                selectedLineItemsList.add(lineItem);
                //validationError=isValidDayForAccommodation(startdateSettingsList[0].ValidAccommodationDays__c,lineItem.Apttus_Config2__StartDate__c,lineItem.Apttus_Config2__EndDate__c);
                break;
            }
            else {
                System.debug('value is Null');
            }
        }

        if (selectedLineItemsList.size()>0) {
            SObjectUnitOfWork.executeUpdateLineItemValues(selectedLineItemsList);
            return '';
        }
        else {
            return '';
        }
    }

    //Not in use
    /*public static PageReference doRerefresh() {
        if (configId2 != null) {
            pr = new PageReference(Site.getPathPrefix() + '/apex/EditStartEndDate?id=' + configId2);
            pr.setRedirect(false);
            system.debug('==pr==' + pr);
            return pr;
        }
        return pr;
    }*/

    //Once the course start date is selected we update the start date and end date of some articles through this method
    @RemoteAction
    global static string updateStartDate(String startdate, String endDate, String quantity,
                                         String currentLineItemString, String configLineItemListJSON, String configId, String configReqId) {
        System.debug('startdate '+startdate);
        System.debug('endDate '+endDate);
        System.debug('quantity '+quantity);
        configLineItemList = (List<Apttus_Config2__LineItem__c>) JSON.deserialize(configLineItemListJSON, List<Apttus_Config2__LineItem__c>.Class);
        System.debug('Total Line Items '+configLineItemList.size());
        map<Decimal, list<Apttus_Config2__LineItem__c>> bundleWiseLineItemMap = new map<Decimal, list<Apttus_Config2__LineItem__c>>();
        Apttus_Config2__LineItem__c overLappingLineItem;
        if(!configLineItemList.isEmpty()){
            for(Apttus_Config2__LineItem__c lineItem : configLineItemList){
                System.debug('Product Code is '+lineItem.Product_Code__c);
                if(bundleWiseLineItemMap.containsKey(lineItem.Apttus_Config2__LineNumber__c)){
                    bundleWiseLineItemMap.get(lineItem.Apttus_Config2__LineNumber__c).add(lineItem);
                }
                else{
                    bundleWiseLineItemMap.put(lineItem.Apttus_Config2__LineNumber__c, new list<Apttus_Config2__LineItem__c>{lineItem});
                }
            }
        }
        
        currentLineItem = (Apttus_Config2__LineItem__c) JSON.deserialize(currentLineItemString, Apttus_Config2__LineItem__c.Class);
        System.debug('Current Id '+currentLineItem.ID);
        configId2 = configId;
        configRequestId = configReqId;
        String[] urltoNavigate = Utility.splitString(configReqId, '?') ;
        Set<Id> deletedLineItemIdSet = new Set<Id>();
        
        if (currentLineItem != null) {            
            list<Apttus_Config2__LineItem__c> selectedLineItemsList = new list<Apttus_Config2__LineItem__c>();
            for (Apttus_Config2__LineItem__c lineItem : configLineItemList) {
                if (lineItem.Id == currentLineItem.Id) {
                    lineItem.Apttus_Config2__EndDate__c = Date.valueOf(endDate);
                    lineItem.Apttus_Config2__StartDate__c = Date.valueOf(startdate);
                    lineItem.Apttus_Config2__Quantity__c = Integer.valueOf(quantity);
                    selectedLineItemsList.add(lineItem);
                    deletedLineItemIdSet = SeasonSupplementsHelper.createOptionLineItem(configId2, lineItem, bundleWiseLineItemMap);
                }
                System.debug('==deletedLineItemIdSet=='+deletedLineItemIdSet);
                if (lineItem.DestinationCode__c == currentLineItem.DestinationCode__c  && lineItem.Id != currentLineItem.Id && lineItem.Apttus_Config2__LineNumber__c == currentLineItem.Apttus_Config2__LineNumber__c) {
                    //selectedLineItemsList.add(lineItem);
                    if(deletedLineItemIdSet == null || deletedLineItemIdSet.isEmpty()){
                        selectedLineItemsList.add(lineItem);
                    }
                    else if(!deletedLineItemIdSet.isEmpty() && !deletedLineItemIdSet.contains(lineItem.Id)){
                        selectedLineItemsList.add(lineItem);
                    }
                }
                else {
                    System.debug('Excluded Id '+lineItem.ID);
                    System.debug('Excluded Product Code is '+lineItem.Product_Code__c);
                    System.debug('Excluded Destination :'+lineItem.DestinationCode__c);
                }
            }
            System.debug('Before Updating List SIZE is'+selectedLineItemsList.size());
            StartDateHelper.updateStartDateAndEndDateOfRelatedArticles(selectedLineItemsList,
                    currentLineItem.DestinationCode__c,
                    Date.valueOf(startdate),
                    Date.valueOf(endDate), Integer.valueOf(quantity));
        }
        else {
            System.debug('currentLineItem is: null');
        }
        return '';
    }

    /*public static String constructOverlappingError() {
        return 'Over Lap found';
    }*/

    /*public static Apttus_Config2__LineItem__c returnOverLappingLineItem(Apttus_Config2__LineItem__c loopItem,Date startDate,Date endDate) {
        if(((startDate >= loopItem.Apttus_Config2__StartDate__c && startDate <= loopItem.Apttus_Config2__EndDate__c) ||
                (endDate >= loopItem.Apttus_Config2__StartDate__c && endDate <= loopItem.Apttus_Config2__EndDate__c)))  {

            return loopItem;
        }
        else {
            return null;
        }
    }*/

    /*Public static String isValidDayForAccommodation(String validAccommodationDays,Date startDate,Date endDate) {
        Datetime dt = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
        String startDatedayOfWeek=dt.format('EEEE');
        Datetime dt1 = datetime.newInstance(endDate.year(), endDate.month(),endDate.day());
        String endDatedayOfWeek=dt.format('EEEE');
        if(validAccommodationDays.contains(startDatedayOfWeek) )
        {
            if (!validAccommodationDays.contains(endDatedayOfWeek)) {
                return 'Accommodation end Date Cannot Be on :'+endDatedayOfWeek;
            }
        }
        else
        {
            return 'Accommodation start Date Cannot Be on :'+startDatedayOfWeek;
        }
       return '';
    }*/

    /* Public Static String courseWithoutAccommodationCheck(Date courseStartDate,Date courseEndDate,Date accommodationStartDate,Date accommodationEndDate) {
        if (courseStartDate>=accommodationStartDate) {
            if (courseEndDate>accommodationEndDate) {
                return 'Course End Date is greater than Accommodation';
            }
        }
        else {
            return 'Course start date is lessar than accommodation start date';
        }
        return '';
    }*/

    //This class is added to manipulate the values of bundles in EDit start date and end date page
    public class BundleWrapper {
        public boolean selectedBundle { get; set; }
        public Apttus_Config2__LineItem__c lineItem { get; set; }

        public BundleWrapper(boolean selectBundle, Apttus_Config2__LineItem__c lineItem) {
            this.selectedBundle = selectBundle;
            this.lineItem = lineItem;
        }
    }
}