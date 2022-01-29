// From EllerbeCreek on 5/9/2021
// Needed for the EllerbeCreek deployment
// But for other groups superseded by the volunteer portal

@isTest
private class Vol_Interest_Form_Test {

    @isTest
    static void ExistingContactTest() {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        String testoption = options[0].getLabel();

        Create_Test_Variables ctv = new Create_Test_Variables();
        Account testacct = ctv.fetchTestAccount();
        Contact testctct = ctv.fetchTestContact();
        Contact pcontact = new Contact();
        pageReference pageRef = Page.Vol_Interest_Form;
        ApexPages.StandardController ct = new ApexPages.StandardController(pcontact);
        Vol_Interest_Form_Controller VIFC1 = new Vol_Interest_Form_Controller(ct);
        pcontact.FirstName = 'Test';
        pcontact.LastName = 'TestContact';
        pcontact.Email = 'testcontact@dontbotherme.org';
        VIFC1.interestselection.add(testoption);
        VIFC1.skillselection.add(testoption);
        VIFC1.getInterests();
        VIFC1.getSkills();
        string nextPage = VIFC1.submit().getURL();
        System.assertEquals(testoption,[select id, volunteer_interests__c from Contact where id = :testctct.id].volunteer_interests__c);
        System.assertEquals('/apex/volunteer_interest_thankyou',nextpage);
    } // endof ExistingContactTest

    static testMethod void ExistingLeadTest() {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        String testoption = options[0].getLabel();
        Create_Test_Variables ctv = new Create_Test_Variables();
        Lead testlead = ctv.fetchTestLead();
        Contact pcontact = new Contact();
        pageReference pageRef = Page.Vol_Interest_Form;
        ApexPages.StandardController ct = new ApexPages.StandardController(pcontact);
        Vol_Interest_Form_Controller VIFC2 = new Vol_Interest_Form_Controller(ct);
        VIFC2.interestselection.add(testoption);
        VIFC2.skillselection.add(testoption);
        pcontact.Email = 'testlead@dontbotherme.org';
        pcontact.LastName = 'TestLead';
        pcontact.FirstName = 'Lead';
        VIFC2.submit();
        System.assertEquals(testoption,[select id, volunteer_interests__c from Lead where id = :testlead.id].volunteer_interests__c);
    } // endof ExistingContactTest


    static testMethod void NewLeadTest() {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        String testoption = options[0].getLabel();
        Contact pcontact = new Contact();
        pageReference pageRef = Page.Vol_Interest_Form;
        ApexPages.StandardController ct = new ApexPages.StandardController(pcontact);
        Vol_Interest_Form_Controller VIFC3 = new Vol_Interest_Form_Controller(ct);
        VIFC3.interestselection.add(testoption);
        VIFC3.skillselection.add(testoption);
        pcontact.Email = 'testlead@dontbotherme.org';
        pcontact.LastName = 'testlead';
        VIFC3.submit();
        System.assertEquals(testoption,[select id, volunteer_interests__c from Lead where email = 'testlead@dontbotherme.org'][0].volunteer_interests__c);
    } // endof ExistingContactTest

}