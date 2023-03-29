public with sharing class SendPdfReportController{
    @AuraEnabled (Cacheable=true)
    public static void sendReport(Id recordId, String email){
        try {
            sendWorklogsPDF(recordId, email);
//            throw new AuraHandledException('Unexpected error');
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void sendWorklogsPDF(Id projectId, String email){
        // System.debug('projectId inside sendEorklogsPDF: ' + projectId);
        // System.debug('email inside sendEorklogsPDF:: ' + email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{ email });
        mail.setSubject('Worklogs PDF Report for Project Id: ' + projectId);
        mail.setPlainTextBody(projectId);
        PageReference pagePDF = Page.WorklogsList;
        pagePDF.getParameters().put('id', projectId);
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('WorklogsReport.pdf');
        attachment.setContentType('application/pdf');
        attachment.setBody(Test.isRunningTest() ? Blob.valueOf('Test Blob String') : pagePDF.getContentAsPDF());
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail }, false);
        // System.debug('Stop sending email:');
    }

    @AuraEnabled (Cacheable=true)
    public static String prePopulationEmail(Id recordId){
        try {
            System.debug('We call this method and get recordId: ' + recordId);
           Project__c project = [SELECT Id, Primary_Contact__r.Email
           FROM Project__c
           WHERE Id = :recordId];
           String result = project.Primary_Contact__r.Email;
            return  result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}