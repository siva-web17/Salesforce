/**
 * Created by Arkadiusz Celej on 03.04.2018.
 */

@IsTest
global class CalloutHandlerMocks {
    global class SuccessCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(new CalloutHandler.CalloutResult(true, 'Success')));
            res.setStatusCode(200);
            return res;
        }
    }

    global class FailureCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(new CalloutHandler.CalloutResult(false, 'Failure')));
            res.setStatusCode(200);
            return res;
        }
    }

    global class InvalidCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(new CalloutHandler.CalloutResult(false, 'Failure')));
            res.setStatusCode(500);
            return res;
        }
    }
}