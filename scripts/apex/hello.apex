// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
List<Movie_Review__c> reviews = [SELECT Id, Movie_Portal_User__r.Name
                                 FROM Movie_Review__c
                                 WHERE Movie_Portal_User__r.Name LIKE 'User%'];
delete reviews;
List<Movie_Portal_User__c> user = [SELECT Id
                                   FROM Movie_Portal_User__c
                                   WHERE Name LIKE 'User%'];
delete user;