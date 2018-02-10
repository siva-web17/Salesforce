public class InvokeScribe {

    @future (callout=true)    
    public static void InvokeScribeAfterFinishBooking_Async(id QuoteID) {
        Id currentrecord;
        try{
        
        InvokeScribeAfterFinishBooking(QuoteID);
        system.debug('Inside invoke scribe method Async  :'+QuoteID);
        }
            catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'InvokeScribe', 'InvokeScribeAfterFinishBooking', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
        }
            
    }
    public static void InvokeScribeAfterFinishBooking(id QuoteID) {
        Id currentrecord;
        try{            
                        Apttus_Proposal__Proposal__c quotation = new Apttus_Proposal__Proposal__c();
           				system.debug('Inside invoke scribe method   :'+quotation);
                        quotation = [select id,Apttus_Proposal__Opportunity__c
                                     from Apttus_Proposal__Proposal__c where Id=:QuoteID LIMIT 1];
                        //Construct HTTP request and response
                        HttpRequest req = new HttpRequest();
                         //Http request method,Endpoint and setBody
                        req.setEndpoint('https://endpoint-frankfurt.scribesoft.com/v1/orgs/25738/requests/4855?accesstoken=b693644b-8d85-4568-a146-7851d8e47822');
                        req.setMethod('POST');
                        req.setHeader( 'Content-Type', 'application/json' );
                        req.setHeader( 'Accept', 'application/json' );
                    
                        String currentUsername = UserInfo.getUserName();
                        System.debug('currentUsername: ' + currentUsername);
                    
                        JSONGenerator gen = JSON.createGenerator(true);    
                        gen.writeStartObject();      
                        gen.writeStringField('OpportunityID', quotation.Apttus_Proposal__Opportunity__c);
                        gen.writeStringField('username', currentUsername);
                        gen.writeStringField('QuoteID', QuoteID);
                        gen.writeEndObject();    
                        String jsonS = gen.getAsString();
                        req.setBody(jsonS);
                
                        system.debug('Call Service: '+jsonS);
                     
                        HttpResponse res = new HttpResponse();
                        Http http = new Http(); 
                        //setting read time out as 20 seconds, 20*1000ms 
                        req.setTimeout(60000);
                        res = http.send(req);
                    
                        if(res != null){
                            System.debug('response:--> ' + res.getBody());       
                        }
                        else{
                            System.debug('Empty response'); 
                        }
        }
        catch(Exception ex){
            ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                    'InvokeScribe', 'InvokeScribeAfterFinishBooking', currentrecord);
            System.debug('Dml exception :'  +ex.getMessage());
    	}
    }
}