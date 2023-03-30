public with sharing class ReviewsController{
    @future(callout = true)@AuraEnabled
    public static void pullReviews(Id movieRecordId){
        List<Movie_Review__c> movieReviewList = [SELECT Id, External_Id__c, Movie_Portal_User__c, Movie_Portal_User__r.Email__c
                                                 FROM Movie_Review__c
                                                 WHERE Movie__c = :movieRecordId];

        for (Movie_Review__c movieReview_i : movieReviewList){

            List<Movie_Review__c> movieReviewToInsertList = new List<Movie_review__c>();
            List<Movie_Portal_User__c> portalUsersToInsertList = new List<Movie_Portal_User__c>();

            HttpResponse response = getRequest('https://jsonplaceholder.typicode.com/comments?postId=' + movieReview_i.External_Id__c);

            if (response.getStatusCode() == 200){
                System.debug('Inside Response');
                List<WrapperReview> resultList = (List<WrapperReview>)JSON.deserialize(response.getBody(), List<WrapperReview>.class);

                List<String> emailsList = new List<String>();
                for (WrapperReview review_i : resultList){
                    emailsList.add(review_i.email);
                }

                List<Movie_Portal_User__c> moviePortalUsers = [SELECT Id, Email__c
                                                               FROM Movie_Portal_User__c
                                                               WHERE Email__c IN:emailsList];
                Map<String, Id> emailUserMap = new Map<String, Id>();
                for (Movie_Portal_User__c user_i : moviePortalUsers){
                    emailUserMap.put(user_i.Email__c, user_i.Id);
                }


                for (WrapperReview review_i : resultList){
                    Movie_Review__c movieReview = new Movie_Review__c(Title__c = review_i.name, Body__c = review_i.body);

                    if (emailUserMap.containsKey(review_i.email)){
                        movieReview.Movie_Portal_User__c = emailUserMap.get(review_i.email);
                        movieReviewToInsertList.add(movieReview);
                    } else{
                        HttpResponse userResponse = getRequest('https://jsonplaceholder.typicode.com/users?email=' + review_i.email);
                        Map<String, sObject> responseMap = (Map<String, sObject>)JSON.deserializeUntyped(userResponse.getBody());

                    }
                }

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
                 */
            }
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

}