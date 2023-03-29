trigger WorklogTrigger on Worklog__c (before insert,after insert, before update, after update,before delete, after delete, after undelete) {
    WorklogTriggerHandler handler = new WorklogTriggerHandler();
    handler.run();
}