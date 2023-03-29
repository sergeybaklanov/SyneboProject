/**
 * Created by User on 03.03.2023.
 */

trigger MovieTrigger on Movie__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    MovieTriggerHandler handler = new MovieTriggerHandler();
    handler.run();
}