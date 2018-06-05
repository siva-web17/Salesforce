/**
 * Created by britenet-patrykzak on 13/03/2018.
 */

global class ExternalRouterMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}