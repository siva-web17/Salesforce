public class ShowBookingController { 
    public String displayMessage{get;set;}
    public String BookingNumber{get;set;}
    public Booking__c BookingObject{get;set;}
    public String ServiceURL{get;set;}

    public ShowBookingController(ApexPages.StandardController controller) {
    this.displayMessage=system.label.ShowBookingDisplayMessage;
        if (controller.getRecord().getSObjectType()==Booking__c.getSObjectType()) {
            this.BookingObject = (Booking__c)controller.getRecord();
            BookingObject =  [SELECT ID,Name FROM Booking__c WHERE ID = :BookingObject.Id];
            BookingNumber=this.BookingObject.Name;
            ExternalServiceSettings__mdt serviceSettingRecord = ExternalRouter.getServiceURL('OpenBooking');
            if(serviceSettingRecord!=null && !String.IsEmpty(serviceSettingRecord.EndPoint__c))
            {
                this.ServiceURL = serviceSettingRecord.EndPoint__c;
            }
        }
        else
        {
            BookingNumber=null;
        }
    }
}