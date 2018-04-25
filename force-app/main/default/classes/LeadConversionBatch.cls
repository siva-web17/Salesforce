//This batch is for Lead Conversion
global class LeadConversionBatch implements Database.Batchable<SObject>{
    
    //properties
    global String strQuery;   
           
    //constructor
    global LeadConversionBatch(){    
        this.strQuery = 'SELECT Id,FirstName,LastName FROM Lead WHERE IsByConversion__c = False AND IsDupeProcessed__c = True AND IsCAMOnly__c = False AND Ranking__c != Null AND Market__c = \'NOO\' AND IsConverted = False AND IsDupe__c = False'; 
    	System.debug('this.strQuery' +this.strQuery);
    }
  
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){    
        return Database.getQueryLocator(this.strQuery); 
    }
  
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> Scope){ 
        try{   
			map<id,id> Contentnoteidmap = new map<id,id>();
            Set<Id> LeadID = new Set<Id>();
            List<Lead> LeadUpdate = new List<Lead>();
            for (Lead IdLead : (List<Lead>)Scope){
                LeadID.add(IdLead.Id);
			}
            System.debug('LeadID' +LeadID.size());
			list<ContentDocumentLink> listOfContentDocumentLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId in:LeadID];
			list<ContentDocumentLink> listOfContentDocumentLinkToUpdate = new List<ContentDocumentLink>();
			system.debug('Contentdocumentlink>>>>'+listOfContentDocumentLink.size());
			for(ContentDocumentLink objlistOfContentDocumentLink :listOfContentDocumentLink){
				Contentnoteidmap.put(objlistOfContentDocumentLink.LinkedEntityId,objlistOfContentDocumentLink.ContentDocumentId);
			}
			delete listOfContentDocumentLink;
			for(Lead objLead : (List<Lead>)Scope){
				objLead.iscamonly__c=false;
                LeadUpdate.add(objLead);
			}
			update LeadUpdate;
            system.debug('LeadUpdate'+LeadUpdate.size());
			map<id,lead> LeadMap = new map<id,lead>([select id,convertedaccountid,convertedopportunityid from lead where id in:LeadID and (convertedaccountid!=null OR convertedopportunityid!=null)]);
            if(LeadMap.size() < LeadUpdate.size())
            {
                system.debug('Failed to convert');
                SObjectException e=new SObjectException();
                e.setMessage('Convertion failed for lead');
                throw e;
            }
			//map<id,account> accountAndOppMap = new Map<id,Account>([select id,(select id from opportunity where isactive__c=true) from account ]);
			for(id objid:LeadMap.keyset()){
				system.debug('objid>>'+objid);
				system.debug('Contentnoteidmap>>'+Contentnoteidmap);   
                system.debug('after account'+LeadMap.get(objid).convertedaccountid);
				if(LeadMap.get(objid).convertedaccountid!=null){
				  ContentDocumentLink ContentDocumentLinkFirstUpdate = new ContentDocumentLink();
				system.debug('after get'+Contentnoteidmap.get(objid));
							ContentDocumentLinkFirstUpdate.ContentDocumentId = Contentnoteidmap.get(objid);
							ContentDocumentLinkFirstUpdate.LinkedEntityId = LeadMap.get(objid).convertedaccountid;
							ContentDocumentLinkFirstUpdate.ShareType = 'V';
							ContentDocumentLinkFirstUpdate.Visibility = 'AllUsers';
							listOfContentDocumentLinkToUpdate.add(ContentDocumentLinkFirstUpdate);
							ContentDocumentLink ContentDocumentLinkSecondUpdate = new ContentDocumentLink();
							ContentDocumentLinkSecondUpdate.ContentDocumentId = Contentnoteidmap.get(objid);
							ContentDocumentLinkSecondUpdate.LinkedEntityId = LeadMap.get(objid).convertedopportunityid;
							ContentDocumentLinkSecondUpdate.ShareType = 'V';
							ContentDocumentLinkSecondUpdate.Visibility = 'AllUsers';
							listOfContentDocumentLinkToUpdate.add(ContentDocumentLinkSecondUpdate);
                    system.debug('ContentDocumentLinkFirstUpdate'+ContentDocumentLinkFirstUpdate);
                    system.debug('ContentDocumentLinkSecondUpdate'+ContentDocumentLinkSecondUpdate);
			}
	}
				insert listOfContentDocumentLinkToUpdate; 
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                   'LeadConversionBatch', 'execute', null);
        } 
    }
   
    //finish method
    global void finish(Database.BatchableContext context){    
    }
}