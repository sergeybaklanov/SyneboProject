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

    public static List<Movie_Review__c> createMovieReviewsList(Integer num, Id movie, Id moviePortalUser, Boolean doInsert){
        List<Movie_Review__c> movieReviewList = new List<Movie_Review__c>();
        for (Integer i = 0; i < num; i++){
            movieReviewList.add(new Movie_Review__c(Movie_Portal_User__c = moviePortalUser, Movie__c = movie, Title__c = 'Test title' + i, Body__c = 'Test body' + i));
        }
        if (doInsert){
            insert movieReviewList;
        }
        return movieReviewList;
    }

    public static List<Movie_Portal_User__c> createMoviePortalUsersList(Integer numberOfUsers, Boolean doInsert){
        List<Movie_Portal_User__c> usersList = new List<Movie_Portal_User__c>();
        for (Integer i = 0; i < numberOfUsers; i++){
            usersList.add(new Movie_Portal_User__c(Name = 'Test Portal User' + i, Email__c = 'test' + i + '@mail.com'));
        }
        if (doInsert){
            insert usersList;
        }
        return usersList;
    }

}