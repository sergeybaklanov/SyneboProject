/**
 * Created by User on 07.03.2023.
 */
public with sharing class RelatedEmployeeController {

    @AuraEnabled(Cacheable=false)
    public static List<MovieEmployeeWrapper> getRelatedRecords(Id recordId) {
//        System.debug('Get related method starting');
        List<Movie_Employee__c> movieEmployeesList = [
                SELECT Id, Movie__c, Employee__r.Employee_Name__c, Position__c
                FROM Movie_Employee__c
                WHERE Movie__c = :recordId
                ORDER BY Position__c
        ];

        Map<String, String> orderEmployeePositionMap = new Map<String, String>();
       // List<Movie_Employee__c> resultList = new List<Movie_Employee__c>();
        List<MovieEmployeeWrapper> movieEmployeeWrapperList = new List<MovieEmployeeWrapper>();
        List<Employee_Position__mdt> orderEmployeePositionsList = Employee_Position__mdt.getAll().values();

        for (Employee_Position__mdt employeePosition_i : orderEmployeePositionsList) {
            orderEmployeePositionMap.put(employeePosition_i.Position__c, String.valueOf(employeePosition_i.Sequence_number__c));
        }
        for (Movie_Employee__c employee_i : movieEmployeesList) {
            Integer position;

            if (orderEmployeePositionMap.containsKey(employee_i.Position__c)) {
                position = Integer.valueOf(orderEmployeePositionMap.get(employee_i.Position__c));
            } else {
                position = Integer.valueOf(orderEmployeePositionMap.get('Others'));
            }
            movieEmployeeWrapperList.add(new MovieEmployeeWrapper(employee_i, position));
        }
        movieEmployeeWrapperList.sort();

        if (!movieEmployeeWrapperList.isEmpty()) {
//            System.debug('List with results: '+movieEmployeeWrapperList);
            return movieEmployeeWrapperList;
        } else {
            System.debug('Result list is empty');
        }
        return null;
    }

    @AuraEnabled (Cacheable=true)
    public static List<Employee__c> getAllEmployees() {
        List<Employee__c> employeeList = [SELECT Id, Employee_Name__c FROM Employee__c];

        if (!employeeList.isEmpty()) {
            return employeeList;
        }
        return null;
    }

    @AuraEnabled
    public static void hireEmployee(Id movieId, Id employeeId, String position) {
        Movie_Employee__c newMovieEmployee = new Movie_Employee__c(Movie__c = movieId, Employee__c = employeeId, Position__c = position);
        insert newMovieEmployee;
    }
    @AuraEnabled
    public static void dismissEmployee( List<Id> employeeIdsList) {
        System.debug('EMPLOYEE list to delete:');
        System.debug(employeeIdsList.toString());
        List<Movie_Employee__c> movieEmployeesToDismissList = [SELECT Id FROM Movie_Employee__c WHERE Id IN :employeeIdsList];

        try {
            delete movieEmployeesToDismissList;
        } catch (Exception error) {
            System.debug('Error while deleting Movie_Employee record: ' + error.getMessage());
        }
    }

    public class MovieEmployeeWrapper implements Comparable {

        @AuraEnabled
        public Movie_Employee__c movieEmployee;
        public Integer positionNumber;

        public MovieEmployeeWrapper(Movie_Employee__c movieEmployee, Integer positionNumber) {
            this.movieEmployee = movieEmployee;
            this.positionNumber = positionNumber;
        }

        public Integer compareTo(Object obj) {
            MovieEmployeeWrapper other = (MovieEmployeeWrapper) obj;
            return this.positionNumber - other.positionNumber;
        }
    }
}