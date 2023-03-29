@IsTest
public with sharing class AccountProcessorTest {
 
    @IsTest
    private static void countContactsTest(){
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Name FROM Account]);

        Test.startTest();

        AccountProcessor.countContacts(accountMap.keySet());

        Test.stopTest();

        //assert results
    }
}