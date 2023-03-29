public class ProjectUtils{
    public static void sendWorklogsPDF(Id projectId, Id contactId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{ [SELECT Email
                                            FROM Contact
                                            WHERE Id = :contactId].Email };
        mail.setToAddresses(toAddress);
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
    }
}