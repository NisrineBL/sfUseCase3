public without sharing class ExternalSystemService {
    /**
     * @description retreive accounts and send them to the ExternalSystemCallout class.
     * @param handledCase Handled case
     */
    public void registerAttendees(Case handledCase){
        SObjectAccessDecision securityDecisionAccounts = 
         Security.stripInaccessible(AccessType.READABLE,
         [SELECT id FROM Account where id = :handledCase.AccountId WITH SECURITY_ENFORCED]);

        List<Account> accounts = securityDecisionAccounts.getRecords();
        Set<Id> accountIdsSet = (new Map<Id,SObject>(accounts)).keySet();
        
        ExternalSystemCallout.makeCallout(accountIdsSet, handledCase.Id);
    } 
}