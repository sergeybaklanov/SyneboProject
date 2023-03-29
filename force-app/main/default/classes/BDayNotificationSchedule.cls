public without sharing class BDayNotificationSchedule implements Schedulable{
  public void execute(SchedulableContext ctx){

    List<Employee__c> employeeList = [SELECT ID, Email__c, Name, User__c
                                  FROM Employee__c
                                  WHERE Birthday__c = TODAY
                                  ];
                                  
    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

    for (Employee__c employee_i : employeeList){
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setToAddresses(new String[]{ (String) employee_i.get('Email__c') });
      message.setSubject('Happy Birthday');
      message.setPlainTextBody('Happy Birthday, ' + employee_i.get('Name') + '!');
      messages.add(message);
    }

    for (Messaging.SingleEmailMessage variable : messages) {
      System.debug('variable: ' + variable.getPlainTextBody());
    }

    Messaging.sendEmail(messages);
  }
}