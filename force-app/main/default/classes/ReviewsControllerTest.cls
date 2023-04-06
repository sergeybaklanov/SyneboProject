@IsTest
public with sharing class ReviewsControllerTest{
    @IsTest
    static void getRequestTest(){
        Test.setMock(HttpCalloutMock.class, new MovieReviewsCalloutMock());

        String endPoint = 'https://jsonplaceholder.typicode.com/comments?postId=5';
        HttpResponse response = ReviewsController.getRequest(endPoint);

        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());

        String expectedValue = '[{"postId":5,"name":"Response example Name 21","id":21,"email":"test21@example.com","body":"Response example Body 21"},{"postId":5,"name":"Response example Name 22","id":22,"email":"test22@example.com","body":"Response example Body 22"},{"postId":5,"name":"Response example Name 23","id":23,"email":"test23@example.com","body":"Response example Body 23"}]';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());

        endPoint = 'https://jsonplaceholder.typicode.com/users?email=test21@example.com';
        response = ReviewsController.getRequest(endPoint);

        contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        actualValue = response.getBody();
        System.debug(response.getBody());

        expectedValue = '[{"website":"antonio1.viewer.com","phone":"666-666-666","name":"Antonio1","email":"test21@example.com"},{"website":"antonio2.viewer.com","phone":"555-555-555","name":"Antonio2","email":"test22@example.com"}]';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    @IsTest
    private static void pullReviewsTest(){

        //Data Setup
        List<Studio__c> studioListInsertList = TestDataFactory.createStudioList(1, true);
        List<Movie__c> movieListInsertList = TestDataFactory.createMoviesList(1, studioListInsertList[0].Id, true);
        List<Movie_Review__c> movieReviewInsertList = TestDataFactory.createMovieReviewsList(2, movieListInsertList[0].Id, null, true);
        List<Movie_Portal_User__c> moviePortalUserList = TestDataFactory.createMoviePortalUsersList(2, true);

        moviePortalUserList[0].Email__c = 'test21@example.com';
        update moviePortalUserList;

        movieReviewInsertList[0].Movie_Portal_User__c = moviePortalUserList[0].Id;
        update movieReviewInsertList;

        movieListInsertList[0].External_Id__c = '5';
        update movieListInsertList;

        //Set Mock class
        Test.setMock(HttpCalloutMock.class, new MovieReviewsCalloutMock());

        System.assertEquals(2, [SELECT Id
                                FROM Movie_Review__c
                                WHERE Movie__c = :movieListInsertList[0].Id].size(), 'Movie review count should be 2');
        Test.startTest();
        ReviewsController.pullReviews(movieListInsertList[0].Id);
        Test.stopTest();

        List<Movie__c> movieResultList = [SELECT Id, (SELECT Id
                                                      FROM Movie_Reviews__r)
                                          FROM Movie__c 
                                          WHERE Id = :movieListInsertList[0].Id];

        System.assertNotEquals(0, movieResultList.size(), 'Select query not return any of records');
        System.assertEquals(5, movieResultList[0].Movie_Reviews__r.size(), 'Number of reviews for movie not Equal 5');
    }

}