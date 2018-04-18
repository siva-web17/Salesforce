//This batch is generic, its code can be changed for executing one off data update jobs 
global class LanguageGenericBatch implements Database.Batchable<SObject>{
    
    //properties
    global String strQuery;   
           
    //constructor
    global LanguageGenericBatch(){    
        this.strQuery = 'select id,requesttype__c,IsCAMOnly__c from lead where RequestType__c = \'CAM\' and isconverted=false'; 
    }
  
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){    
        return Database.getQueryLocator(this.strQuery); 
    }
  
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> scope){ 
        /*try{   
            list<Lead> lstResource = new list<Lead >() ;
            lstResource = (List<Lead>)scope;
            for(Lead lrec:lstResource)
            {
                lrec.IsCAMOnly__c=true;
            }
            update lstResource; 
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                   'LanguageGenericBatch', 'execute', null);
        }*/ 
    }
   
    //finish method
    global void finish(Database.BatchableContext context){    
    }
}