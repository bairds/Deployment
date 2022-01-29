/**
 * Created by Baird on 6/5/2020.
 */

@isTest
private with sharing class morph1EmailTo3TEST {

    // One SFEmail, One WGEmail. Does SFEmail go into different WGEmail?
    // and preferred is set to it.
    @IsTest
    static void OneSFEmail() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        system.debug('ResultCtcts is ' + ResultCtcts);
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('testcontact@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
            // system.assertEquals('testcontact@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    @IsTest
    static void OneSFEmailFromWorkAccount() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestBusinessContact();
        // Contact TestContact = ctv.fetchTestContact();
        TestContact.Preferred_Email__c=null;
        // TestContact.Personal_Email__c=null;
        Update Testcontact;
        Contact ConfirmTestContact = [
                SELECT Firstname, Lastname, Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,
                        Work_Email__c,Preferred_Email__c,Legacy_Emails__c,Account.RecordType.DeveloperName
                FROM Contact
                where Id = :TestContact.Id];
        System.debug('ConfirmTestContact.Preferred_Email__c is '+ ConfirmTestContact.Preferred_Email__c);
        System.debug('ConfirmTestContact.Personal_Email__c is '+ ConfirmTestContact.Personal_Email__c);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        system.debug('ResultCtcts is ' + ResultCtcts);
        For (Contact c : ResultCtcts) {
            system.assertEquals('testbusinesscontact@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Personal_Email__c);
            system.assertEquals('testbusinesscontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
            // system.assertEquals('testbusinesscontact@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    // One SFEmail, one WGEmail (Personal_Email__c). Does SFEmail go into Work_Email__c?
    // and preferred is set to Work
    @IsTest
    static void SFEmailWGEmailNoPreferred1() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
            // system.assertEquals('testcontact@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    // One SFEmail, two WGEmail (Personal_Email__c and Work_Email__c). Does SFEmail go into Other_Email__c?
    // and Is Preferred is set to Other?
    @IsTest
    static void SFEmailWGEmailNoPreferred2() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
            // system.assertEquals('testcontact@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    // One SFEmail, two WGEmail (Personal_Email__c and Work_Email__c). Does SFEmail go into Other_Email__c?
    // and Is Preferred is set to Other?
    @IsTest
    static void SFEmailAllWGEmailsNoPreferred() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals(null, c.Preferred_Email__c);
            // system.assertEquals('testcontact@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferred1() {
WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = '';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferred2() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = '';
        Testcontact.Other_Email__c = 'Other@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('other@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferredWork() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = '';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void SFEmailMatchWGEmailNoPreferred1() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = 'Other@dontbotherme.org';
        Testcontact.Other_Email__c = 'Other@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('other@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
            // system.assertEquals('other@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    @IsTest
    static void SFEmailMatchWGEmailNoPreferred2() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = 'work@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'Other@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
            // system.assertEquals('work@dontbotherme.org,', c.Legacy_Emails__c);
        }
    }

    @IsTest
    static void SFEmailNoWGEmailPreferred1() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Work';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('testcontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
            system.assertEquals(null, c.Legacy_Emails__c);
        }
    }

    // Preferred exists but is not set to one of the existing wGEmail fields;
    // SFEmail should populate the Preferred field
    @IsTest
    static void SFEmailWGEmailPreferred() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'Work@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Other';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
            system.assertEquals(null, c.Legacy_Emails__c);
        }
    }

    // Preferred exists and is set to one of the existing wGEmail fields;
    // SFEmail should populate the Preferred field
    @IsTest
    static void SFEmailWGEmailPreferred2() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'Work@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Personal';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('personal@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
            system.assertEquals(null, c.Legacy_Emails__c);
        }
    }
    // SFEmail doesn't match Preferred Email; SFEmail goes into Legacy_Emails__c and Personal_Email goes into Email.
    @IsTest
    static void SFEmailWGEmailMatchesPreferred() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'Work@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Personal';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        List<Contact> ResultCtcts = [SELECT Email,Last_Email_Overwrite__c,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        SYSTEM.DEBUG('Before calling arrangeEmails() ResultCtcts is ' + ResultCtcts);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        For (Contact c : ResultCtcts) {
            system.assertEquals('personal@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
            system.assertEquals(null, c.Legacy_Emails__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals(date.today(), c.Last_Email_Overwrite__c.date());
            system.debug(c.Last_Email_Overwrite__c);
        }
    }

    @IsTest
    static void BatchTest() {
        Account a = new Account(
                Name = 'TestAccount'
        );
        insert a;
        List<Contact> LCs = new List<Contact>();
        for (Integer i=0;i<50;i++){
            Contact c = new Contact(
                    AccountId = a.id,
                    LastName = 'Testcontact'+i,
                    Personal_Email__c = 'personal@dontbotherme.org',
                    Email = 'testcontact@dontbotherme.org',
                    Work_Email__c = 'Work@dontbotherme.org');
            LCs.add(c);
        }
        system.assertEquals(50,LCs.size());
        insert LCs;

        morph1EmailTo3Batch m1E3 = new morph1EmailTo3Batch();
        List<SObject> LSOb = new List<SObject>();
        LCs = [SELECT Id from Contact];
        for (Contact c : LCs) LSOb.add(c);

        Test.startTest();
        morph1EmailTo3InvokeBatchForContacts ME3 = new morph1EmailTo3InvokeBatchForContacts();
        ME3.invokeBatch('SELECT Id from Contact');
        Test.stopTest();

        List<Contact> resultContacts = [SELECT Id, email, Personal_Email__c, Work_Email__c, Other_Email__c,
        Preferred_Email__c from Contact WHERE LastName<>'TestContact'];
        system.assertEquals(50,resultContacts.size());
        For (Contact c : resultContacts) {
            system.assertEquals('Other',c.Preferred_Email__c,'Should have stored Email in Other_Email, set Preferred to Other');
        }
    }


    @IsTest
    static void DuplicateLegacyEmail() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BManageContactEmails = false;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestBusinessContact();
        // Contact TestContact = ctv.fetchTestContact();
        TestContact.Preferred_Email__c=null;
        TestContact.Legacy_Emails__c='testbusinesscontact@dontbotherme.org,';
        Update Testcontact;
        Contact ConfirmTestContact = [
                SELECT Firstname, Lastname, Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,
                        Work_Email__c,Preferred_Email__c,Legacy_Emails__c,Account.RecordType.DeveloperName
                FROM Contact
                where Id = :TestContact.Id];
        System.debug('ConfirmTestContact.Preferred_Email__c is '+ ConfirmTestContact.Preferred_Email__c);
        System.debug('ConfirmTestContact.Personal_Email__c is '+ ConfirmTestContact.Personal_Email__c);
        List<Id> CLIds = new List<Id>();
        CLIds.add(TestContact.Id);
        morph1EmailTo3 M1E3 = new morph1EmailTo3();
        M1E3.arrangeEmails(CLIds);
        List<Contact> ResultCtcts = [SELECT Email,Other_Email__c,Personal_Email__c,Work_Email__c,Preferred_Email__c,Legacy_Emails__c from Contact where Id in:CLIds];
        system.assertEquals(1, resultCtcts.size(), 'Should have returned only the one test contact.');
        system.debug('ResultCtcts is ' + ResultCtcts);
        For (Contact c : ResultCtcts) {
            system.assertEquals('testbusinesscontact@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Personal_Email__c);
            system.assertEquals('testbusinesscontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
            system.assertEquals('testbusinesscontact@dontbotherme.org,', c.Legacy_Emails__c,'Should not have inserted a new email because the newly inserted legacy email was a duplicate.');
        }
    }
}