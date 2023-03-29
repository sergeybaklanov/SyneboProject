public with sharing class ProjectIssuesController{
    @AuraEnabled
    public static List<Issue__c> obtainIssues(Id projectId){
        System.debug('projectId: ' + projectId);
        try{

            return [SELECT Id, Assignee__c,Summary__c
                    FROM Issue__c
                    WHERE Id =:projectId];


        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}