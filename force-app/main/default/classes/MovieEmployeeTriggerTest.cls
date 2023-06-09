@IsTest
public with sharing class MovieEmployeeTriggerTest{
    @TestSetup
    static void makeData(){
        List<Employee__c> employeeList = TestDataFactory.createEmployeeList(10, true);
        List<Studio__c> listStudio = TestDataFactory.createStudioList(1, true);
        List<Movie__c> movieList = TestDataFactory.createMoviesList(1, listStudio[0].Id, true);
    }

    @IsTest
    public static void preventDuplicatePositionOnEmployeeInsertTest(){
        List<Employee__c> employeeList = [SELECT Id
                                          FROM Employee__c
                                          LIMIT 1];
        List<Movie__c> movieList = [SELECT Id
                                    FROM Movie__c
                                    LIMIT 1];

        List<Movie_Employee__c> movieEmployeeList = new List<Movie_Employee__c>();

        for (Integer i = 0; i < 10; i++){
            movieEmployeeList.add(new Movie_Employee__c(Movie__c = movieList[0].Id, Employee__c = employeeList[0].Id, Position__c = 'TestPosition' + i));
            if (i < 5){
                movieEmployeeList.add(new Movie_Employee__c(Movie__c = movieList[0].Id, Employee__c = employeeList[0].Id, Position__c = 'TestPosition' + i));
            }
        }

        System.debug('movieEmployeeList: ' + movieEmployeeList);

        Test.startTest();
        Database.insert (movieEmployeeList, false);
        Test.stopTest();
        List<Movie_Employee__c> movieEmployeeResultList = [SELECT Id, Position__c
                                                           FROM Movie_Employee__c];
        System.debug('movieEmployeeResultList: ' + movieEmployeeResultList);

        System.debug('movieEmployeeResultList: ' + movieEmployeeResultList.size());
        System.assertEquals(10, movieEmployeeResultList.size(), 'Insertion of 10 records Movie_Employee fail');
    }

    @IsTest
    public static void preventDuplicatePositionOnEmployeeUpdateTest(){

        List<Movie__c> movieList = [SELECT Id
                                    FROM Movie__c
                                    LIMIT 1];
        List<Employee__c> employeeList = [SELECT Id
                                          FROM Employee__c
                                          LIMIT 10];
        List<Movie_Employee__c> movieEmployeeList = new List<Movie_Employee__c>();

        for (Integer i = 0; i < employeeList.size(); i++){
            movieEmployeeList.add(new Movie_Employee__c(Employee__c = employeeList[i].Id, Movie__c = movieList[0].Id, Position__c = 'Actor'));
        }
        Test.startTest();
        insert movieEmployeeList;

        List<Movie_Employee__c> movieEmployeeToUpdateList = [SELECT Id, Position__c
                                                             FROM Movie_Employee__c
                                                             LIMIT 5];
        for (Movie_Employee__c movieEmployee_i : movieEmployeeToUpdateList){
            movieEmployee_i.Position__c = 'Director';
        }

        Database.update (movieEmployeeToUpdateList, false);
        Test.stopTest();

        System.assertEquals(5, [SELECT Id, Position__c
                                FROM Movie_Employee__c
                                WHERE Position__c = 'Director'].size(), 'Records wasn\'t updated');
    }

}