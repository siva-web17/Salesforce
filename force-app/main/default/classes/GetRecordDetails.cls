public with sharing class GetRecordDetails {

    @AuraEnabled
    Public static string GetRecordOwnerDetails(String Id)
    {
        /*Opportunity ObjOpportunityDetails=[SELECT OwnerId, Id, Owner.name FROM Opportunity where id=:Id];
        return JSON.serialize(ObjOpportunityDetails);*/
        
        Apttus_Proposal__Proposal__c ObjQuoteDetails=[SELECT Id,SalesMadeby__c, SalesMadeby__r.name FROM Apttus_Proposal__Proposal__c where id=:Id];
        system.debug('Quote is :'+ObjQuoteDetails);
        return JSON.serialize(ObjQuoteDetails);
    }

    @AuraEnabled
    Public static string ChangeOwner(Id UserId,Id RecordId,string ObjectName)
    {
         string updatestatus='';
        System.debug('params  '+UserId+' record is '+RecordId + ' ObjectName '+ObjectName);
        try {
            system.debug('UserId is :'+UserId);
            String sQuery =  'select id, Name,SalesMadeby__c, SalesMadeby__r.name  from '+ObjectName+'  where id =:RecordId';
            if(ObjectName=='Lead')
            {
                Lead leadRecord = Database.query(sQuery);
                system.debug('before update ownerId is :'+leadRecord.OwnerId);
                leadRecord.OwnerId=UserId;
                update leadRecord;
            }
            
            else if(ObjectName=='Apttus_Proposal__Proposal__c')
            {
                 sQuery =  'select id, Name,SalesMadeby__c,SalesMadeby__r.name  from '+ObjectName+'  where id =:RecordId';
                Apttus_Proposal__Proposal__c quoteRecord = Database.query(sQuery);
                system.debug('before update ownerId is :'+quoteRecord.SalesMadeby__c);
                quoteRecord.SalesMadeby__c=UserId;
                update quoteRecord;
            }
            
            /*else if(ObjectName=='Opportunity')
            {
                opportunity oppRecord = Database.query(sQuery);
                system.debug('before update ownerId is :'+oppRecord.OwnerId);
                oppRecord.OwnerId=UserId;
                update oppRecord;
            }*/

            return updatestatus='' ;

        }
        catch(exception ex)
        {
            system.debug('Error cannot update owner Id for :'+RecordId);
            updatestatus=ex.getMessage();
            return updatestatus;
        }


    }

}