@IsTest
public with sharing class HelloWorldTest {
    @isTest
    private static void createAccontTest(){

        String accountName='Google';

        Account newAccount = HelloWorld.createAccout(accountName);

        newAccount  = [SELECT Id, Name FROM Account WHERE id=:newAccount.Id];

        System.system.assertEquals(accountName, newAccount.Name,'Something wrong with the new account');

    }

}