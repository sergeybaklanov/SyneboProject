@IsTest
private with sharing class DeleteMoviesBatchTest{
    @TestSetup
    static void makeData(){
        List<Studio__c> studioList = TestDataFactory.createStudioList(1, true);
        List<Movie__c> movieList = TestDataFactory.createMoviesList(10, studioList[0].Id, true);

        List<Movie__c> moviesToUpdateList = new List<Movie__c>();

        for (Movie__c movie_i : [SELECT Id, Status__c
                                 FROM Movie__c
                                 WHERE Status__c = 'To Do'
                                 LIMIT 5]){

            movie_i.Status__c = 'Decline';

            moviesToUpdateList.add(movie_i);
        }
        update moviesToUpdateList;
    }

    @IsTest
    static void deleteMoviesTest(){
        Test.startTest();
        DeleteMoviesBatch testedBatch = new DeleteMoviesBatch();
        testedBatch.execute(null);
        Test.stopTest();

        List<Movie__c> moviesResultList = [SELECT Id
                                           FROM Movie__c
                                           WHERE Status__c = 'Decline'];
        System.debug('moviesResultList: ' + moviesResultList);

        System.assertNotEquals(null, [SELECT Id
                                      FROM Movie__c
                                      WHERE Status__c = 'Decline'].size(), 'Records with Decline wasn\'t deleted');
    }

}