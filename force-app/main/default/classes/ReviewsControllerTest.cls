@IsTest
public with sharing class ReviewsControllerTest {
    @TestSetup
    static void makeData(){
        List<Studio__c> studioList = TestDataFactory.createStudioList(1,true);
        List<Movie__c> movieList = TestDataFactory.createMoviesList(1,studioList[0].Id, true); 

    }
    @IsTest 
    private static void pullReviewsTest(){
        
    }

    /*
    static void testGetCallout(){
        // Set Mock callout class
        Test.setMock(HttpCalloutMock.class, new MovieReviewsCalloutMock());
        HttpRequest request = new HttpRequest();
        request.setBody('Some request with email');
        HttpResponse response = MovieReviewsCalloutMock.respond(request);
    }
    */
}