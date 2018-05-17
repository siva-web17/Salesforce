//This batch is generic, its code can be changed for executing one off data update jobs 
global class LanguageGenericBatch implements Database.Batchable<SObject>{        

    //properties
    global String strQuery;   
    
    //constructor
    global LangGenericBatch(){
    	this.strQuery = 'Select Id, NumberOfCalls__c from Opportunity order by AccountId';    	    
    }    
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){        
         return Database.getQueryLocator(this.strQuery); 
    }
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> scope){ 
    	/**
    	1. Loop on opportunities
    	2. Create a map, key - opportunity id, value - opportunity record
    	3. Query out tasks based on opportunity Ids
    	4. Loop on tasks
    	5. Create a map, key - opportunity record, value - list of tasks
    	6. Loop on this map
    	7. Call method for calculating number of calls
    	8. Update opportunity records where number of calls is changed
    	**/
    	
    	List<Opportunity> lstOpps = new List<Opportunity>();
    	List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
    	List<Task> lstTasks = new List<Task>();
    	
    	Map<Id, Opportunity> mapOppIdRecord = new Map<Id, Opportunity>();
    	Map<Id, List<Task>> mapOppIdTasks = new Map<Id, List<Task>>();
    	
    	try{
    		lstOpps = (List<Opportunity>)scope;
    		
    		//1. Loop on opportunities
    		for(Opportunity opp : lstOpps){
    			//2. Create a map, key - opportunity id, value - opportunity record
    			mapOppIdRecord.put(opp.Id, opp);
    		}
	    	
	    	//3. Query out tasks based on opportunity Ids
	    	lstTasks = [Select Id, WhatId, SalesAction__c, TaskSubType, IsClosed, RecordTypeId from Task where WhatId in :mapOppIdRecord.keySet()];
	    	
	    	//4. Loop on tasks
	    	for(Task taskRecord : lstTasks){
	    		//5. Create a map, key - opportunity Id, value - list of tasks
	    		if(!mapOppIdTasks.containsKey(taskRecord.WhatId)){
	    			mapOppIdTasks.put(taskRecord.WhatId, new List<Task>()); 
	    		}
	    		mapOppIdTasks.get(taskRecord.WhatId).add(taskRecord);
	    	}	    	
	    	
	    	//6. Loop on this map
	    	for(Id oppId : mapOppIdTasks.keySet()){	    		
	    		if(!mapOppIdRecord.containsKey(oppId)){
	    			continue;
	    		}
	    		
	    		Opportunity oppRecord = mapOppIdRecord.get(oppId);
	    		Decimal dcmOldNumberOfCalls = oppRecord.NumberOfCalls__c;
	    		
	    		//7. Call method for calculating number of calls	    		 		
	    		TasksHelper.updateNumberOfCompletedCalls(oppRecord, mapOppIdTasks.get(oppId));
	    		
	    		if(oppRecord.NumberOfCalls__c != dcmOldNumberOfCalls){
	    			lstOppsToUpdate.add(oppRecord);            
               } 
	    	}	    	
	    	
	    	//8. Update opportuity records where number of calls is changed
	    	if(lstOppsToUpdate.size() > 0){
	    		update lstOppsToUpdate;
	    	}	    	
    	}
    	catch(Exception ex){
    		//Logger.logException(ex);
             ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'LanguageGenericBatch', 'execute', null);
    	}
    }  
    //finish method
    global void finish(Database.BatchableContext context){    
    }
}