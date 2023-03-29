/**
 * Created by User on 17.03.2023.
 */
public with sharing class CinemaScheduleController{
    @AuraEnabled
    public static List<Movie_Employee__c> getCinemaMovies(Id cinemaRecordId, Date selectedDate){
        System.debug('cinemaRecordId: ' + cinemaRecordId);
        System.debug('selectedDate: ' + selectedDate);

        String country;

        //1 Get cinema record info
        Cinema__c cinemaRecord = [SELECT Id, Country__c
                                  FROM Cinema__c
                                  WHERE Id = :cinemaRecordId];
        country = cinemaRecord.Country__c;

        //Get information about all movies related to the cinema according to date that user selected
        List<Cinema_Movie__c> cinemaMovieList = [SELECT Id, Premiere_date__c, Shown_till__c, Movie__c, Movie__r.Name, Cinema__r.Country__c
                                                 FROM Cinema_Movie__c
                                                 WHERE Cinema__c = :cinemaRecordId AND Shown_till__c >= :selectedDate AND Premiere_date__c <= :selectedDate];
        System.debug('cinemaMovieList: ' + cinemaMovieList);

        // List where we will put all movies that still shown
        List<Id> movieResultIdsList = new List<Id>();

        if (!cinemaMovieList.isEmpty()){
            for (Cinema_Movie__c cinemaMovie_i : cinemaMovieList){
                movieResultIdsList.add(cinemaMovie_i.Movie__c);
            }
        }

        //Get all movies from Country Movie tab except movies that we already have in the Cinema Movie tab
        List<Country_Movie__c> countryMovieList = [SELECT Id, Country__c, Shown_till__c, Premiere_date__c, Movie__c, Movie__r.Name
                                                   FROM Country_Movie__c
                                                   WHERE Country__c = :country AND Movie__c NOT IN:movieResultIdsList AND Shown_till__c >= :selectedDate AND Premiere_date__c <= :selectedDate];
        System.debug('countryMovieList: ' + countryMovieList);

        if (!countryMovieList.isEmpty()){
            for (Country_Movie__c countryMovie_i : countryMovieList){
                movieResultIdsList.add(countryMovie_i.Movie__c);
            }
        }

        List<Movie_Employee__c> movieEmployeesList = [SELECT Employee__r.Employee_Name__c, Position__c, Movie__c, Movie__r.Name, Movie__r.Studio__r.Name
                                                      FROM Movie_Employee__c
                                                      WHERE Position__c = 'Director' AND Movie__c IN:movieResultIdsList];

        
            System.debug('Returning List ' + movieEmployeesList);
            return movieEmployeesList;
       
    }
}