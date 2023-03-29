@IsTest
public with sharing class BDayNotificationScheduleTest{
    @TestSetup
    static void makeData(){
        User user = [SELECT Id, Name, Email
                     FROM User
                     WHERE FirstName = 'Serhii' AND LastName = 'Baklanov'];
        List<Employee__c> employeeTestList = new List<Employee__c>();
        for (Integer i = 0; i < 5; i++){
            employeeTestList.add(new Employee__c(Name = 'TestEmployee ' + i, User__c = user.Id, Email__c = 'sergeybaklanov468@gmail.com', Birthday__c = Date.today()));
        }
        insert employeeTestList;
    }
    @isTest
    public static void BDayNotificationTest(){
        String crone = '0 0 9 ? * * *';
        Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>([SELECT Id, Name, Email__c
                                                                     FROM Employee__c]);
        Set<Id> employeeIdsSet = employeeMap.keySet();
        System.debug('employeeIdsSet ' + employeeIdsSet.toString());
        Test.startTest();

        String jobId = System.schedule('BDNotificationTest', crone, new BDayNotificationSchedule());

        Test.stopTest();
        System.debug('jobId: ' + jobId);
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors, JobType, CronTriggerId
                                   FROM AsyncApexJob WHERE CronTriggerId=:jobId];
        System.debug('jobs: ' + jobs);

        System.assertEquals(1, jobs.size(), 'The number of AsyncApexJob records should be 1.');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'The number of errors in AsyncApexJob should be 0.');
    }
}