@isTest
public class WorklogTriggerHandlerTest{
    @TestSetup
    static void makeData(){

        Project__c project1 = new Project__c(Name = 'Project');
        insert project1;

        // Create test Issues
        List<Issue__c> issues = new List<Issue__c>();
        Issue__c issue1 = new Issue__c(Summary__c = 'Issue 1', Project__c = project1.Id);
        Issue__c issue2 = new Issue__c(Summary__c = 'Issue 2', Project__c = project1.Id);
        issues.add(issue1);
        issues.add(issue2);

        insert issues;

        List<Worklog__c> worklogs = new List<Worklog__c>();

        for (Integer i = 0; i < 100; i++){
            worklogs.add(new Worklog__c(Issue__c = issue1.Id, Actual_Hours__c = 10, Billable_Hours__c = 5, Type__c = 'Issue', Sub_type__c = 'Development'));
        }

        insert worklogs;
    }

    @isTest
    static void specifyBillableHoursInsertTest(){

        //Data setup and insert
        List<Worklog__c> worklogList = new List<Worklog__c>();

        for (Integer i = 0; i < 100; i++){
            worklogList.add(new Worklog__c(Type__c = 'Issue', Actual_hours__c = 5, Sub_type__c = 'Research'));
        }

        for (Integer i = 0; i < 100; i++){
            worklogList.add(new Worklog__c(Type__c = 'Internal', Actual_hours__c = 5, Sub_type__c = 'Research'));
        }
        insert worklogList;

        // Verify that Billable_hours__c is correctly set for each Worklog__c record
        List<Worklog__c> worklogs = [SELECT Id, Billable_hours__c, Type__c, Actual_hours__c
                                     FROM Worklog__c
                                     WHERE Id IN:worklogList];

        for (Worklog__c w : worklogs){
            if (w.Type__c == 'Issue'){
                System.assertEquals(w.Billable_hours__c, w.Actual_hours__c);
            } else if (w.Type__c == 'Internal'){
                System.assertEquals(w.Billable_hours__c, 0);
            }
        }
    }

    @IsTest
    static void specifyBillableHoursUpdateTest(){
        //Data setup
        List<Worklog__c> worklogList = new List<Worklog__c>();

        for (Integer i = 0; i < 100; i++){
            worklogList.add(new Worklog__c(Type__c = 'Issue', Actual_hours__c = 5, Sub_type__c = 'Research'));
        }
        insert worklogList;

        List<Worklog__c> worklogsToUpdate = [SELECT Id, Billable_hours__c, Type__c, Actual_hours__c
                                             FROM Worklog__c
                                             WHERE Id IN:worklogList];

        //Make updates
        for (Integer i = 0; i < worklogsToUpdate.size(); i++){
            if (i < 50){
                worklogsToUpdate.get(i).Billable_hours__c = null;
            } else{
                worklogsToUpdate.get(i).Type__c = 'Internal';
            }
        }
        update worklogsToUpdate;

        List<Worklog__c> worklogsResultList = [SELECT Id, Billable_hours__c, Type__c, Actual_hours__c
                                               FROM Worklog__c
                                               WHERE Id IN:worklogsToUpdate];

        for (Worklog__c w : worklogsResultList){
            if (w.Type__c == 'Issue'){
                System.assertEquals(5, w.Billable_hours__c, 'Issue should not be updated to Actual_hours__c');
            } else if (w.Type__c == 'Internal'){
                System.assertEquals(0, w.Billable_hours__c, 'Billable_hours should be 0');
            }
        }
    }

    @isTest
    static void calculateTotalActualAndBillableHours_InsertTest(){

        Issue__c issue = [SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                          FROM Issue__c
                          WHERE Summary__c = 'Issue 1'];
        List<AggregateResult> worklogsList = [SELECT SUM(Actual_Hours__c)actualHours, SUM(Billable_Hours__c)billableHours, Issue__c issueId
                                              FROM Worklog__c 
                                              WHERE Issue__c  = :issue.Id
                                              GROUP BY Issue__c];

        System.assertEquals(Integer.valueOf(worklogsList[0].get('billableHours')), issue.Total_Billable_Hours__c, 'TotalBillableHours not equal sum of the Billable_hours in related Worklogs');
        System.assertEquals(Integer.valueOf(worklogsList[0].get('actualHours')), issue.Total_Actual_Hours__c, 'TotalActualHours not equal sum of the Actual_hours in related Worklogs');
    }

