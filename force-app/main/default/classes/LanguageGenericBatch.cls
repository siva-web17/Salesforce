//This batch is generic, its code can be changed for executing one off data update jobs 
global class LanguageGenericBatch implements Database.Batchable<SObject>{      

    //properties
    global String strQuery;   
           
    //constructor
    global LanguageGenericBatch(){    
        this.strQuery = 'select Id,NumberOfCalls__c,(Select Id,SalesAction__c,TaskSubType,IsClosed,RecordTypeId from Tasks order by CreatedDate desc) from Opportunity'; 
    }    
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){        
         return Database.getQueryLocator(this.strQuery); 
    }    
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> scope){ 
        try{   
            list<Opportunity> lstResource = new list<Opportunity>() ;
            List<opportunity> finalopplist = new List<Opportunity>();
               lstResource = (List<Opportunity>)scope;
            for(Opportunity opp : lstResource){  
               integer previousNumberOfCompletedCalls = integer.valueof(opp.NumberOfCalls__c);
               Taskshelper.updateNumberOfCompletedCalls(opp ,opp.Tasks);
               if(opp.NumberOfCalls__c!=previousNumberOfCompletedCalls){
                finalopplist.add(opp);            
               }               
            }
            update finalopplist;
        }
        catch(Exception ex){
            //Logger.logException(ex);
             ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'LanguageGenericBatch', 'execute', '');
        }
    }    
    //finish method
    global void finish(Database.BatchableContext context){    
    }
}