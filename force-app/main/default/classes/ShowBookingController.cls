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
            this.ServiceURL = ExternalRouter.getServiceURL('OpenBooking');
        }
        else
        {
            BookingNumber=null;
        }
    }
}