    @isTest
    static void calculateTotalActualAndBillableHours_UpdateTest(){
        Issue__c issue2 = [SELECT Id
                           FROM Issue__c
                           WHERE Summary__c = 'Issue 2'];
        List<Worklog__c> worklogsToUpdateList = [SELECT Id, Actual_Hours__c, Billable_Hours__c, Issue__c
                                                 FROM Worklog__c
                                                 WHERE Issue__r.Summary__c = 'Issue 1'
                                                 LIMIT 50];
        for (Worklog__c worklog_i : worklogsToUpdateList){
            for (Integer i = 0; i < 10; i++){
                worklog_i.Issue__c = null;
                continue;
            }
            for (Integer j = 0; j < 5; j++){
                worklog_i.Actual_Hours__c = 1;
                worklog_i.Billable_hours__c = null;
                continue;
            }
            worklog_i.Issue__c = issue2.Id;
        }
        update worklogsToUpdateList;

        List<AggregateResult> worklogsAfterUpdateList = [SELECT SUM(Actual_Hours__c)actualHours, SUM(Billable_Hours__c)billableHours, Issue__c
                                                         FROM Worklog__c
                                                         WHERE Issue__r.Summary__c IN ('Issue 1', 'Issue 2')
                                                         GROUP BY Issue__c ];


        List<Issue__c> issuesList = [SELECT ID, Total_Actual_Hours__c, Total_Billable_Hours__c, Summary__c
                                     FROM Issue__c];

        for (Issue__c issue_i : issuesList){
            Integer actualHours = 0;
            Integer billableHours = 0;
            for (AggregateResult result : worklogsAfterUpdateList){
                if (issue_i.Id == result.get('Issue__c')){
                    actualHours = Integer.valueOf(result.get('actualHours'));
                    billableHours = Integer.valueOf(result.get('billableHours'));
                    break;
                }
            }
            System.assertEquals(actualHours, issue_i.Total_Actual_Hours__c, 'TotalActualHours not equal sum of the Actual_hours in related Worklogs');
            System.assertEquals(billableHours, issue_i.Total_Billable_Hours__c, 'TotalBillableHours not equal sum of the Billable_hours in related Worklogs');
        }
    }

    @isTest
    static void calculateTotalActualAndBillableHours_DeleteTest(){

        List<Worklog__c> worklogsToDeleteList = [SELECT Id
                                                 FROM Worklog__c
                                                 WHERE Issue__r.Summary__c = 'Issue 1'
                                                 LIMIT 10];
        delete worklogsToDeleteList;

        List<AggregateResult> worklogsAfterDeleteList = [SELECT SUM(Actual_Hours__c)actualHours, SUM(Billable_Hours__c)billableHours, Issue__c
                                                         FROM Worklog__c
                                                         WHERE Issue__r.Summary__c = 'Issue 1'
                                                         GROUP BY Issue__c ];


        List<Issue__c> issuesList = [SELECT ID, Total_Actual_Hours__c, Total_Billable_Hours__c, Summary__c
                                     FROM Issue__c
                                     WHERE Summary__c = 'Issue 1'];

        System.assertEquals(worklogsAfterDeleteList[0].get('actualHours'), issuesList[0].Total_Actual_Hours__c, 'TotalActualHours not equal sum of the Actual_hours in related Worklogs');
        System.assertEquals(worklogsAfterDeleteList[0].get('billableHours'), issuesList[0].Total_Billable_Hours__c, 'TotalBillableHours not equal sum of the Billable_hours in related Worklogs');
    }

    @isTest
    static void calculateTotalActualAndBillableHours_UndeleteTest(){
        List<Issue__c> issuesBeforeDeleteList = [SELECT ID, Total_Actual_Hours__c, Total_Billable_Hours__c, Summary__c
                                                 FROM Issue__c
                                                 WHERE Summary__c = 'Issue 1'];

        List<Worklog__c> worklogsToDeleteList = [SELECT Id, Billable_hours__c, Actual_hours__c
                                                 FROM Worklog__c
                                                 WHERE Issue__r.Summary__c = 'Issue 1'
                                                 LIMIT 10];
        delete worklogsToDeleteList;
        List<Issue__c> issuesAfterDeleteList = [SELECT ID, Total_Actual_Hours__c, Total_Billable_Hours__c, Summary__c
                                                FROM Issue__c
                                                WHERE Summary__c = 'Issue 1'];

        System.assertNotEquals(issuesAfterDeleteList[0].get('Total_Actual_Hours__c'), issuesBeforeDeleteList[0].get('Total_Actual_Hours__c'));
        System.assertNotEquals(issuesAfterDeleteList[0].get('Total_Billable_Hours__c'), issuesBeforeDeleteList[0].get('Total_Billable_Hours__c'));

        undelete worklogsToDeleteList;

        List<Issue__c> issuesAfterUndeleteList = [SELECT ID, Total_Actual_Hours__c, Total_Billable_Hours__c, Summary__c
                                                  FROM Issue__c
                                                  WHERE Summary__c = 'Issue 1'];

        System.assertEquals(issuesAfterUndeleteList[0].get('Total_Actual_Hours__c'), issuesBeforeDeleteList[0].get('Total_Actual_Hours__c'),'Related Worklogs records wasn\'t restored correctly');
        System.assertEquals(issuesAfterUndeleteList[0].get('Total_Billable_Hours__c'), issuesBeforeDeleteList[0].get('Total_Billable_Hours__c'),'Related Worklogs records wasn\'t restored correctly');
    }
}