@isTest
global class AnimalsHttpCalloutMock implements HttpCalloutMock {

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    private Integer statusCode;

    public AnimalsHttpCalloutMock(Integer statusCode) {
        this.statusCode=statusCode; 
    }

   // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setStatusCode(statusCode);
        return response; 
    }
}