//This batch is for Lead Conversion
global class LeadConversionBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, System.Schedulable{
    
    public static final String SCHEDULED_JOB_NAME = 'Converting Lead having Content Note';
    
    //properties
    global String strQuery;   
           
    //constructor
    global LeadConversionBatch(){    
        this.strQuery = 'SELECT Id, FirstName, LastName ';
        this.strQuery = this.strQuery + ' FROM Lead';
        this.strQuery = this.strQuery + ' WHERE IsByConversion__c = False AND IsConverted = False AND Market__c = \'NOO\' AND IsCAMOnly__c = False AND Ranking__c != Null AND IsDupeProcessed__c = True AND IsDupe__c = False';
        this.strQuery = this.strQuery + ' order by CreatedDate Desc '; 
    	
    	System.debug('this.strQuery' +this.strQuery);
        
        if(Test.isRunningTest()){
          this.strQuery += ' Limit 1';
        }
    }
  
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){    
        return Database.getQueryLocator(this.strQuery); 
    }
  
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> Scope){
    	
    	/** 
    	1. Loop on leads that came in as scope and create a set of lead ids.
    	2. Query out content document link records associated to these leads.
    	3. Deleting content document link records of the lead.	
    	4. Updating Lead record.
    	5. Query out converted Lead.
    	6. Checking for Lead size to throw error.
    	7. Create content note for associated account of the Lead.
    	8. Create content note for associated opportunity of the Lead.
    	9. Inserting created notes to content document link
    	10. Scheduling Job for every 30min.
    	**/ 
    	     
        try{   
			Set<Id> leadIdSet = new Set<Id>();
			Map<Id, Id> contentNoteIdMap = new Map<Id, Id>(); 
            
            List<Lead> leadUpdateList = new List<Lead>();
            List<ContentDocumentLink> listOfContentDocumentLink = new List<ContentDocumentLink>(); 
            List<ContentDocumentLink> listOfContentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            //1. Loop on leads that came in as scope and create a set of lead ids.
            for (Lead leadRecord : (List<Lead>)Scope){
                leadIdSet.add(leadRecord.Id);
			}
            System.debug('leadIdSet.size' + leadIdSet.size());
			
			//2. Query out content document link records associated to these leads.			
			listOfContentDocumentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :leadIdSet];			
			
			system.debug('Contentdocumentlink>>>>'+listOfContentDocumentLink.size());
			
			for(ContentDocumentLink objlistOfContentDocumentLink : listOfContentDocumentLink){
				contentNoteIdMap.put(objlistOfContentDocumentLink.LinkedEntityId, objlistOfContentDocumentLink.ContentDocumentId);
			}
			
			//3. Deleting content document link records of the lead.
			if(listOfContentDocumentLink != null && listOfContentDocumentLink.size() > 0){
				delete listOfContentDocumentLink;
			}

			//4. Updating Lead record.
			update (List<Lead>)Scope; 
            system.debug('LeadUpdate'+ ((List<Lead>)Scope).size());
			
			//5. Query out converted Lead.
			Map<Id, Lead> leadMap = new Map<Id, Lead>([select Id, ConvertedAccountId, ConvertedOpportunityId 
													   from Lead 
													   where Id in :leadIdSet 
													   and (ConvertedAccountId != null OR ConvertedOpportunityId != null)]);
            
            //6. Checking for Lead size to throw error.
            if(leadMap.size() < ((List<Lead>)Scope).size()){
                system.debug('Failed to convert');
                SObjectException e = new SObjectException();
                e.setMessage('Convertion failed for lead'); 
                throw e;
            }
            
			for(Id leadId : leadMap.keyset()){
				system.debug('objid>>' + leadId);
				system.debug('Contentnoteidmap>>' + contentNoteIdMap);   
                system.debug('after account' + leadMap.get(leadId).ConvertedAccountId);
				
				if(leadMap.get(leadId).ConvertedAccountId != null){
					system.debug('after get' + Contentnoteidmap.get(leadId));
					
					//7. Create content note for associated account of the Lead.
					ContentDocumentLink contentDocumentLinkForAccount = new ContentDocumentLink();
					contentDocumentLinkForAccount.ContentDocumentId = contentNoteIdMap.get(leadId);
					contentDocumentLinkForAccount.LinkedEntityId = leadMap.get(leadId).ConvertedAccountId;
					contentDocumentLinkForAccount.ShareType = 'V';
					contentDocumentLinkForAccount.Visibility = 'AllUsers';
					listOfContentDocumentLinkToInsert.add(contentDocumentLinkForAccount);
					system.debug('ContentDocumentLinkFirstUpdate' + contentDocumentLinkForAccount);
					
					//8. Create content note for associated opportunity of the Lead.
					ContentDocumentLink contentDocumentLinkForOpportunity = new ContentDocumentLink();
					contentDocumentLinkForOpportunity.ContentDocumentId = contentNoteIdMap.get(leadId);
					contentDocumentLinkForOpportunity.LinkedEntityId = leadMap.get(leadId).ConvertedOpportunityId;
					contentDocumentLinkForOpportunity.ShareType = 'V';
					contentDocumentLinkForOpportunity.Visibility = 'AllUsers';
					listOfContentDocumentLinkToInsert.add(contentDocumentLinkForOpportunity);
                    system.debug('ContentDocumentLinkSecondUpdate' + contentDocumentLinkForOpportunity);
				}
			}
			
			//9. Inserting created notes to content document link
			if(listOfContentDocumentLinkToInsert != null && listOfContentDocumentLinkToInsert.size() > 0){
				insert listOfContentDocumentLinkToInsert;
			}			 
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'LeadConversionBatch', 'execute', null);
        } 
    }
   
    //finish method
    global void finish(Database.BatchableContext context){    
    }
    
    public void execute(SchedulableContext ctx){
        Database.executeBatch(new LeadConversionBatch());
    }
    
    public static void scheduleEvery30mins(){
        String appendix = Test.isRunningTest()? '_test' : '';
        //10. Scheduling Job for every 30min.
        LeadConversionBatch.schedule('0 0 * ? * *', SCHEDULED_JOB_NAME+' - 00 minute of hour'+appendix);
        LeadConversionBatch.schedule('0 30 * ? * *', SCHEDULED_JOB_NAME+' - 30 minute of hour'+appendix);
    }

    public static void schedule(String crone, String label){
        System.schedule(label, crone, new LeadConversionBatch());
    }
}