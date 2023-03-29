// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// DeleteMoviesBatch sched = new DeleteMoviesBatch();
// String cronExp = '0 0 10 ? * * *';
// System.schedule('Delete movies with status \"Decline\"', cronExp, sched);
// System.debug('Cron expression executed');
// To test Batch
// Studio__c studio = [SELECT Id FROM Studio__c WHERE Name = 'Pixar'];
// List<Movie__c> moviesList = new List<Movie__c>();
// for(Integer i = 0; i<20; i++){
//     moviesList.add(new Movie__c(Name='Test Movie'+i, Studio__c = studio.id, Status__c='To Do'));
// }
// insert moviesList;
// for(Movie__c movie_i : moviesList){
//     movie_i.Status__c= 'Decline';
// }
// update moviesList;
DeleteMoviesBatch batch = new DeleteMoviesBatch();
Database.executeBatch(batch, 4);