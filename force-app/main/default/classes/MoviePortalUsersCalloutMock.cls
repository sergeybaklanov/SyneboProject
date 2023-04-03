@isTest
global with sharing class MoviePortalUsersCalloutMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        WrapperResponse myResponse1 = new WrapperResponse();
        myResponse1.name = 'Antonio1';
        myResponse1.email = 'test21@example.com';
        myResponse1.phone = '666-666-666';
        myResponse1.website = 'antonio1.viewer.com';
       
        WrapperResponse myResponse2 = new WrapperResponse();
        myResponse2.name = 'Antonio2';
        myResponse2.email = 'test22@example.com';
        myResponse2.phone = '555-555-555';
        myResponse2.website = 'antonio2.viewer.com';
       
        List<WrapperResponse> responseList = new List<WrapperResponse>{myResponse1,myResponse2};

        String responseBody = JSON.serialize(responseList);

        response.setHeader('Content-Type','application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        System.debug('ResponseBody: ' + responseBody);
        
        return response;
    }

    class WrapperResponse {
       String name;
       String email;
       String phone;
       String website;
    }
    
}