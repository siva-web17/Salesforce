/**************************************************************************************
Apex Class Name    : BookingsSelector
Version            : 1.0
Created Date       : May 23 2018
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arjun.Mohan                 23/05/2018              Original Version
*******************************************************************************/
public class BookingsSelector {

    public static Map<Id,List<Booking__c>> getBookingForAccountIds(Set<Id> AccountId)
    {
        Map<Id,List<Booking__c>> accountWithBookingMap = new Map<Id,List<Booking__c>>();
       List<Booking__c> bookingList=[SELECT Id, Name, CurrencyIsoCode, AccountId__c, BookingDate__c, Product__c, Program__c, SalesOffice__c, PosBookingNumber__c, Status__c, MainSalesResponsible__c FROM Booking__c where Status__c != 'CAX' and AccountId__c IN :AccountId];
        for(Booking__c bookingRec:bookingList)
        {
            if(!accountWithBookingMap.containsKey(bookingRec.AccountId__c))
            {
                accountWithBookingMap.put(bookingRec.AccountId__c, new List<Booking__c>());
            }
            List<Booking__c> temp=accountWithBookingMap.get(bookingRec.AccountId__c);
            temp.add(bookingRec);
            accountWithBookingMap.put(bookingRec.AccountId__c, temp);
        }
        return accountWithBookingMap;
    }
}