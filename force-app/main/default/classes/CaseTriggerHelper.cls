public with sharing class CaseTriggerHelper {

    /**
     * @description validateCasesBeforeInsert description
     * @param  newList newList description
     */
    public static void validateCasesBeforeInsert(List<Case> newList) {
        Map<Id, Account> relatedAccounts = getRelatedAccounts(newList);
        for (Case currentCase : newList) {
            Account account = relatedAccounts.get(currentCase.AccountId);
            if (account != null) {
                Integer numberOfContacts = account.Contacts.size();
                if (numberOfContacts == 0) {
                    currentCase.addError('You cannot create a request for accounts without contacts');
                } else if(currentCase.Origin == 'Web' && numberOfContacts >= 2) {
                    currentCase.addError('Web request are only allowed to have one attendee');
                } else if(currentCase.Origin == 'Phone' && numberOfContacts >= 4) {
                    currentCase.addError('Phone request are only allowed to have three attendee');
                }
            } else {
                currentCase.addError('You cannot create a request without attaching an account');
            }
        }
    }
    
    /**
     * @description registerAttendeesBeforeUpdate
     * @param  newMap newMap
     */
    public static void registerAttendeesBeforeUpdate(Map<Id, Case> newMap) {
        SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE,
         [SELECT AccountId, Status FROM Case where Id IN :newMap.keySet() WITH SECURITY_ENFORCED]);

        List<Case> cases = securityDecision.getRecords();
        for (Case currentCase : cases) {
            if(currentCase.Status == 'Closed'){
                ExternalSystemService service = new ExternalSystemService();
                service.registerAttendees(currentCase);
            }
        }
    }

    /**
     * @description getRelatedAccounts
     * @param  cases cases description
     * @return       return description
     */
    private static Map<Id, Account> getRelatedAccounts(List<Case> cases) {
        Set<Id> accountIds = new Set<Id>();
        for (Case currentCase : cases) {
            accountIds.add(currentCase.AccountId);
        }
        SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE,
         [SELECT Id, (select Id from contacts) FROM Account where Id IN :accountIds WITH SECURITY_ENFORCED]);
        
        return new Map<Id, Account>((List<Account>)securityDecision.getRecords());
    }
}