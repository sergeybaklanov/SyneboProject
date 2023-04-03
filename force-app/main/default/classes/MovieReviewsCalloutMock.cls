@IsTest
global with sharing class MovieReviewsCalloutMock implements  HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        WrapperResponse myResponse1 = new WrapperResponse();
        myResponse1.postId = 5;
        myResponse1.id =  21;
        myResponse1.name = 'Response example Name 21';
        myResponse1.body = 'Response example Body 21';
        myResponse1.email = 'test21@example.com';

        WrapperResponse myResponse2 = new WrapperResponse();
        myResponse2.postId = 5;
        myResponse2.id =  22;
        myResponse2.name = 'Response example Name 22';
        myResponse2.body = 'Response example Body 22';
        myResponse2.email = 'test22@example.com';

        List<WrapperResponse> responseList = new List<WrapperResponse>{myResponse1,myResponse2};

        String responseBody = JSON.serialize(responseList);

        response.setHeader('Content-Type','application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        System.debug('ResponseBody: ' + responseBody);
        
        return response;
    }

    class WrapperResponse {
        Integer postId;
        Integer id;
        String name;
        String email;
        String body;
    }
}