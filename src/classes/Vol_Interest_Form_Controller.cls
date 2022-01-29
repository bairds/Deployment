/**
 * Created by Baird on 5/9/2021.
 */
global class Vol_Interest_Form_Controller {

    public Vol_Interest_Form_Controller(ApexPages.StandardController Controller) {
        this.pcontact=(Contact)Controller.getRecord();
        interestselection = new List<String>{};
        skillselection = new List<String>{};
    }

    public Contact pcontact {get; Set;}
    public List<String> interestselection {get; Set;}
    public List<String> skillselection {get; Set;}

    Public ID sID {get; set;}
    Public string stype;
    public lead tempLead {get; set;}
    public contact tempContact {get; set;}
    public List<String> results {get; set;}


    public PageReference submit(){
        String[] sresults = identifyorcreatePerson.IdentifyOrCreatePerson(pContact);
        sID = sresults[0];
        stype = sresults[1];
        system.debug('results is ' + sresults);
        system.debug('stype is ' + stype);
        if (stype=='Contact') {
            tempContact = [select id, firstname, lastname, phone, mailingStreet, mailingCity, mailingState,
                    MailingPostalCode, email, Mailing_Lists__c from contact where id = :sID];
            tempContact.email = pcontact.email;
            tempContact.volunteer_interests__c = String.join(interestselection,';');
            tempContact.volunteer_skills__c = String.join(skillselection,';');
            update tempContact;
        }
        else {
            if (stype=='Lead') {
                tempLead = [select id, firstname, lastname, PostalCode, email, Mailing_Lists__c from lead where id = :sID];
                templead.email = pcontact.email;
                tempLead.volunteer_interests__c = String.join(interestselection,';');
                tempLead.volunteer_skills__c = String.join(skillselection,';');
                update tempLead;
            }
        } // END ELSE CHECK IF STYPE = LEAD */
        PageReference Thanks_Page = Page.Volunteer_Interest_ThankYou;
        Thanks_Page.setRedirect(false);
        return Thanks_Page;
        //return null;

    }

    public List<SelectOption> getInterests() {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    } // end getInterests

    public List<SelectOption> getSkills() {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : Contact.Volunteer_Skills__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    } // end getSkills



}