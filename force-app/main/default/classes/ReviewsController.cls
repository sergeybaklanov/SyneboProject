public with sharing class ReviewsController{
    @future(callout = true)@AuraEnabled
    public static void pullReviews(Id movieRecordId){
        Movie__c movie = [SELECT Id, External_Id__c
                          FROM Movie__c
                          WHERE Id = :movieRecordId];
        List<Movie_Review__c> movieReviewsList = [SELECT Id, Movie_Portal_User__r.Email__c, Movie__c, Movie__r.External_Id__c, RecordId__c
                                                  FROM Movie_Review__c
                                                  WHERE Movie__c = :movieRecordId];

        List<Movie_Review__c> movieReviewToInsertList = new List<Movie_review__c>();
        List<Movie_Portal_User__c> portalUsersToInsertList = new List<Movie_Portal_User__c>();

        HttpResponse response = getRequest('https://jsonplaceholder.typicode.com/comments?postId=' + movie.External_Id__c);
        if (response.getStatusCode() == 200){

            List<WrapperReview> resultList = (List<WrapperReview>)JSON.deserialize(response.getBody(), List<WrapperReview>.class);

            //Keys -emails. Values a movie reviews
            Map<String, WrapperReview> wrapperReviewsMap = new Map<String, WrapperReview>();
            for (WrapperReview review_i : resultList){
                wrapperReviewsMap.put(review_i.email, review_i);
            }

            List<Movie_Portal_User__c> moviePortalUsers = [SELECT Id, Email__c, Name
                                                           FROM Movie_Portal_User__c
                                                           WHERE Email__c IN:wrapperReviewsMap.keySet()];

            // Collection of key - emails which we need find in outside resource
            Set<String> emailsNotFoundSet = new Set<String>();
            emailsNotFoundSet.addAll(wrapperReviewsMap.keySet());
            //Collection of all exist users in the response from the Movie_Portal_User__c table  key- email, value - User
            /* --1-- */
            Map<String, Movie_Portal_User__c> existMoviePortalUsersMap = new Map<String, Movie_Portal_User__c>();
            for (Movie_Portal_User__c user_i : moviePortalUsers){
                existMoviePortalUsersMap.put(user_i.Email__c, user_i);
                // Delete existing users from list to external search
                if (emailsNotFoundSet.contains(user_i.Email__c) && (!user_i.Name.contains('User'))){
                    emailsNotFoundSet.remove(user_i.Email__c);
                }
            }

            //Collection of all users that we found from external resource. Key- email, value - WrapperUser
            ///* --2-- */
            Map<String, Movie_Portal_User__c> responseUserMap = new Map<String, Movie_Portal_User__c>();
            // Map<String, Movie_Portal_User__c> notFoundedUserMap = new Map<String, Movie_Portal_User__c>();

            if (!emailsNotFoundSet.isEmpty()){
                for (String email_i : emailsNotFoundSet){
                    HttpResponse userResponse = getRequest('https://jsonplaceholder.typicode.com/users?email=' + email_i);
                    if (userResponse.getStatusCode() == 200){
                        WrapperUser wrapperUser = null;
                        try{
                            wrapperUser = (WrapperUser)JSON.deserialize(response.getBody(), WrapperUser.class);
                            System.debug('wrapperUser: ' + wrapperUser);
                            responseUserMap.put(email_i, new Movie_Portal_User__c(Email__c = email_i, Name = wrapperUser.name, Phone__c = wrapperUser.phone, Website__c = wrapperUser.website));
                        } catch (JSONException e){
                            System.debug('Json Exception on wrapperUser  : ' + e.getMessage());
                        } finally{
                            System.debug('wrapperUser: ' + wrapperUser);
                            if (wrapperUser == null && !existMoviePortalUsersMap.containsKey(email_i)){
                                Movie_Portal_User__c newPortalUser = new Movie_Portal_User__c(Email__c = email_i, Name = 'User ' + email_i);
                                responseUserMap.put(email_i, newPortalUser);

                            }
                        }
                    }
                }
            } else{
                System.debug('emailsNotFoundSet is empty');
            }

            if (!responseUserMap.isEmpty()){
                Database.upsert (responseUserMap.values(), Movie_Portal_User__c.Email__c);
            } else{
                System.debug('responseUserMap is empty');
            }


            //Creating the map of exist Movie_Reviews__c for current Movie__c from movieReviewsList Key - User Email, Value - Movie_review__c
            Map<String, Movie_Review__c> existEmailReviewsMap = new Map<String, Movie_Review__c>();
            for (Movie_Review__c review_i : movieReviewsList){
                System.debug('review_i.Movie_Portal_User__r.Email__c ' + review_i.Movie_Portal_User__r.Email__c);
                existEmailReviewsMap.put(review_i.Movie_Portal_User__r.Email__c, review_i);
            }
            for (String email_i : wrapperReviewsMap.keySet()){

                Movie_Review__c tempReview = new Movie_Review__c(Movie__c = movieRecordId, Title__c = wrapperReviewsMap.get(email_i).name, Body__c = wrapperReviewsMap.get(email_i).body, RecordId__c = wrapperReviewsMap.get(email_i).id);

                if (existMoviePortalUsersMap.containsKey(email_i)){
                    tempReview.Movie_Portal_User__c = existMoviePortalUsersMap.get(email_i).Id;
                } else if (responseUserMap.containsKey(email_i)){
                    tempReview.Movie_Portal_User__c = responseUserMap.get(email_i).Id;
                }
                movieReviewToInsertList.add(tempReview);
            }
            Database.upsert (movieReviewToInsertList, Movie_Review__c.RecordId__c);
        }
    }

    @TestVisible
    private static HttpResponse getRequest(String endPoint){
        Http httpObject = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        System.debug('requestEndPOINT: ' + request.getEndpoint());
        request.setMethod('GET');
        HttpResponse response = httpObject.send(request);
        System.debug('response: ' + response);
        return response;
    }

    class WrapperReview{
        public Integer postId;
        public String id;
        public String name;
        public String email;
        public String body;
    }

    class WrapperUser{
        public String name;
        public String email;
        public String phone;
        public String website;

    }

}