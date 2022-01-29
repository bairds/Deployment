/**
 * Created by Baird on 7/18/2020.
 * Revised Apr 29 2021 to avoid error in MultipleChangesToAccount test,
 * where the address assigned to one GUU was being passed to all contacts
 * because the GUU updated a contact which was not protected and hence
 * updated the account and the account pushed the new address to all contacts.
 * Now the test creates separate accounts for the contacts.
 */

@IsTest
private class approveGuestUserEditsTEST {
    @TestSetup
    static void setupGUUs(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        Id UnknownCampId = WGHelpers.getUnknownCampaignId();
        List<Contact> ListCtcts = new List<Contact>();
        For (integer i=0;i<9;i++) {
            Contact Ctct = new Contact(
                    FirstName = 'TestGUU',
                    LastName = 'Tester' + i,
                    Email = 'test' + i + '@tester.com',
                    AccountId = TestAccount.Id
            );
            ListCtcts.add(Ctct);
        }
        Insert ListCtcts;
        List<GuestUserUpdate__c> ListGUUs = new List<GuestUserUpdate__c>();
        For (integer i=0;i<9;i++){
            GuestUserUpdate__c newGUU = new GuestUserUpdate__c(
                    FirstName__c='Test',
                    LastName__c='Tester'+i,
                    Email__c='test'+i+'@tester.com',
                    Processing_Status__c='Review',
                    RelatedContact__c=ListCtcts[i].Id
            );
            ListGUUs.add(newGUU);
        }
        // One of the nine should not appear in the list
        // because it is set to rejected
        ListGUUs[8].Processing_Status__c='Rejected';
        ListGUUs[0].Email__c='ChangedTest8@tester.com';
        insert ListGUUs;
        List<Opportunity> ListOpps = new List<Opportunity>();
        For (integer i=0;i<9;i++){
            Opportunity newOpp = new Opportunity(
                    Contact__c=ListCtcts[i].Id,
                    Description='Description of work',
                    Hours_Actual__c=2,
                    StageName='Task Submitted',
                    CloseDate=system.today(),
                    AccountId = TestAccount.Id,
                    CampaignId = UnknownCampId,
                    Name = 'VolTask'+i
            );
            ListOpps.add(newOpp);
        }
        ListOpps[8].StageName='Task Rejected';
        insert ListOpps;
    }
    @IsTest
    static void processAll() {
        WGHelpers.BManageContacts=true;
        PageReference pageRef = Page.ApproveGuestUserEdits;
        Test.setCurrentPage(pageRef);
        approveGuestUserEdits AMGE = new approveGuestUserEdits();
        system.assertEquals(8,AMGE.GUUs.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AMGE.GUUs[1].Processing_Status__c = 'Rejected';
        AMGE.GUUs[0].MailingStreet__c = 'New Mailing Street #111';
        AMGE.submitEdits();
        List<Contact> Results = [SELECT AccountId from Contact where email = 'ChangedTest8@tester.com'];
        system.AssertEquals(1,results.size(),'Should have found one Contact with a changed email.');
        Results = [SELECT AccountId, Account.BillingStreet, Contact.MailingStreet, LastName, FirstName from Contact
        WHERE LastName LIKE 'Tester%'];
        system.debug('Results is ' + Results);
        system.AssertEquals('New Mailing Street #111',Results[0].Account.BillingStreet,'Should have changed Account Address.');
    }

    @IsTest
    static void protectedAccountAddress() {
        WGHelpers.BManageContacts=true;
        PageReference pageRef = Page.ApproveGuestUserEdits;
        Test.setCurrentPage(pageRef);
        approveGuestUserEdits AMGE = new approveGuestUserEdits();
        system.assertEquals(8,AMGE.GUUs.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AMGE.GUUs[1].Processing_Status__c = 'Rejected';
        AMGE.GUUs[2].MailingStreet__c = 'New Mailing Street #111';
        // Protect the contact from account address changes, and vice versa
        AMGE.CtctMap.get(AMGE.GUUs[2].RelatedContact__c).Protected__c = true;
        AMGE.submitEdits();
        List<Contact> Results = [SELECT AccountId from Contact where email = 'ChangedTest8@tester.com'];
        system.AssertEquals(1,results.size(),'Should have found one Contact with a changed email.');
        Results = [SELECT MailingStreet from Contact where id =: AMGE.GUUs[2].RelatedContact__c];
        system.AssertEquals('New Mailing Street #111',results[0].MailingStreet,'Should have found one Contact with a changed email.');
        Results = [SELECT AccountId, Account.BillingStreet, Contact.MailingStreet from Contact where email = 'test2@tester.com'];
        system.AssertNotEquals('New Mailing Street #111',Results[0].Account.BillingStreet,'Should have changed Account Address.');
    }

    // If there are multiple changes to the same account address, controller
    // Should not submit additional changes, and should set SomeContactsNotProcessed flag.
    @IsTest
    static void multipleChangesToAccount(){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Account> ListAccts = new List<Account>();
        For (integer i=0;i<9;i++) {
            Account Acct = new Account(
                    Name = 'Account'+i
            );
            ListAccts.add(Acct);
        }
        insert ListAccts;
        List<Contact> ListCtcts = new List<Contact>();
        For (integer i=0;i<9;i++) {
            Contact Ctct = new Contact(
                    FirstName = 'TestGUU2',
                    LastName = 'Tester' + i,
                    Email = 'test' + i + '@tester.com',
                    AccountId = ListAccts[i].Id
            );
            ListCtcts.add(Ctct);
        }
        insert ListCtcts;
        Id UnknownCampId = WGHelpers.getUnknownCampaignId();
        ListCtcts = [SELECT Id from Contact WHERE FirstName LIKE 'TestGUU2%'
        ORDER BY LastName];
        system.assertEquals(9,ListCtcts.size());
        List<GuestUserUpdate__c> ListGUUs = new List<GuestUserUpdate__c>();
        For (integer i=0;i<9;i++) {
            GuestUserUpdate__c newGUU = new GuestUserUpdate__c(
                    FirstName__c = 'TestGUU2',
                    LastName__c = 'Tester' + i,
                    Email__c = 'test' + i + '@tester.com',
                    Processing_Status__c = 'Review',
                    MailingStreet__c = 'Mailing Street ' + i,
                    RelatedContact__c = ListCtcts[i].Id
            );
            ListGUUs.add(newGUU);
        }
// One of the nine should not appear in the list
// because it is set to rejected
        ListGUUs[8].Processing_Status__c='Rejected';
        ListGUUs[0].Email__c='ChangedTest8@tester.com';
        insert ListGUUs;
        system.debug('GuestUserEdits are ' + ListGUUs);
        approveGuestUserEdits AMGE = new approveGuestUserEdits();
        system.assertEquals(16,AMGE.GUUs.size());
        AMGE.submitEdits();
        List<Contact> Results = [SELECT AccountId, Account.BillingStreet, Contact.MailingStreet from Contact
        WHERE FirstName = 'TestGUU'];
        system.debug('Results.size is  ' + results.size());
        Results = [SELECT AccountId, Account.BillingStreet,FirstName,LastName,MailingStreet from Contact
        where MailingStreet='Mailing Street 0'];
        system.debug('Results of Contact  list query is ' + Results);
        system.AssertEquals(1,Results.size());
        List<GuestUserUpdate__c> ResultsGUUs = [SELECT Id,MailingStreet__c,FirstName__c,LastName__c,Processing_Status__c
        FROM GuestUserUpdate__c WHERE  MailingStreet__c<>null AND Processing_Status__c='Approved'];
        // Test Street 111 is the usual record created by Create_Test_Variables.
        system.debug('resultsGUUs are ' + ResultsGUUs);
        // Should still be 8 records waiting to be processed.
        // 9 GUUs originally, 1 was set to "rejected", 1 was just processed
        System.assertEquals(8,ResultsGUUs.size(),'Should still be 8 records waiting to be processed because each GUU had a different address.');
    }
}