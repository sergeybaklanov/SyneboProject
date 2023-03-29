trigger ContactTrigger on Contact (before insert) {
    ContactTriggerHandler handler = new ContactTriggerHandler();
    handler.run();

}