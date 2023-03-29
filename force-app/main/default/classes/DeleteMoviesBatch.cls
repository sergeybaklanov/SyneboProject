public class DeleteMoviesBatch implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    private static String errorsLog = '';
    public void execute(SchedulableContext context){
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Movie__c WHERE Status__c=\'Decline\'');
    }

    public void execute(Database.BatchableContext BC, List<Movie__c> moviesList){

        Database.DeleteResult[] deleteResults = Database.delete (moviesList, false);
        for (Database.DeleteResult deleteResult : deleteResults){
            if (deleteResult.isSuccess()){
                System.debug('Record deleted successfully!');
            } else{
                System.debug('Record delete failed!');
            }
            for (Database.Error err : deleteResult.getErrors()){
                errorsLog += 'The following error has occurred. ' + err.getStatusCode() + ': ' + err.getMessage() + 
                         'Fields that affected this error: ' + err.getFields() + '|';
                // System.debug('The following error has occurred.');
                // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                // System.debug('Fields that affected this error: ' + err.getFields());
            }
            System.debug('errorsLog!!!!!!!!: ' + errorsLog);

        }
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];

        // Send an email notification
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ 'sergeybaklanov468@gmail.com' });
        mail.setSubject('Batch Apex Job ' + job.Status);
        String body = 'The Batch Apex Job ' + job.Id + ' completed with Status: ' + job.Status + '.';
        body += 'Processed ' + job.JobItemsProcessed + ' of ' + job.TotalJobItems + ' jobs.';
        body += 'Number of errors: ' + job.NumberOfErrors + '.\n';

        body += errorsLog;

        mail.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        System.debug('Email sended: ' + body);
    }

}