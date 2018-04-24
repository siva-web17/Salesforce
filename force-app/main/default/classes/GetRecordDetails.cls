public with sharing class GetRecordDetails {

    @AuraEnabled
    Public static string GetRecordOwnerDetails(String Id)
    {
        /*Opportunity ObjOpportunityDetails=[SELECT OwnerId, Id, Owner.name FROM Opportunity where id=:Id];
        return JSON.serialize(ObjOpportunityDetails);*/
        return userinfo.getName();

    }

    @AuraEnabled
    Public static string ChangeOwner(Id UserId,Id RecordId,string ObjectName)
    {
         string updatestatus='';
        System.debug('params  '+UserId+' record is '+RecordId + ' ObjectName '+ObjectName);
        try {
            system.debug('UserId is :'+UserId);
            String sQuery =  'select id, Name,SalesMadeby__c, SalesMadeby__r.Name  from '+ObjectName+'  where id =:RecordId';

            if(ObjectName=='Lead')
            {
                Lead leadRecord = Database.query(sQuery);
                system.debug('before update ownerId is :'+leadRecord.OwnerId);
                leadRecord.OwnerId=UserId;
                update leadRecord;
            }
            
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