trigger MovieEmployeeTrigger on Movie_Employee__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    MovieEmployeeTriggerHandler handler = new MovieEmployeeTriggerHandler();
    handler.run();
}