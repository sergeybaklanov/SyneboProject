public with sharing class AccountProcessor {
    @future
 public static void  countContacts(Set<Id> accountIdSet){
    List<Account> accountList = [SELECT Id, Number_Of_Contacts__c, (SELECT ID FROM Contacts)
                                    FROM Account
                                    WHERE Id IN : accountIdSet
                                    ];

 for(Account account_i : accountList){
    account_i.Number_Of_Contacts__c=account_i.Contacts.size(); 
    }
update accountList;
 }
}