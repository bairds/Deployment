/**
 * Created by Baird on 9/26/2020.
 */

public with sharing class sendVolPortalLink {
    public string SiteURL { get; set; }
    public Contact ctct { get; set; }
    public string SendStatus {get; set;}


    public sendVolPortalLink(ApexPages.StandardController stdController) {
        // ctct = (Contact) stdController.getRecord();
        Ctct = [SELECT Id, FirstName, LastName,VolToken__c
                from Contact
                WHERE Id = :stdController.getRecord().Id
        ];
        List<Site> SignupSites;
        SignupSites = [SELECT Subdomain, UrlPathPrefix FROM Site where name = 'SignUp'];
        if (SignupSites.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not find a Site named SignUp.'));
        } else {
            SiteURL = 'https://' + SignupSites[0].Subdomain + '.secure.force.com/VolPortal?cid=' +
                    Ctct.Id + '&VToken=' + Ctct.VolToken__c;
        }
    }


    public PageReference sendVolPortalLink() {Ctct.VolToken__c = WGHelpers.getVolToken();
        update Ctct;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(ctct.id);
        message.setSenderDisplayName('Volunteer Support');
        message.setReplyTo(String.ValueOf(UserInfo.getUserEmail()));
        message.setBccSender(true);
        message.setSaveAsActivity(true);
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,
                HtmlValue,DeveloperName,Body FROM EmailTemplate
        where name = 'VolPortalLinkFromOrganizer'];
        message.setTemplateID(emailTemplate.Id);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                message
        };
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
            SendStatus = 'Sent';
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
            SendStatus = 'Not sent. Error was ' + results[0].getErrors()[0].getMessage();
        }
        return null;
    }
}