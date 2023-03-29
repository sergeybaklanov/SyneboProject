@IsTest
public with sharing class EmailValidationUtilTest{
    @TestSetup
    static void makeData(){
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 10; i++){
            contactList.add(new Contact(LastName = 'Contact' + i, Email = 'Contact' + i + '@gmail.com'));
        }
        insert contactList;
    }

    @isTest
    public static void checkEmailQualityTest(){

        //Create and macke fake response callout
        Test.setMock(HttpCalloutMock.class, new EmailValidationMock());

        Map<Id, Contact> contactsMap = new Map<Id, Contact>((List<Contact>)[SELECT Id, Name
                                                                             FROM Contact]);
        Test.startTest();
        EmailValidationUtil.checkEmailQuality(contactsMap.keySet());
        Test.stopTest();

        List<Contact> contactResultsList = [SELECT Id, Name, Is_Disposable_email__c, Is_free_email__c
                                            FROM Contact];

        for (Contact contact_i : contactResultsList){
            System.assertEquals(true, contact_i.Is_Disposable_email__c);
            System.assertEquals(false, contact_i.Is_free_email__c);
        }
    }
}