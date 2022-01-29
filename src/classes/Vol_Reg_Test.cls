// Baird, 9 Jan 2014 w help from Jaspreet
@isTest
private class Vol_Reg_Test {
 
public static testMethod void VRT_New_Lead() {
WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

    //Find values in the Volunteer Interests global picklist
    List<String> VolInterests = new List<String>();
    Schema.sObjectType sObjType = Contact.getSObjectType();
    Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
    Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
    List<Schema.PicklistEntry> picklistValues = sObjFields.get('Volunteer_Interests__c').getDescribe().getPickListValues();
    for (Schema.PicklistEntry entry : picklistValues) {
        VolInterests.add(entry.getLabel());
    }

    //Find values in the Volunteer Skills global picklist
    List<String> VolSkills = new List<String>();
    sObjType = Contact.getSObjectType();
    sObjResult = sObjType.getDescribe();
    sObjFields = sObjResult.fields.getMap();
    picklistValues = sObjFields.get('Volunteer_Skills__c').getDescribe().getPickListValues();
    for (Schema.PicklistEntry entry : picklistValues) {
        VolSkills.add(entry.getLabel());
    }

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up a new lead
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.SelectedInterests = new List<String>();
    VRC.SelectedInterests.add(VolInterests[0]);
    VRC.SelectedInterests.add(VolInterests[1]);
    VRC.SelectedSkills = new List<String>();
    VRC.SelectedSkills.add(VolSkills[0]);
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;

    VRC.setSelectedInterests(VRC.SelectedInterests);
    VRC.setSelectedSkills(VRC.SelectedSkills);
VRC.submit();
Lead testlead = [select firstname, lastname, company, street, city, state, postalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Lead where email = 't@tester.com'];    
system.assertEquals('Test',testlead.firstname);
    system.assert(testlead.Volunteer_Interests__c.CONTAINS(VolInterests[0]));
    system.assert(testlead.Volunteer_Interests__c.CONTAINS(VolInterests[1]));
    system.assertEquals(VolSkills[0],testlead.Volunteer_Skills__c);
} // end testmethod
 
public static testMethod void VRT_New_Lead_No_Company() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up a new lead
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    // VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.pcontact.volunteer_interests__c = 'Tree Planting';
    VRC.pcontact.Volunteer_Skills__c = 'Fundraising';
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;
    
VRC.submit();
Lead testlead = [select firstname, lastname, company, street, city, state, postalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Lead where email = 't@tester.com'];    
system.assertEquals('Test',testlead.firstname);    
system.assertEquals('none',testlead.company);
} // end testmethod

     
public static testMethod void VRT_Contact_By_Email() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    testctct.email = 't@tester.com';
    update testctct;
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up existing contact with new information
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.pcontact.volunteer_interests__c = 'Tree Planting';
    VRC.pcontact.Volunteer_Skills__c = 'Fundraising';
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;
    
VRC.submit();
Contact testcontact = [select firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Contact where email = 't@tester.com'];    
system.assertEquals('TestContact',testcontact.lastname);
system.assertEquals('TT Mailing Street',testcontact.MailingStreet);
system.assertEquals(true,testcontact.Over_18__c);
    
// Invoke ReturnToList()
    VRC.returnToList();
    }

    public static testMethod void VRT_Lead_By_Email() {
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    Lead testlead = ctv.fetchTestLead();
    testlead.email = 't@tester.com';
    update testlead;
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

        // Identify the existing Volunteer Interests
        List<SelectOption> LSOs = WGHelpers.getPicklistEntries('Contact','Volunteer_Interests__c');
        system.debug('LSOs is 0' + LSOs);
        List<String> LabelStrings = new List<String>();
        for (SelectOption SO : LSOs) {
            LabelStrings.add(SO.getLabel());
        }
        system.debug('List of labels is ' + LabelStrings);

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up existing contact with new information
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.pcontact.volunteer_interests__c = LabelStrings[0];
    VRC.pcontact.Volunteer_Skills__c = 'Fundraising';
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;
    
VRC.submit();
Lead testld = [select firstname, lastname, Street, City, State, PostalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Lead where email = 't@tester.com'];    
system.assertEquals('TestLead',testld.lastname);
system.assertEquals('TT Mailing Street',testld.Street);
system.assertEquals(true,testld.Over_18__c);

    }

     
public static testMethod void VRT_Contact_By_NameZip() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    testctct.firstname = 'Test';
    testctct.lastname = 'Tester';
    testctct.MailingPostalCode = '55555';
    update testctct;
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up existing contact with new information
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.pcontact.volunteer_interests__c = 'Tree Planting';
    VRC.pcontact.Volunteer_Skills__c = 'Fundraising';
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;
    
VRC.submit();
Contact testcontact = [select firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Contact where firstname='Test' and lastname='Tester' and MailingPostalCode='55555'];    
system.assertEquals('Tester',testcontact.lastname);
system.assertEquals('TT Mailing Street',testcontact.MailingStreet);
system.assertEquals(true,testcontact.Over_18__c);
    }
    
    
    public static testMethod void VRT_Lead_By_NameZip() {
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.Vol_Reg_Page;
    Test.setCurrentPage(pageRef);
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account testacct = ctv.fetchTestAccount();
    Contact testctct = ctv.fetchTestContact();
    Lead testlead = ctv.fetchTestLead();
    testlead.firstname = 'Test';
    testlead.lastname = 'Tester';
    testlead.PostalCode = '55555';
    update testlead;
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);

    ApexPages.StandardController sc = new ApexPages.StandardController(Testctct);
    Vol_Reg_Controller VRC = new Vol_Reg_Controller(sc);
    pageRef = Page.Vol_Reg_Page;
        Test.setCurrentPage(pageRef);
    VRC.getpContact();
        
//  Sign up existing contact with new information
    VRC.pcontact.firstname = 'Test';
    VRC.pcontact.lastname = 'Tester';
    VRC.pcontact.email = 't@tester.com';
    VRC.Company = 'Test Company';
    VRC.pcontact.MailingStreet = 'TT Mailing Street';
    VRC.pcontact.MailingCity = 'TT Mailing City';
    VRC.pcontact.MailingState = 'TT Mailing State';
    VRC.pcontact.MailingPostalCode = '55555';
    VRC.pcontact.Phone = '333-3333';
    VRC.HowHeardAbout = 'How I heard about HRWC';
    VRC.pcontact.volunteer_interests__c = 'Tree Planting';
    VRC.pcontact.Volunteer_Skills__c = 'Fundraising';
    VRC.Comments = 'Questions or comments for HRWC';
    VRC.pcontact.Over_18__c = true;
    VRC.enewsletters = true;
    
VRC.submit();
Lead testld = [select firstname, lastname, Street, City, State, PostalCode,
                 Phone, Description, Volunteer_Interests__c, Volunteer_Skills__c,
                 Over_18__c from Lead where firstname='Test' and lastname='Tester' and PostalCode='55555'];    
system.assertEquals('Tester',testld.lastname);
system.assertEquals('TT Mailing Street',testld.Street);
system.assertEquals(true,testld.Over_18__c);
    } // end testmethod
} // end test