/**
 * Created by Arkadiusz Celej on 03.04.2018.
 */

@IsTest
global class CalloutHandlerMocks {
    global class SuccessCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(new ExternalRouter.CalloutResult(true, 'Success')));
            res.setStatusCode(200);
            return res;
        }
    }

    global class FailureCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(new ExternalRouter.CalloutResult(false, 'Failure')));
            res.setStatusCode(200);
            return res;
        }
    }

    global class InvalidCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            return res;
        }
    }

    global class CallForRankingMock implements HttpCalloutMock{

        private List<Lead> leads = new List<Lead>();

        global CallForRankingMock(List<Lead> leadList){
            this.leads = leadList;
        }

        global HTTPResponse respond(HTTPRequest req) {
            System.debug('HTTP RESPONSE RESPOND !!!!!');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(rankingServiceResponseList()));
            res.setStatusCode(200);
            return res;
        }


        private List<RankingServiceResponse> rankingServiceResponseList(){

            List<RankingServiceResponse> rankingServiceResponses = new List<RankingServiceResponse>();

            for(Lead lead : leads){
                RankingServiceResponse rsr = new RankingServiceResponse();
                rsr.LeadID = lead.Id;
                rsr.Rank = 5;
                rsr.IsRanked = TRUE;
                rankingServiceResponses.add(rsr);
            }
            return rankingServiceResponses;
        }
    }

}