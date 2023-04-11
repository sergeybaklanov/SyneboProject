public with sharing class LocationMapController{
    @AuraEnabled
    public static List<Cinema__c> getNearestCinemas(Decimal latitude, Decimal longtitude){
        List<Cinema__c> resultCinemasList = [SELECT Id, Name, Location__c, Location__Latitude__s, Location__Longitude__s
                                             FROM Cinema__c];
        System.debug('result' + resultCinemasList);
        return resultCinemasList;
    }

}

// 53.024441, 17.973214
// 53.025609, 18.119359
// 0,001168, 0,146145