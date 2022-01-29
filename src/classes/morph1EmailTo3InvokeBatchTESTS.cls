/**
 * Created by Baird on 4/23/2021.
 */

@isTest
private with sharing class morph1EmailTo3InvokeBatchTESTS {

@IsTest
static void ContactBatchTest() {
        Account a = new Account(
                Name = 'TestAccount'
        );
        insert a;
        List<Contact> LCs = new List<Contact>();
        for (Integer i=0;i<50;i++){
        Contact c = new Contact(
                AccountId = a.id,
                LastName = 'Testcontact' + i,
                Personal_Email__c = 'personal@dontbotherme.org',
                Email = 'testcontact@dontbotherme.org',
                Work_Email__c = 'Work@dontbotherme.org');
        LCs.add(c);
}
system.assertEquals(50, LCs.size());
insert LCs;

morph1EmailTo3Batch m1E3 = new morph1EmailTo3Batch();
List<SObject> LSOb = new List<SObject>();
LCs = [SELECT Id from Contact];
for (Contact c : LCs) LSOb.add(c);
List<Lead> LLs = [SELECT Id from Lead];
for (Lead l : LLs) LSOb.add(l);

Test.startTest();
morph1EmailTo3InvokeBatchForContacts ME3 = new morph1EmailTo3InvokeBatchForContacts();
ME3.invokeBatch('SELECT Id from Contact');
Test.stopTest();

List<Contact> resultContacts = [SELECT Id, email, Personal_Email__c, Work_Email__c, Other_Email__c,
Preferred_Email__c from Contact WHERE LastName <> 'TestContact'];
system.assertEquals(50, resultContacts.size());
For (Contact c : resultContacts) {
system.assertEquals('Other', c.Preferred_Email__c, 'Should have stored Email in Other_Email, set Preferred to Other');
}
}


        @IsTest
        static void LeadBatchTest() {
                List<Lead> LCs = new List<Lead>();
                for (Integer i=0;i<50;i++){
                        Lead c = new Lead(
                                LastName = 'TestLead' + i,
                                Company = 'TestLead' + i + ' Household',
                                Personal_Email__c = 'personal@dontbotherme.org',
                                Email = 'testLead@dontbotherme.org',
                                Work_Email__c = 'Work@dontbotherme.org');
                        LCs.add(c);
                }
                system.assertEquals(50, LCs.size());
                insert LCs;

                morph1EmailTo3Batch m1E3 = new morph1EmailTo3Batch();
                List<SObject> LSOb = new List<SObject>();
                LCs = [SELECT Id from Lead];
                for (Lead c : LCs) LSOb.add(c);
                List<Lead> LLs = [SELECT Id from Lead];
                for (Lead l : LLs) LSOb.add(l);

                Test.startTest();
                morph1EmailTo3InvokeBatchForLeads ME3 = new morph1EmailTo3InvokeBatchForLeads();
                ME3.invokeBatch('SELECT Id from Lead');
                Test.stopTest();

                List<Lead> resultLeads = [SELECT Id, email, Personal_Email__c, Work_Email__c, Other_Email__c,
                        Preferred_Email__c from Lead WHERE LastName <> 'TestLead'];
                system.assertEquals(50, resultLeads.size());
                For (Lead c : resultLeads) {
                        system.assertEquals('Other', c.Preferred_Email__c, 'Should have stored Email in Other_Email, set Preferred to Other');
                }
        }

}