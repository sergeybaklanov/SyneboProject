@IsTest
global with sharing class MovieReviewsCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){

        if (request.getEndpoint().contains('https://jsonplaceholder.typicode.com/comments?postId=')){
            HttpResponse response = new HttpResponse();
            WrapperUserResponse myResponse1 = new WrapperUserResponse();
            myResponse1.postId = 5;
            myResponse1.id = 21;
            myResponse1.name = 'Response example Name 21';
            myResponse1.body = 'Response example Body 21';
            myResponse1.email = 'test21@example.com';

            WrapperUserResponse myResponse2 = new WrapperUserResponse();
            myResponse2.postId = 5;
            myResponse2.id = 22;
            myResponse2.name = 'Response example Name 22';
            myResponse2.body = 'Response example Body 22';
            myResponse2.email = 'test22@example.com';

            WrapperUserResponse myResponse3 = new WrapperUserResponse();
            myResponse3.postId = 5;
            myResponse3.id = 23;
            myResponse3.name = 'Response example Name 23';
            myResponse3.body = 'Response example Body 23';
            myResponse3.email = 'test23@example.com';

            List<WrapperUserResponse> responseList = new List<WrapperUserResponse>{ myResponse1, myResponse2, myResponse3 };

            String responseBody = JSON.serialize(responseList);

            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBody);
            response.setStatusCode(200);
            System.debug('ResponseBody: ' + responseBody);

            return response;
        } else if (request.getEndpoint().contains('https://jsonplaceholder.typicode.com/users?email=')){

            HttpResponse response = new HttpResponse();
            WrapperEmailResponse myResponse1 = new WrapperEmailResponse();
            myResponse1.name = 'Antonio1';
            myResponse1.email = 'test21@example.com';
            myResponse1.phone = '666-666-666';
            myResponse1.website = 'antonio1.viewer.com';

            WrapperEmailResponse myResponse2 = new WrapperEmailResponse();
            myResponse2.name = 'Antonio2';
            myResponse2.email = 'test22@example.com';
            myResponse2.phone = '555-555-555';
            myResponse2.website = 'antonio2.viewer.com';

            List<WrapperEmailResponse> responseList = new List<WrapperEmailResponse>{ myResponse1, myResponse2 };

            String responseBody = JSON.serialize(responseList);

            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBody);
            response.setStatusCode(200);
            System.debug('ResponseBody: ' + responseBody);
            return response;

        } else{
            return null;
        }
    }

    class WrapperUserResponse{
        Integer postId;
        Integer id;
        String name;
        String email;
        String body;
    }

    class WrapperEmailResponse{
        String name;
        String email;
        String phone;
        String website;

    }

}