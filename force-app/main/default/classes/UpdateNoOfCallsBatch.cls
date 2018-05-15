 global class UpdateNoOfCallsBatch implements Database.Batchable<SObject>{       
    
    //start method
    global Database.QueryLocator start(Database.BatchableContext context){
        
        return Database.getQueryLocator([select id,NumberOfCalls__c,(Select id,salesaction__c,isclosed,recordtypeid from tasks order by createddate desc) from opportunity]); 
    }
    
    //execute method
    global void execute(Database.BatchableContext context, List<SObject> scope){ 
        try{   
            list<Opportunity> lstResource = new list<Opportunity>() ;
            List<opportunity> finalopplist = new List<Opportunity>();
               lstResource = (List<Opportunity>)scope;
            for(Opportunity opp : lstResource){  
                system.debug('Inside opplist');
                Integer numberOfCallsCompleted= 0;
                for(Task task : opp.Tasks){
                    system.debug('inside task'+task.SalesAction__c);
                    if (task.tasksubtype=='Call' && task.IsClosed) {                      
                            numberOfCallsCompleted++;                      
                    }
                }
                if(opp.NumberOfCalls__c != numberOfCallsCompleted){
                    opp.NumberOfCalls__c = numberOfCallsCompleted;
                    system.debug('updated number of call  tasks'+ opp.NumberOfCalls__c);
                    finalopplist.add(opp);
                }
            }
            update finalopplist;
        }
        catch(Exception ex){
            //Logger.logException(ex);
        }
    }    
    //finish method
    global void finish(Database.BatchableContext context){    
    }
  }