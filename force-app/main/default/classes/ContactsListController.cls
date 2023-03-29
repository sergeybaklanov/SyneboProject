public with sharing class ContactsListController {
    /*
    public List<Contact> contactsList { get; set; }
    
    public ContactsListController() {
        this.contactsList = [
            SELECT Id, FirstName, LastName, Title, Email
            FROM Contact
            LIMIT 10
        ];
    }
    */
     
    private String sortOrder = 'LastName';
    public List<Contact> getContactsList() {
        List<Contact> results = Database.query(
            'SELECT Id, FirstName, LastName, Title, Email ' +
            'FROM Contact ' +
            'ORDER BY ' + sortOrder + ' ASC ' +
            'LIMIT 10'
        );
        return results;
    }
    
    public ContactsListController() {
        
    }
    
    public void sortByLastName() {
        this.sortOrder = 'LastName';
    }
    public void sortByFirstName() {
        this.sortOrder = 'FirstName';
    }
}