public class TestDataFactory{
    public static List<Movie__c> createMoviesList(Integer num, Id studioId, Boolean doInsert){
        List<Movie__c> moviesList = new List<Movie__c>();
        for (Integer i = 0; i < num; i++){
            moviesList.add(new Movie__c(Name = 'Test Movie' + i, Status__c = 'To Do', Studio__c = studioId));
        }
        if (doInsert){
            insert moviesList;
        }
        return moviesList;
    }

    public static List<Studio__c> createStudioList(Integer num, Boolean doInsert){
        List<Studio__c> studioList = new List<Studio__c>();
        for (Integer i = 0; i < num; i++){
            studioList.add(new Studio__c(Name = 'Test Studio' + i));
        }
        if (doInsert){
            insert studioList;
        }
        return studioList;
    }

    public static List<Employee__c> createEmployeeList(Integer num, Boolean doInsert){
        List<Employee__c> employeeList = new List<Employee__c>();
        for (Integer i = 0; i < num; i++){
            employeeList.add(new Employee__c(First_Name__c = 'Employee' + i, Last_Name__c = 'Test'));
        }
        if (doInsert){
            insert employeeList;
        }
        return employeeList;
    }

}