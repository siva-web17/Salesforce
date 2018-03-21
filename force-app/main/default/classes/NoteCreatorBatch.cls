//This batch creates ContentNote record based on NoteMigration records  
global class NoteCreatorBatch implements Database.Batchable<SObject>{
    
    //properties
    global String strQuery;   
           
    //constructor
    global NoteCreatorBatch(){
        this.strQuery  = ' Select Id, EventId__c, LeadId__c, Title__c, NoteContent__c from NoteMigration__c ' ;
        this.strQuery += ' where EventId__c != null and LeadId__c != null and Title__c != null and IsProcessed__c = false ';
        this.strQuery += ' order by CreatedDate ';  
        
        if(Test.isRunningTest()){
          this.strQuery += ' Limit 1';
        } 
    }
  
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(strQuery); 
    }
  
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> scope){ 
        /**
        1. Loop on note migration records
        2. Create a map, key - note migration record Id, value - content note record
        3. Insert map values
        4. Loop on note migration record
        5. Create content document link records for lead and event and add them to list
        6. Update note migration records
        7. Insert content document link records
        8. Update note migration records
        **/
        
        List<NoteMigration__c> lstNoteMigrations = new List<NoteMigration__c>();                
        List<ContentDocumentLink> lstContentDocumentLinksToInsert = new List<ContentDocumentLink>();
        
        Map<Id, ContentNote> mapNoteMigrationContentNote = new Map<Id, ContentNote>();
        
        try{            
            lstNoteMigrations = (List<NoteMigration__c>)scope;
            System.debug('*** List size: ' + lstNoteMigrations.size());
            
            //1. Loop on note migration records
            for(NoteMigration__c objNoteMigration : lstNoteMigrations){
                //2. Create a map, key - note migration record Id, value - content note record
                ContentNote noteRecord = new ContentNote();
                noteRecord.Title = objNoteMigration.Title__c;
                noteRecord.Content = Blob.valueOf(EventsHelper.getTheParsedJson(objNoteMigration.NoteContent__c));
                
                mapNoteMigrationContentNote.put(objNoteMigration.Id, noteRecord);                
            }                        
            
            //3. Insert map values
            if(mapNoteMigrationContentNote.size() > 0 && mapNoteMigrationContentNote.values().size() > 0){
                insert mapNoteMigrationContentNote.values();
            }            
            
            //4. Loop on note migration record
            for(NoteMigration__c objNoteMigration : lstNoteMigrations){
                //5. Create content document link records for lead and event and add them to list
                ContentDocumentLink linkRecordEvent = new ContentDocumentLink();
                linkRecordEvent.LinkedEntityId = objNoteMigration.EventId__c;
                linkRecordEvent.ContentDocumentId = mapNoteMigrationContentNote.get(objNoteMigration.Id).Id;                
                linkRecordEvent.ShareType = 'V';
                linkRecordEvent.Visibility = 'AllUsers';
                lstContentDocumentLinksToInsert.add(linkRecordEvent);
                
                ContentDocumentLink linkRecordLead = new ContentDocumentLink();
                linkRecordLead.LinkedEntityId = objNoteMigration.LeadId__c;
                linkRecordLead.ContentDocumentId = mapNoteMigrationContentNote.get(objNoteMigration.Id).Id;                
                linkRecordLead.ShareType = 'V';
                linkRecordLead.Visibility = 'AllUsers';
                
                lstContentDocumentLinksToInsert.add(linkRecordLead);
                
                //6. Update note migration records
                objNoteMigration.IsProcessed__c = true;
                objNoteMigration.LastProcessedDate__c = DateTime.now();
                objNoteMigration.ContentNoteId__c = mapNoteMigrationContentNote.get(objNoteMigration.Id).Id;
            }            
            
            //7. Insert content document link records
            if(lstContentDocumentLinksToInsert.size() > 0){
                insert lstContentDocumentLinksToInsert;
            } 
            
            //8. Update note migration records
            update lstNoteMigrations;                       
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(), 'NoteCreatorBatch', 'excecute', null);            
        }
    }
   
    //finish method
    global void finish(Database.BatchableContext context){    
    }
}