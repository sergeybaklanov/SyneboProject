public with sharing class ContactTriggerHandler extends TriggerHandler {
    
    protected override void afterInsert(){
        this.countNumberOfContacts((List<Contact>)Trigger.new, null);
    }
    
    protected override void afterUpdate(){
        this.countNumberOfContacts((List<Contact>)Trigger.new, (Map<Id, Contact>)Trigger.oldMap);
    }
    
    protected override void afterDelete(){
        this.countNumberOfContacts(null, (Map<Id, Contact>)Trigger.oldMap);
    }
    
    protected override void afterUndelete(){
        this.countNumberOfContacts((List<Contact>)Trigger.new, null);
    }
    
    // Custom roll-up based on aggregate query (preferred in most cases)
    private void countNumberOfContacts(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id, Integer> accountIdToNumOfContactsMap = new Map<Id, Integer>();
        List<Account> accountsToUpdateList = new List<Account>();
        
        // Define a list to process. Remember that Trigger.new is null on Delete
        List<Contact> contactsToProcessList = (!Trigger.isDelete)
                                            ? newList
                                            : oldMap.values();
        
        // Define Accounts to update
        for (Contact contact_i : contactsToProcessList) {
            
            // Number of Contacts related to Account is changed on Insert, Delete, Undelete
            if ((Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) && contact_i.AccountId != null) {
                accountIdToNumOfContactsMap.put(contact_i.AccountId, 0);
            }
            
            // Number of Contacts related to Account is also changed on Account update. 
            // Notice that if account is replaced with another one > you need to update both
            if (Trigger.isUpdate && contact_i.AccountId != oldMap.get(contact_i.Id).AccountId) {
                if (contact_i.AccountId != null) {
                    accountIdToNumOfContactsMap.put(contact_i.AccountId, 0);
                }
                if (oldMap.get(contact_i.Id).AccountId != null) {
                    accountIdToNumOfContactsMap.put(oldMap.get(contact_i.Id).AccountId, 0);
                }
            }
        } 
        if (accountIdToNumOfContactsMap.isEmpty()) {
            return;
        }
        
        // Remember to check that Set / List used in a SOQL is not empty.
        // Otherwise SOQL will not return any row but it will be counted in limits.
        List<AggregateResult> aggResList = [
            SELECT COUNT(Id) contactsCount, AccountId
            FROM Contact
            WHERE AccountId IN :accountIdToNumOfContactsMap.keySet()
            GROUP BY AccountId
        ];
        if (!aggResList.isEmpty()) {
            for (AggregateResult result_i : aggResList) {
                if (accountIdToNumOfContactsMap.containsKey((Id)result_i.get('AccountId'))) {
                    accountIdToNumOfContactsMap.put((Id)result_i.get('AccountId'), (Integer)result_i.get('contactsCount'));
                }
            }
        }
        for (Id accountId_i : accountIdToNumOfContactsMap.keySet()) {
            accountsToUpdateList.add(
                new Account(
                    Id = accountId_i,
                    Number_of_contacts__c = accountIdToNumOfContactsMap.get(accountId_i)
                )
            );
        }
        update accountsToUpdateList;
    }
}