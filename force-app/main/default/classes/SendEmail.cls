public without sharing class SendEmail {
    public static void sendEmail(String toAddress, String subject, String body, Id htmlTemplateId) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new String[]{toAddress});
      mail.setSubject(subject);
      mail.setPlainTextBody(body);
     // mail.setTemplateId(htmlTemplateId);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }