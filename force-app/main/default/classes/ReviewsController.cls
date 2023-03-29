public with sharing class ReviewsController{
    @AuraEnabled
    public static Id getExternalId(Id movieRecordId){
        Id externalId = [SELECT Id
                         FROM Movie_Review__c
                         WHERE Movie__c = :movieRecordId].Id;
        return externalId;
    }

}