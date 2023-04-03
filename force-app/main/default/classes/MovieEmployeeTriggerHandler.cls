/**
 * Created by User on 13.03.2023.
 */
public with sharing class MovieEmployeeTriggerHandler extends TriggerHandler{
    protected override void beforeInsert(){
        preventDuplicatePositionOnEmployee(null, Trigger.new );
    }

    protected override void beforeUpdate(){
        preventDuplicatePositionOnEmployee((Map<Id, Movie_Employee__c>)Trigger.oldMap, Trigger.new );
    }

    protected override void beforeDelete(){
    }

    protected override void afterInsert(){
        makeUpdateEvent((Map<Id, Movie_Employee__c>)Trigger.newMap);
    }

    protected override void afterUpdate(){
        makeUpdateEvent((Map<Id, Movie_Employee__c>)Trigger.newMap);
    }

    protected override void afterDelete(){
        makeUpdateEvent((Map<Id, Movie_Employee__c>)Trigger.oldMap);
    }

    protected override void afterUndelete(){
        makeUpdateEvent((Map<Id, Movie_Employee__c>)Trigger.newMap);
    }

    private static void preventDuplicatePositionOnEmployee(Map<Id, Movie_Employee__c> oldMovieEmployeeMap, List<Movie_Employee__c> newMovieEmployeeList){

        Set<Id> newMovieIdsSet = new Set<Id>();
        Set<Id> newEmployeeIdsSet = new Set<Id>();

        //Collecting data to Map and prevent duplicate of position for Employees on Movie
        Map<Id, Map<Id, List<String>>> movieEmployeePositionMap = new Map<Id, Map<Id, List<String>>>();

        for (Movie_Employee__c movieEmployee_i : newMovieEmployeeList){
            if (movieEmployeePositionMap.containsKey(movieEmployee_i.Movie__c)){
                if (movieEmployeePositionMap.get(movieEmployee_i.Movie__c).containsKey(movieEmployee_i.Employee__c)){
                    if (movieEmployeePositionMap.get(movieEmployee_i.Movie__c).get(movieEmployee_i.Employee__c).contains(movieEmployee_i.Position__c)){
                        movieEmployee_i.Position__c.addError(movieEmployee_i.Employee__c + ' employee already has ' + movieEmployee_i.Position__c + ' position on this movie');
                    } else{
                        movieEmployeePositionMap.get(movieEmployee_i.Movie__c).get(movieEmployee_i.Employee__c).add(movieEmployee_i.Position__c);
                    }
                } else{
                    movieEmployeePositionMap.get(movieEmployee_i.Movie__c).put(movieEmployee_i.Employee__c, new List<String>{ movieEmployee_i.Position__c });
                }
            } else{
                Map<Id, List<String>> newEmployeePositionMap = new Map<Id, List<String>>();
                newEmployeePositionMap.put(movieEmployee_i.Employee__c, new List<String>{ movieEmployee_i.Position__c });
                movieEmployeePositionMap.put(movieEmployee_i.Movie__c, newEmployeePositionMap);

                //Collecting records id for use them in database search
                newMovieIdsSet.add(movieEmployee_i.Movie__c);
                newEmployeeIdsSet.add(movieEmployee_i.Employee__c);
            }
        }


        if (Trigger.isInsert || Trigger.isUpdate){
            List<Movie_Employee__c> existingMovieEmployeeList = [SELECT Id, Movie__c, Employee__c, Position__c
                                                                 FROM Movie_Employee__c
                                                                 WHERE Movie__c IN:newMovieIdsSet AND Employee__c IN:newEmployeeIdsSet];

            for (Movie_Employee__c movieEmployee_i : newMovieEmployeeList){
                if (oldMovieEmployeeMap == null || !(oldMovieEmployeeMap.get(movieEmployee_i.Id).Position__c == movieEmployee_i.Position__c)){
                    for (Movie_Employee__c existingMovieEmployee_i : existingMovieEmployeeList){
                        if (existingMovieEmployee_i.Position__c == movieEmployee_i.Position__c){
                            movieEmployee_i.addError('This employee already has ' + movieEmployee_i.Position__c + ' position on this movie');
                        }
                    }
                }
            }
        }
    }

    private static void makeUpdateEvent(Map<Id, Movie_Employee__c> movieEmployeeMap){
        List<Hired_Employee__e> hiredEmployeesEventsList = new List<Hired_Employee__e>();
        for (Id movieEmployee_i : movieEmployeeMap.keySet()){
            Id movieId_i = movieEmployeeMap.get(movieEmployee_i).Movie__c;
            hiredEmployeesEventsList.add(new Hired_Employee__e(Movie_Id__c = movieId_i));
        }

        List<Database.SaveResult> results = EventBus.publish(hiredEmployeesEventsList);

        for (Database.SaveResult result : results){
            if (result.isSuccess()){
                System.debug('Successfully published event.');
            } else{
                for (Database.Error error : result.getErrors()){
                    System.debug(error.getMessage());
                    System.debug(error.getStatusCode());
                }
            }
        }
    }

}