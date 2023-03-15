/**
 * ExternalSystemCallout class performs an HTTP POST callout to an external service using a given list of Contact records.
 * If the callout returns a successful response (HTTP status code 201), it creates a Task to send an email to each Contact.
 * @see Contact
 * @see Task
 */
public without sharing class ExternalSystemCallout {
   
    /**
     * @description makeCallout description
     * @param  accountIdsSet accountIdsSet description
     * @param  handledCaseId handledCaseId description
     */
    @future(callout=true)
    public static void makeCallout(Set<Id> accountIdsSet, Id handledCaseId) {
        SObjectAccessDecision securityDecisionContacts = 
         Security.stripInaccessible(AccessType.READABLE,
         [SELECT id,name, email, AccountId FROM Contact where accountid IN : accountIdsSet]);

        List<Contact> contactList = securityDecisionContacts.getRecords();

        for(Contact contact: contactList) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ExternalServiceUrl/animals');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');    
            // Set the body as a JSON object
            request.setBody('{"name":"'+ contact.name + '-' + contact.email  +'"}');
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 201) {
                Logger.error('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                // Everything went as expected.
                notifyAttendeeByEmail(contact, handledCaseId);
            }
        }
    }

    /**
     * notifyAttendeeByEmail() creates a new Task for the given Contact and sends an email to the Contact.
     * The Task's subject is 'Send Email To [Contact Name]', and it is associated with the Contact's Account.
     * The email subject is 'Case Closed', and the body includes a link to the Case that is associated with the email.
     * If the Task cannot be created, no email is sent.
     * @param contact The Contact record to create the Task and send the email to
     * @param handledCaseId ID of the Case that was handled and is associated with the email to be sent
     * @see Contact
     * @see Task
     */
    public static void notifyAttendeeByEmail(Contact contact, Id handledCaseId){
        if(!Schema.sObjectType.Task.isCreateable()){
            return;
        }
        Task task = new Task();
        task.Subject = 'Send Email To' + contact.name;
        task.Status = 'Open';
        task.Priority = 'Normal';
        task.WhoId = contact.Id;
        task.WhatId = contact.AccountId;
        insert task;
        sendMail(contact.email, handledCaseId);
    } 

    public static void sendMail(String contactEmail, Id caseId) {
        // getting domain url
        String caseLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseId;
        // reserve email capacity for the current Apex transaction
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {contactEmail};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Case Closed');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('Your case: <b> ' + caseId +' </b> has been closed. <p>'+
     'To view your case <a href='+caseLink+'>click here.</a>');  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}