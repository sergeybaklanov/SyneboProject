public with sharing class ReviewsController{
    @future(callout = true)@AuraEnabled
    public static void pullReviews(Id movieRecordId){
        List<Movie_Review__c> movieReviewsList = [SELECT Id, Movie_Portal_User__r.Email__c, Movie__c, Movie__r.External_Id__c
                                                  FROM Movie_Review__c
                                                  WHERE Movie__c = :movieRecordId];

        List<Movie_Review__c> movieReviewToInsertList = new List<Movie_review__c>();
        List<Movie_Portal_User__c> portalUsersToInsertList = new List<Movie_Portal_User__c>();


        HttpResponse response = getRequest('https://jsonplaceholder.typicode.com/comments?postId=' + movieReviewsList[0].Movie__r.External_Id__c);

        if (response.getStatusCode() == 200){
            List<WrapperReview> resultList = (List<WrapperReview>)JSON.deserialize(response.getBody(), List<WrapperReview>.class);
            // Collection of all emails from the response
            List<String> emailsList = new List<String>();
            //Keys -emails. Values a movie reviews
            Map<String, WrapperReview> wrapperReviewsMap = new Map<String, WrapperReview>();
            for (WrapperReview review_i : resultList){
                wrapperReviewsMap.put(review_i.email, review_i);
                emailsList.add(review_i.email);
            }
            List<Movie_Portal_User__c> moviePortalUsers = [SELECT Id, Email__c
                                                           FROM Movie_Portal_User__c
                                                           WHERE Email__c IN:wrapperReviewsMap.keySet()];

            // Collection of key - emails which we need find in outside resource
            Set<String> emailsNotFoundSet = new Set<String>();

            //Collection of all exist users in the response from the Movie_Portal_User__c table  key- email, value - User
            /* --1-- */Map<String, Movie_Portal_User__c> moviePortalUsersMap = new Map<String, Movie_Portal_User__c>();

            for (Movie_Portal_User__c user_i : moviePortalUsers){
                moviePortalUsersMap.put(user_i.Email__c, user_i);

                if (!wrapperReviewsMap.containsKey(user_i.Email__c)){
                    emailsNotFoundSet.add(user_i.Email__c);
                }
            }

            //Collection of all users that we found from external resource. Key- email, value - WrapperUser
            /* --2-- */Map<String, Movie_Portal_User__c> requestUserMap = new Map<String, Movie_Portal_User__c>();

            if (!emailsNotFoundSet.isEmpty()){
                for (String email_i : emailsNotFoundSet){
                    HttpResponse userResponse = getRequest('https://jsonplaceholder.typicode.com/users?email=' + email_i);
                    if (userResponse.getStatusCode() == 200){
                        WrapperUser wrapperUser = (WrapperUser)JSON.deserialize(response.getBody(), WrapperUser.class);
                        requestUserMap.put(email_i, new Movie_Portal_User__c(Email__c = email_i, Name = wrapperUser.name, Phone__c = wrapperUser.phone, Website__c = wrapperUser.website));
                    }
                }
            }
            if (!requestUserMap.isEmpty()){
                insert requestUserMap.values();
            } else{
                System.debug('requestUserMap is empty');
            }
            //Creating the map of exist Movie_Reviews__c for current Movie__c from movieReviewsList Key - User Email, Value - Movie_review__c
            Map<String, Movie_Review__c> existEmailReviewsMap = new Map<String, Movie_Review__c>();
            for (Movie_Review__c review_i : movieReviewsList){
                existEmailReviewsMap.put(review_i.Movie_Portal_User__r.Email__c, review_i);
            }


            for (String email_i : wrapperReviewsMap.keySet()){
                if (existEmailReviewsMap.containsKey(email_i)){
                    if (existEmailReviewsMap.get(email_i).Title__c != wrapperReviewsMap.get(email_i).name && existEmailReviewsMap.get(email_i).Body__c != wrapperReviewsMap.get(email_i).body){
                        Movie_Review__c tempReview = new Movie_Review__c(Movie__c = movieRecordId, Title__c = wrapperReviewsMap.get(email_i).name, Body__c = wrapperReviewsMap.get(email_i).body);

                        if (moviePortalUsersMap.containsKey(email_i)){
                            tempReview.Movie_Portal_User__c = moviePortalUsersMap.get(email_i).Id;
                        } else if (requestUserMap.containsKey(email_i)){
                            tempReview.Movie_Portal_User__c = requestUserMap.get(email_i).Id;
                        }
                        movieReviewToInsertList.add(tempReview);
                    }
                }
            }

            insert movieReviewToInsertList;

            /*
             [
             {
             "postId": 5,
             "id": 21,
             "name": "aliquid rerum mollitia qui a consectetur eum sed",
             "email": "Noemie@marques.me",
             "body": "deleniti aut sed molestias explicabo\ncommodi odio ratione nesciunt\nvoluptate doloremque est\nnam autem error delectus"
             },
             {
             "postId": 5,
             "id": 22,
             "name": "porro repellendus aut tempore quis hic",
             "email": "Khalil@emile.co.uk",
             "body": "qui ipsa animi nostrum praesentium voluptatibus odit\nqui non impedit cum qui nostrum aliquid fuga explicabo\nvoluptatem fugit earum voluptas exercitationem temporibus dignissimos distinctio\nesse inventore reprehenderit quidem ut incidunt nihil necessitatibus rerum"
             },
             {
             "postId": 5,
             "id": 23,
             "name": "quis tempora quidem nihil iste",
             "email": "Sophia@arianna.co.uk",
             "body": "voluptates provident repellendus iusto perspiciatis ex fugiat ut\nut dolor nam aliquid et expedita voluptate\nsunt vitae illo rerum in quos\nvel eligendi enim quae fugiat est"
             },
             {
             "postId": 5,
             "id": 24,
             "name": "in tempore eos beatae est",
             "email": "Jeffery@juwan.us",
             "body": "repudiandae repellat quia\nsequi est dolore explicabo nihil et\net sit et\net praesentium iste atque asperiores tenetur"
             },
             {
             "postId": 5,
             "id": 25,
             "name": "autem ab ea sit alias hic provident sit",
             "email": "Isaias_Kuhic@jarrett.net",
             "body": "sunt aut quae laboriosam sit ut impedit\nadipisci harum laborum totam deleniti voluptas odit rem ea\nnon iure distinctio ut velit doloribus\net non ex"
             }
             ]

             }
             }
             }
             */
        }
    }

    private static HttpResponse getRequest(String endPoint){
        Http httpObject = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        System.debug('requestEndPOINT: ' + request.getEndpoint());
        request.setMethod('GET');
        HttpResponse response = httpObject.send(request);
        return response;
    }

    class WrapperReview{
        public Integer postId;
        public Integer id;
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