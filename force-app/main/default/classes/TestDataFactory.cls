public with sharing class TestDataFactory {
    
    /**
     * @Testing function createCase
     * @param  caseOrigin caseOrigin 
     * @return            return 
     */ 
    @TestVisible
    private static Case createCase(String caseOrigin) {
        return new Case(Origin = caseOrigin, Subject = 'Event Booking', Description = 'Book Spots');
    }

    /**
     * @description createCaseWithAccount description
     * @param  caseOrigin       caseOrigin description
     * @param  numberOfContacts numberOfContacts description
     * @return                  return description
     */ 
    @TestVisible
    private static Case createCaseWithAccount(String caseOrigin, Integer numberOfContacts) {
        Account account = new Account(Name = 'Salesforce');
        if (Schema.sObjectType.Account.isCreateable()) {
            insert account;
        }
        
        createContacts(numberOfContacts, account);
        return new Case(Origin = caseOrigin, Subject = 'Event Booking', Description = 'Book Spots', AccountId = account.ID);
    }

    /**
     * @description createContacts description
     * @param  numberOfContacts numberOfContacts description
     * @param  account          account description
     */ 
    @TestVisible
    private static void createContacts(Integer numberOfContacts, Account account) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0;i<numberOfContacts;i++) {
            Contact contact = new Contact(LastName = 'Contact ' + i, AccountId = account.ID);
            contacts.add(contact);
        }
        if (Schema.sObjectType.Contact.isCreateable()) {
            insert contacts;
        }
        
    }
}