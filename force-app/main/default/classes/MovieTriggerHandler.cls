/**
 * Created by User on 02.03.2023.
 */
public with sharing class MovieTriggerHandler extends TriggerHandler{
    public override void beforeInsert(){
    }

    public override void beforeUpdate(){
        checkStatusField((Map<Id, Movie__c>)Trigger.oldMap, Trigger.new );
    }

    public override void beforeDelete(){
        checkPickField((Map<Id, Movie__c>)Trigger.oldMap);
    }

    public override void afterInsert(){
    }

    public override void afterUpdate(){
    }

    public override void afterDelete(){
    }

    public override void afterUndelete(){
    }

    private static void checkStatusField(Map<Id, Movie__c> oldMoviesMap, List<Movie__c> newMoviesList){

        List<Movie_setting_rule__mdt> metadataList = Movie_setting_rule__mdt.getAll().values();

        MovieReleaseDateSetValue__c releaseDateSetWord = MovieReleaseDateSetValue__c.getOrgDefaults();

        Map<String, Set<String>> metadataMap = new Map<String, Set<String>>();

        for (Movie_setting_rule__mdt metadata_i : metadataList){
            if (metadataMap.containsKey(metadata_i.StatusFrom__c)){
                metadataMap.get(metadata_i.StatusFrom__c).add(metadata_i.StatusTo__c);
            } else{
                metadataMap.put(metadata_i.StatusFrom__c, new Set<String>{ metadata_i.StatusTo__c });
            }
        }
        String releaseDateSetterStatus = releaseDateSetWord.ReleaseDateSetWord__c;

        for (Movie__c movie_i : newMoviesList){
            Boolean validStatusValues = false;

            if (Trigger.isUpdate){
                if (!oldMoviesMap.get(movie_i.Id).Status__c.equals(movie_i.Status__c)){

                    if (metadataMap.containsKey(oldMoviesMap.get(movie_i.Id).Status__c) && metadataMap.get(oldMoviesMap.get(movie_i.Id).Status__c).contains(movie_i.Status__c)){
                        validStatusValues = true;
                    }
                    if (!validStatusValues){
                        movie_i.addError('You cannot switch from ' + oldMoviesMap.get(movie_i.Id).Status__c + ' to ' + movie_i.Status__c);
                    }
                    if (movie_i.Status__c.equals(releaseDateSetterStatus)){
                        System.debug('Release date set');
                        movie_i.Release_date__c = Date.today();
                    }
                }
            }
        }
    }

    private static void checkPickField(Map<Id, Movie__c> oldMoviesMap){
        for (Id movieId_i : oldMoviesMap.keySet()){
            if (oldMoviesMap.get(movieId_i).Denie_To_Delete__c == true){
                oldMoviesMap.get(movieId_i).addError('You cannot delete this movie because it is denied to delete.');
            }
        }
    }

}