public with sharing class EmailValidationUtil{
    @future(callout = true)
    public static void checkEmailQuality(Set<Id> contactIdsSet){

        Map<Id, String> contactsEmailsMap = new Map<Id, String>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<String, Boolean> qualityEmailsResultMap = new Map<String, Boolean>();

        for (Contact contacts_i : [SELECT Id, Email
                                   FROM Contact
                                   WHERE Id IN:contactIdsSet]){
            contactsEmailsMap.put(contacts_i.Id, contacts_i.Email);
        }

        for (Id contactId_i : contactsEmailsMap.keySet()){
            qualityEmailsResultMap = callEmailValidationService(contactsEmailsMap.get(contactId_i));
            Boolean isDisposalEmail = qualityEmailsResultMap.get('is_disposable_email');
            Boolean isFreeEmail = qualityEmailsResultMap.get('is_free_email');

            contactsToUpdate.add(new Contact(Id = contactId_i, Is_Disposable_email__c = isDisposalEmail, Is_free_email__c = isFreeEmail));

        }
        update contactsToUpdate;
    }

    private static Map<String, Boolean> callEmailValidationService(String emailAddress){

        EmailQualityAPISetting__c apiSettings = EmailQualityAPISetting__c.getOrgDefaults();
        Map<String, Boolean> resultsMap = new Map<String, Boolean>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');

        request.setEndpoint(apiSettings.Endpoint__c + '/v1/?api_key=' + apiSettings.Key__c + '&email=' + emailAddress);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Boolean isDisposableEmail = (Boolean) ((Map<String, Object>)responseMap.get('is_disposable_email')).get('value');
            Boolean isFreeEmail = (Boolean) ((Map<String, Object>)responseMap.get('is_free_email')).get('value');
            resultsMap.put('is_disposable_email', isDisposableEmail);
            resultsMap.put('is_free_email', isFreeEmail);
        }

        return resultsMap;
    }

}