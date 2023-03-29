@IsTest
global class EmailValidationMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-type', 'application/json');
        response.setStatusCode(200);
        response.setBody('{"is_disposable_email": {"value": true}, "is_free_email": {"value": false}}');
        return response;
    }
}