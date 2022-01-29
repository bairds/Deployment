// Baird checked May 2015, it filters out email = null
// Sept 29 2016 Baird updates to set Lead.Addressee__c and Dear__c
// Add test for phone formatting, add separate "CleanMobile" digit, regex to strip out nondigits.
@isTest
private class identifyOrCreatePersonTEST {

	static testMethod void NewPersonContact() {
		// Set BDontUseLeads so that contact is created instead of lead.
		WGHelpers.BDontUseLeads = true;
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();


		List<contact> checkResult = [
				select id, lastname, MailingPostalCode, Dear__c, Lookup_Key__c, Addressee__c
				from Contact
				where id = :TestCtct.Id
		];
		System.assertEquals('testtestcontact22222', checkResult[0].Lookup_Key__c);

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'Tester',
				Email = 'Test@tester.org',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('matchesList is ' + matchesList);

		checkResult = [
				select id, lastname, MailingPostalCode, Dear__c, Lookup_Key__c, Addressee__c
				from Contact
				where id = :MatchesList[0].PersonId
		];
		System.assertEquals('Tester', checkResult[0].lastname);
		System.assertEquals('33333', checkResult[0].MailingPostalCode);
		System.assertEquals('testtester33333', checkResult[0].Lookup_Key__c);
	}

	static testMethod void NewPersonLead() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead TestLead = ctv.fetchTestLead();


		List<Lead> checkResult = [
				select id, lastname, PostalCode, Dear__c,
						Lookup_Key__c, Addressee__c
				from Lead
				where id = :TestLead.Id
		];
		System.assertEquals('leadtestlead22222', checkResult[0].Lookup_Key__c);

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'Tester',
				Email = 'Test@tester.org',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('matchesList is ' + matchesList);

		checkResult = [
				select id, lastname, PostalCode, Dear__c,
						Lookup_Key__c, Addressee__c
				from Lead
				where id = :MatchesList[0].PersonId
		];
		System.assertEquals('Tester', checkResult[0].lastname);
		System.assertEquals('33333', checkResult[0].PostalCode);

		System.assertEquals('testtester33333', checkResult[0].Lookup_Key__c);
	}

	static testMethod void ExistingContactbyEmail() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'TestContact',
				Email = 'testcontact@dontbotherme.org',
				MailingPostalCode = '22222');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On First Last Email', MatchesList[0].MatchMethod, 'Should have matched First Last Email on the ctv.TestContact');
		List<Contact> checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestContact', checkResult[0].lastname);
		// does it update the postal code?
		// System.assertEquals('33333',checkResult[0].MailingPostalCode);
	}


	static testMethod void ExistingLeadbyEmail() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead Testlead = ctv.fetchTestLead();

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Lead',
				lastname = 'TestLead',
				Email = 'testlead@dontbotherme.org',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On First Last Email', MatchesList[0].MatchMethod, 'Should have matched First Last Email on the ctv.TestContact');
		List<Lead> checkResult = [
				select id, lastname, PostalCode
				from Lead
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestLead', checkResult[0].lastname);
		// does it update the postal code?
		System.assertEquals('33333', checkResult[0].PostalCode, 'TestLead.Postal Code should have been updated from 22222 to 33333.');
	}


	static testMethod void ExistingContactbyLookupKey() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MailingPostalCode = '33333';
		Testctct.FirstName = 'Test';
		Testctct.LastName = 'Testcontact';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('testtestcontact33333', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'Testcontact',
				Email = 'nottestcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On Lookup_Key__c', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testcontact', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}


	static testMethod void ExistingLeadbyLookupKey() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead Testlead = ctv.fetchTestLead();
		Testlead.PostalCode = '33333';
		Testlead.FirstName = 'Test';
		Testlead.LastName = 'Testlead';
		update Testlead;
		Lead checkResult = [
				select id, lastname, Lookup_Key__c, PostalCode
				from Lead
				WHERE id = :Testlead.Id
		];
		system.assertEquals('testtestlead33333', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'Testlead',
				Email = 'nottestcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On Lookup_Key__c', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, PostalCode
				from Lead
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testlead', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}

	static testMethod void MatchOnEmailAndLookupKey() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MailingPostalCode = '33333';
		Testctct.FirstName = 'Test';
		Testctct.LastName = 'Testcontact';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('testtestcontact33333', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(2, matchesList.size());
		System.assertEquals('Match On First Last Email', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Lookup_Key__c', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testcontact', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}


	static testMethod void MatchOnContactEmailAndLeadLookupKey() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MailingPostalCode = '33333';
		Testctct.FirstName = 'Test';
		Testctct.LastName = 'Testcontact';
		update Testctct;
		Lead Testlead = ctv.fetchTestLead();
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('testtestcontact33333', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Lead',
				lastname = 'TestLead',
				Email = 'testcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '22222');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(2, matchesList.size());
		System.assertEquals('Match On Lookup_Key__c', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		Lead checkResult2 = [
				select id, lastname, PostalCode
				from Lead
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestLead', checkResult2.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}


	static testMethod void MatchOnEmailOnlyAndLookupKey() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.MailingPostalCode = '22222';
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('test1testcontact22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		// This second contact matches on First+Last+Zip
		Contact TestContact2 = new Contact(
				FirstName = 'Test2',
				LastName = 'Testcontact',
				MailingPostalCode = '33333',
				AccountId = Testacct.Id
		);
		Insert TestContact2;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test2',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(2, matchesList.size());
		System.assertEquals('Match On Lookup_Key__c', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testcontact', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}


	static testMethod void MatchOnEmailThriceAndLookupKeyOnce() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.MailingPostalCode = '22222';
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('test1testcontact22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		// This second contact matches on First+Last+Zip
		Contact TestContact2 = new Contact(
				FirstName = 'Test2',
				LastName = 'Testcontact',
				MailingPostalCode = '33333',
				AccountId = Testacct.Id,
				Personal_Email__c = 'testcontact@dontbotherme.org',
				Preferred_Email__c = 'Personal'
		);
		Insert TestContact2;

		// This second contact matches on First+Last+Zip
		Contact TestContact3 = new Contact(
				FirstName = 'Test3',
				LastName = 'Testcontact',
				MailingPostalCode = '33333',
				AccountId = Testacct.Id,
				Work_Email__c = 'workcontact@dontbotherme.org',
				Preferred_Email__c = 'Work'
		);
		Insert TestContact3;
		Contact TestContact4 = new Contact(
				FirstName = 'Test4',
				LastName = 'Testcontact',
				MailingPostalCode = '44444',
				AccountId = Testacct.Id,
				Other_Email__c = 'othercontact@dontbotherme.org',
				Preferred_Email__c = 'Other'
		);
		Insert TestContact4;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test3',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				Work_Email__c = 'workcontact@dontbotherme.org',
				Other_Email__c = 'othercontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(5, matchesList.size());
		System.assertEquals('Match On First Last Email', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Lookup_Key__c', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[2].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[3].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[4].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testcontact', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}

	static testMethod void MatchOnLeadEmailThriceAndLookupKeyOnce() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead Testlead = ctv.fetchTestLead();
		// This contact matches only on email;
		Testlead.PostalCode = '22222';
		Testlead.FirstName = 'Test1';
		Testlead.LastName = 'TestLead';
		update Testlead;
		Lead checkResult = [
				select id, lastname, Lookup_Key__c, PostalCode
				from Lead
				WHERE id = :Testlead.Id
		];
		system.assertEquals('test1testlead22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		// This second contact matches on First+Last+Zip
		Lead TestLead2 = new Lead(
				FirstName = 'Test2',
				LastName = 'TestLead',
				Company = 'TestCompany',
				PostalCode = '33333',
				Personal_Email__c = 'testlead@dontbotherme.org',
				Preferred_Email__c = 'Personal'
		);
		Insert TestLead2;

		// This second contact matches on First+Last+Zip
		Lead TestLead3 = new Lead(
				FirstName = 'Test3',
				LastName = 'TestLead',
				Company = 'TestCompany',
				PostalCode = '33333',
				Work_Email__c = 'workcontact@dontbotherme.org',
				Preferred_Email__c = 'Work'
		);
		Insert TestLead3;
		Lead TestLead4 = new Lead(
				FirstName = 'Test4',
				LastName = 'TestLead',
				Company = 'TestCompany',
				PostalCode = '44444',
				Other_Email__c = 'othercontact@dontbotherme.org',
				Preferred_Email__c = 'Other'
		);
		Insert TestLead4;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test3',
				lastname = 'TestLead',
				Email = 'testlead@dontbotherme.org',
				Work_Email__c = 'workcontact@dontbotherme.org',
				Other_Email__c = 'othercontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(5, matchesList.size());
		System.assertEquals('Match On First Last Email', matchesList[0].MatchMethod, 'Should have matched the ctv.TestLead by Lookup_Key__c');
		System.assertEquals('Match On Lookup_Key__c', matchesList[1].MatchMethod, 'Should have matched the ctv.TestLead by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[2].MatchMethod, 'Should have matched the ctv.TestLead by Lookup_Key__c');
		System.assertEquals('Match On Email Only', matchesList[3].MatchMethod, 'Should have matched the ctv.TestLead by Lookup_Key__c');
		Lead checkResult2 = [
				select id, lastname, PostalCode
				from Lead
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestLead', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}

	static testMethod void MatchOnMobileAndMobileOnly() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.MailingPostalCode = '22222';
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		Testctct.MobilePhone = '1234567';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('test1testcontact22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		// This second contact matches on First+Last+Zip
		Contact TestContact2 = new Contact(
				FirstName = 'Test2',
				LastName = 'Testcontact',
				MailingPostalCode = '22222',
				MobilePhone = '1234567',
				AccountId = Testacct.Id
		);
		Insert TestContact2;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test2',
				lastname = 'Testcontact',
				Email = 'nottestcontact@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333',
				MobilePhone = '1234567');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		//System.assertEquals(2,matchesList.size());
		System.assertEquals('Match On First Last Mobile', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Mobile Only', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		checkResult = [
				select id, lastname, MailingPostalCode
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('Testcontact', checkResult.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}

	static testMethod void MatchOnLeadMobileAndMobileOnly() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead Testctct = ctv.fetchTestLead();
		// This Lead matches only on email;
		Testctct.PostalCode = '22222';
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'TestLead';
		Testctct.MobilePhone = '1234567';
		update Testctct;
		Lead checkResult = [
				select id, lastname, Lookup_Key__c, PostalCode
				from Lead
				WHERE id = :Testctct.Id
		];
		system.assertEquals('test1testlead22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestLead.');

		// This second Lead matches on First+Last+Zip
		Lead TestLead2 = new Lead(
				FirstName = 'Test2',
				LastName = 'TestLead',
				PostalCode = '22222',
				MobilePhone = '1234567',
				Company = 'TestCompany'
		);
		Insert TestLead2;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test2',
				lastname = 'TestLead',
				Email = 'nottestLead@dontbotherme.org',
				MailingStreet = 'Test Street',
				MailingPostalCode = '33333',
				MobilePhone = '1234567');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		//System.assertEquals(2,matchesList.size());
		System.assertEquals('Match On First Last Mobile', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		System.assertEquals('Match On Mobile Only', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by Lookup_Key__c');
		Lead checkResult2 = [
				select id, lastname, PostalCode
				from Lead
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestLead', checkResult2.lastname);
		// does it update the postal code?
		// System.assertEquals('Test Street',checkResult[0].MailingStreet);
	}

	static testMethod void UpdateAddressTest() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.MailingPostalCode = '22222';
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		Testctct.MobilePhone = '1234567';
		update Testctct;
		Contact checkResult = [
				select id, lastname, Lookup_Key__c, MailingPostalCode
				from Contact
				WHERE id = :Testctct.Id
		];
		system.assertEquals('test1testcontact22222', checkResult.Lookup_Key__c, 'The Lookup_Key__c should have been set for TestContact.');

		// Matches on First Last Email and Mobile Phone
		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test1',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				MailingStreet = '1 Test Street',
				MailingCity = 'Test City',
				MailingState = 'ME',
				MailingPostalCode = '33333',
				MobilePhone = '1234567');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(2, matchesList.size());
		System.assertEquals('Match On First Last Email', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact by FirstLastEmail');
		System.assertEquals('Match On First Last Mobile', matchesList[1].MatchMethod, 'Should have matched the ctv.TestContact by FirstLastMobile');
		checkResult = [
				select id, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode, Description
				from Contact
				where id = :matchesList[0].PersonId
		];
		// Is the new address inserted?
		System.assertEquals('Testcontact', checkResult.lastname);
		System.assertEquals('1 Test Street', checkResult.MailingStreet);
		System.assertEquals('Test City', checkResult.MailingCity);
		System.assertEquals('ME', checkResult.MailingState);
		System.assertEquals('33333', checkResult.MailingPostalCode);
		// Is the old address (which was just the zip code) saved in the Description field?
		system.debug('Is the old address saved in the Description field? ' + checkResult.Description);
		system.assert(checkResult.Description.CONTAINS('22222'), 'The existing zip code 22222 should have been moved into Description field.');
	}

	static testMethod void UpdateExistingMobilePhone() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MobilePhone = '0123456';
		update Testctct;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'TestContact',
				Email = 'testcontact@dontbotherme.org',
				MobilePhone = '1234567',
				MailingPostalCode = '22222');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On First Last Email', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact');
		List<Contact> checkResult = [
				select id, lastname, MailingPostalCode, Description, MobilePhone
				from Contact
				where id = :matchesList[0].PersonId
		];
		System.assertEquals('TestContact', checkResult[0].lastname);

		// Was the MobilePhone updated?
		System.assertEquals('0123456', checkResult[0].MobilePhone);
		// Is the old MobilePhone (which was just the zip code) saved in the Description field?
		system.debug('Is the old address saved in the Description field? ' + checkResult[0].Description);
		system.assert(checkResult[0].Description.CONTAINS('1234567'), 'The new zip code 1234567 should have been moved into Description field.');
	}

	static testMethod void UpdateExistingEmails() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MobilePhone = '1234567';
		Testctct.Preferred_Email__c = null;
		Testctct.Personal_Email__c = null;
		Testctct.Other_Email__c = null;
		update Testctct;

		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test',
				lastname = 'TestContact',
				Email = 'nottestcontact@dontbotherme.org',
				MobilePhone = '1234567',
				MailingPostalCode = '33333');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals('Match On First Last Mobile', matchesList[0].MatchMethod, 'Should have matched the ctv.TestContact');
		List<Contact> checkResult = [
				select id, lastname, MailingPostalCode, Email, Description, MobilePhone,
						Personal_Email__c, Work_Email__c, Other_Email__c, Preferred_Email__c, Legacy_Emails__c
				from Contact
				where id = :matchesList[0].PersonId
		];
		system.debug('checkResult is ' + checkResult);
		System.assertEquals('TestContact', checkResult[0].lastname);

		// Was the Email updated?
		System.assertEquals('nottestcontact@dontbotherme.org', checkResult[0].Email);
		// Is the old MobilePhone (which was just the zip code) saved in the Description field?
		system.debug('Is the old address saved in the Other email? ' + checkResult[0].Other_Email__c);
		system.assertEquals('nottestcontact@dontbotherme.org', checkResult[0].Other_Email__c, 'The old email testcontact@dontbotherme.org should have been moved into Other_Email__c field.');
		system.assertEquals('Other', checkResult[0].Preferred_Email__c);
		// system.assertEquals(checkResult[0].Legacy_Emails__c,'testcontact@dontbotherme.org','Should have stored old email in Legacy Emails');
	}

	//The following test methods test the new MatchesList method.
	// I've appended a "B" to all their names.
		@isTest
		static void NewPersonContactB() {
			// Set BDontUseLeads so that contact is created instead of lead.
			WGHelpers.BDontUseLeads = true;
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();


			List<contact> checkResult = [select id, lastname, MailingPostalCode, Dear__c, Lookup_Key__c, Addressee__c from Contact
			where id = :TestCtct.Id];
			System.assertEquals('testtestcontact22222', checkResult[0].Lookup_Key__c);

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'Tester',
					Email = 'Test@tester.org',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('matchesList is ' + matchesList);

			checkResult = [select id, lastname, MailingPostalCode, Dear__c, Lookup_Key__c, Addressee__c from Contact
			where id = :MatchesList[0].PersonId];
			System.assertEquals('Tester',checkResult[0].lastname);
			System.assertEquals('33333',checkResult[0].MailingPostalCode);
			System.assertEquals('testtester33333', checkResult[0].Lookup_Key__c);
		}

		static testMethod void NewPersonLeadB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Lead TestLead = ctv.fetchTestLead();


			List<Lead> checkResult = [select id, lastname, PostalCode, Dear__c,
					Lookup_Key__c, Addressee__c from Lead
			where id = :TestLead.Id];
			System.assertEquals('leadtestlead22222', checkResult[0].Lookup_Key__c);

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'Tester',
					Email = 'Test@tester.org',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('matchesList is ' + matchesList);

			checkResult = [select id, lastname, PostalCode, Dear__c,
					Lookup_Key__c, Addressee__c from Lead
			where id = :MatchesList[0].PersonId];
			System.assertEquals('Tester',checkResult[0].lastname);
			System.assertEquals('33333',checkResult[0].PostalCode);

			System.assertEquals('testtester33333', checkResult[0].Lookup_Key__c);
		}

		static testMethod void ExistingContactbyEmailB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'TestContact',
					Email = 'testcontact@dontbotherme.org',
					MailingPostalCode = '22222');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On First Last Email',MatchesList[0].MatchMethod,'Should have matched First Last Email on the ctv.TestContact');
			List<Contact> checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestContact',checkResult[0].lastname);
			// does it update the postal code?
			// System.assertEquals('33333',checkResult[0].MailingPostalCode);
		}


		static testMethod void ExistingLeadbyEmailB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Lead Testlead = ctv.fetchTestLead();

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Lead',
					lastname = 'TestLead',
					Email = 'testlead@dontbotherme.org',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On First Last Email',MatchesList[0].MatchMethod,'Should have matched First Last Email on the ctv.TestContact');
			List<Lead> checkResult = [select id, lastname, PostalCode from Lead
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestLead',checkResult[0].lastname);
			// does it update the postal code?
			System.assertEquals('33333',checkResult[0].PostalCode,'TestLead.Postal Code should have been updated from 22222 to 33333.');
		}


		static testMethod void ExistingContactbyLookupKeyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			Testctct.MailingPostalCode = '33333';
			Testctct.FirstName = 'Test';
			Testctct.LastName = 'Testcontact';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('testtestcontact33333',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'Testcontact',
					Email = 'nottestcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On Lookup_Key__c',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testcontact',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}


		static testMethod void ExistingLeadbyLookupKeyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Lead Testlead = ctv.fetchTestLead();
			Testlead.PostalCode = '33333';
			Testlead.FirstName = 'Test';
			Testlead.LastName = 'Testlead';
			update Testlead;
			Lead checkResult = [select id, lastname, Lookup_Key__c, PostalCode from Lead
			WHERE id =: Testlead.Id];
			system.assertEquals('testtestlead33333',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'Testlead',
					Email = 'nottestcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On Lookup_Key__c',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, PostalCode from Lead
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testlead',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}

		static testMethod void MatchOnEmailAndLookupKeyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			Testctct.MailingPostalCode = '33333';
			Testctct.FirstName = 'Test';
			Testctct.LastName = 'Testcontact';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('testtestcontact33333',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'Testcontact',
					Email = 'testcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Lookup_Key__c',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testcontact',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}


		static testMethod void MatchOnContactEmailAndLeadLookupKeyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			Testctct.MailingPostalCode = '33333';
			Testctct.FirstName = 'Test';
			Testctct.LastName = 'Testcontact';
			update Testctct;
			Lead Testlead = ctv.fetchTestLead();
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('testtestcontact33333',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Lead',
					lastname = 'TestLead',
					Email = 'testcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '22222');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On Lookup_Key__c',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			Lead checkResult2 = [select id, lastname, PostalCode from Lead
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestLead',checkResult2.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}


		static testMethod void MatchOnEmailOnlyAndLookupKeyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			// This contact matches only on email;
			Testctct.MailingPostalCode = '22222';
			Testctct.FirstName = 'Test1';
			Testctct.LastName = 'Testcontact';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			// This second contact matches on First+Last+Zip
			Contact TestContact2 = new Contact(
					FirstName = 'Test2',
					LastName = 'Testcontact',
					MailingPostalCode = '33333',
					AccountId = Testacct.Id
			);
			Insert TestContact2;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test2',
					lastname = 'Testcontact',
					Email = 'testcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On Lookup_Key__c',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testcontact',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}


		static testMethod void MatchOnEmailThriceAndLookupKeyOnceB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			// This contact matches only on email;
			Testctct.MailingPostalCode = '22222';
			Testctct.FirstName = 'Test1';
			Testctct.LastName = 'Testcontact';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			// This second contact matches on First+Last+Zip
			Contact TestContact2 = new Contact(
					FirstName = 'Test2',
					LastName = 'Testcontact',
					MailingPostalCode = '33333',
					AccountId = Testacct.Id,
					Personal_Email__c = 'testcontact@dontbotherme.org',
					Preferred_Email__c = 'Personal'
			);
			Insert TestContact2;

			// This second contact matches on First+Last+Zip
			Contact TestContact3 = new Contact(
					FirstName = 'Test3',
					LastName = 'Testcontact',
					MailingPostalCode = '33333',
					AccountId = Testacct.Id,
					Work_Email__c = 'workcontact@dontbotherme.org',
					Preferred_Email__c = 'Work'
			);
			Insert TestContact3;
			Contact TestContact4 = new Contact(
					FirstName = 'Test4',
					LastName = 'Testcontact',
					MailingPostalCode = '44444',
					AccountId = Testacct.Id,
					Other_Email__c = 'othercontact@dontbotherme.org',
					Preferred_Email__c = 'Other'
			);
			Insert TestContact4;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test3',
					lastname = 'Testcontact',
					Email = 'testcontact@dontbotherme.org',
					Work_Email__c = 'workcontact@dontbotherme.org',
					Other_Email__c = 'othercontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(5,matchesList.size());
			System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Lookup_Key__c',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[2].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[3].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[4].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testcontact',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}

		static testMethod void MatchOnLeadEmailThriceAndLookupKeyOnceB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Lead Testlead = ctv.fetchTestLead();
			// This contact matches only on email;
			Testlead.PostalCode = '22222';
			Testlead.FirstName = 'Test1';
			Testlead.LastName = 'TestLead';
			update Testlead;
			Lead checkResult = [select id, lastname, Lookup_Key__c, PostalCode from Lead
			WHERE id =: Testlead.Id];
			system.assertEquals('test1testlead22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			// This second contact matches on First+Last+Zip
			Lead TestLead2 = new Lead(
					FirstName = 'Test2',
					LastName = 'TestLead',
					Company = 'TestCompany',
					PostalCode = '33333',
					Personal_Email__c = 'testlead@dontbotherme.org',
					Preferred_Email__c = 'Personal'
			);
			Insert TestLead2;

			// This second contact matches on First+Last+Zip
			Lead TestLead3 = new Lead(
					FirstName = 'Test3',
					LastName = 'TestLead',
					Company = 'TestCompany',
					PostalCode = '33333',
					Work_Email__c = 'workcontact@dontbotherme.org',
					Preferred_Email__c = 'Work'
			);
			Insert TestLead3;
			Lead TestLead4 = new Lead(
					FirstName = 'Test4',
					LastName = 'TestLead',
					Company = 'TestCompany',
					PostalCode = '44444',
					Other_Email__c = 'othercontact@dontbotherme.org',
					Preferred_Email__c = 'Other'
			);
			Insert TestLead4;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test3',
					lastname = 'TestLead',
					Email = 'testlead@dontbotherme.org',
					Work_Email__c = 'workcontact@dontbotherme.org',
					Other_Email__c = 'othercontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(5,matchesList.size());
			System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestLead by Lookup_Key__c');
			System.assertEquals('Match On Lookup_Key__c',matchesList[1].MatchMethod,'Should have matched the ctv.TestLead by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[2].MatchMethod,'Should have matched the ctv.TestLead by Lookup_Key__c');
			System.assertEquals('Match On Email Only',matchesList[3].MatchMethod,'Should have matched the ctv.TestLead by Lookup_Key__c');
			Lead checkResult2 = [select id, lastname, PostalCode from Lead
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestLead',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}

		static testMethod void MatchOnMobileAndMobileOnlyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			// This contact matches only on email;
			Testctct.MailingPostalCode = '22222';
			Testctct.FirstName = 'Test1';
			Testctct.LastName = 'Testcontact';
			Testctct.MobilePhone = '1234567';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			// This second contact matches on First+Last+Zip
			Contact TestContact2 = new Contact(
					FirstName = 'Test2',
					LastName = 'Testcontact',
					MailingPostalCode = '22222',
					MobilePhone = '1234567',
					AccountId = Testacct.Id
			);
			Insert TestContact2;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test2',
					lastname = 'Testcontact',
					Email = 'nottestcontact@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333',
					MobilePhone = '1234567');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			//System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On First Last Mobile',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Mobile Only',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			checkResult = [select id, lastname, MailingPostalCode from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('Testcontact',checkResult.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}

		static testMethod void MatchOnLeadMobileAndMobileOnlyB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Lead Testctct = ctv.fetchTestLead();
			// This Lead matches only on email;
			Testctct.PostalCode = '22222';
			Testctct.FirstName = 'Test1';
			Testctct.LastName = 'TestLead';
			Testctct.MobilePhone = '1234567';
			update Testctct;
			Lead checkResult = [select id, lastname, Lookup_Key__c, PostalCode from Lead
			WHERE id =: Testctct.Id];
			system.assertEquals('test1testlead22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestLead.');

			// This second Lead matches on First+Last+Zip
			Lead TestLead2 = new Lead(
					FirstName = 'Test2',
					LastName = 'TestLead',
					PostalCode = '22222',
					MobilePhone = '1234567',
					Company = 'TestCompany'
			);
			Insert TestLead2;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test2',
					lastname = 'TestLead',
					Email = 'nottestLead@dontbotherme.org',
					MailingStreet = 'Test Street',
					MailingPostalCode = '33333',
					MobilePhone = '1234567');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			//System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On First Last Mobile',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			System.assertEquals('Match On Mobile Only',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by Lookup_Key__c');
			Lead checkResult2 = [select id, lastname, PostalCode from Lead
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestLead',checkResult2.lastname);
			// does it update the postal code?
			// System.assertEquals('Test Street',checkResult[0].MailingStreet);
		}

		static testMethod void UpdateAddressTestB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			// This contact matches only on email;
			Testctct.MailingPostalCode = '22222';
			Testctct.FirstName = 'Test1';
			Testctct.LastName = 'Testcontact';
			Testctct.MobilePhone = '1234567';
			update Testctct;
			Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
			WHERE id =: Testctct.Id];
			system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

			// Matches on First Last Email and Mobile Phone
			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test1',
					lastname = 'Testcontact',
					Email = 'testcontact@dontbotherme.org',
					MailingStreet = '1 Test Street',
					MailingCity = 'Test City',
					MailingState = 'ME',
					MailingPostalCode = '33333',
					MobilePhone = '1234567');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals(2,matchesList.size());
			System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by FirstLastEmail');
			System.assertEquals('Match On First Last Mobile',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by FirstLastMobile');
			checkResult = [select id, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode, Description from Contact
			where id = :matchesList[0].PersonId];
			// Is the new address inserted?
			System.assertEquals('Testcontact',checkResult.lastname);
			System.assertEquals('1 Test Street',checkResult.MailingStreet);
			System.assertEquals('Test City',checkResult.MailingCity);
			System.assertEquals('ME',checkResult.MailingState);
			System.assertEquals('33333',checkResult.MailingPostalCode);
			// Is the old address (which was just the zip code) saved in the Description field?
			system.debug('Is the old address saved in the Description field? ' + checkResult.Description);
			system.assert(checkResult.Description.CONTAINS('22222'),'The existing zip code 22222 should have been moved into Description field.');
		}

	@isTest
	static void DontUpdateAddressTestB() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.MailingStreet = null;
		Testctct.MailingCity = null;
		Testctct.MailingState = null;
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		Testctct.MobilePhone = '1234567';
		// Testctct zip is already 22222
		update Testctct;
		Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
		WHERE id =: Testctct.Id];
		system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

		// Matches on First Last Email and Mobile Phone
		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test1',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				MailingPostalCode = '22222',
				MobilePhone = '1234567');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(3,matchesList.size());
		System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by FirstLastEmail');
		System.assertEquals('Match On First Last Mobile',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by FirstLastMobile');
		System.assertEquals('Match On Lookup_Key__c',matchesList[2].MatchMethod,'Should have matched the ctv.TestContact by FirstLastZip');
		checkResult = [select id, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode, Description from Contact
		where id = :matchesList[0].PersonId];
		// Is the address the same and the Description field empty?
		system.debug('Is the old address saved in the Description field? ' + checkResult.Description);
		system.assertEquals(null,checkResult.Description,'No change to address, should not have added old address to Description.');
	}

	// If one field of the address is changed, it should update.
	@isTest
	static void UpdateAddressTestC() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		// This contact matches only on email;
		Testctct.FirstName = 'Test1';
		Testctct.LastName = 'Testcontact';
		Testctct.MobilePhone = '1234567';
		// Testctct zip is already 22222
		update Testctct;
		Contact checkResult = [select id, lastname, Lookup_Key__c, MailingPostalCode from Contact
		WHERE id =: Testctct.Id];
		system.assertEquals('test1testcontact22222',checkResult.Lookup_Key__c,'The Lookup_Key__c should have been set for TestContact.');

		// Matches on First Last Email and Mobile Phone
		IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
		Contact pcontact = new Contact(
				accountid = Testacct.Id,
				firstname = 'Test1',
				lastname = 'Testcontact',
				Email = 'testcontact@dontbotherme.org',
				MailingStreet = 'Test Street 112',
				MailingCity = 'Annapolis',
				MailingState = 'Maryland',
				MailingPostalCode = '22222',
				MobilePhone = '1234567');
		List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
		System.debug('ListResults is ' + matchesList);
		System.assertEquals(3,matchesList.size());
		System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact by FirstLastEmail');
		System.assertEquals('Match On First Last Mobile',matchesList[1].MatchMethod,'Should have matched the ctv.TestContact by FirstLastMobile');
		System.assertEquals('Match On Lookup_Key__c',matchesList[2].MatchMethod,'Should have matched the ctv.TestContact by FirstLastZip');
		checkResult = [select id, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode, Description from Contact
		where id = :matchesList[0].PersonId];
		// Is the address the same and the Description field empty?
		system.debug('Is the old address saved in the Description field? ' + checkResult.Description);
		system.assert(checkResult.Description.CONTAINS('111'),'Changed street number, should have saved new Description field with Test Street 111.');
	}
		@isTest
static void UpdateExistingMobilePhoneB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			Testctct.MobilePhone = '0123456';
			update Testctct;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'TestContact',
					Email = 'testcontact@dontbotherme.org',
					MobilePhone = '1234567',
					MailingPostalCode = '22222');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On First Last Email',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact');
			List<Contact> checkResult = [select id, lastname, MailingPostalCode, Description, MobilePhone from Contact
			where id = :matchesList[0].PersonId];
			System.assertEquals('TestContact',checkResult[0].lastname);

			// Was the MobilePhone updated?
			System.assertEquals('0123456',checkResult[0].MobilePhone);
			// Is the old MobilePhone (which was just the zip code) saved in the Description field?
			system.debug('Is the old address saved in the Description field? ' + checkResult[0].Description);
			system.assert(checkResult[0].Description.CONTAINS('1234567'),'The new zip code 1234567 should have been moved into Description field.');
		}

		static testMethod void UpdateExistingEmailsB() {
			Create_Test_Variables ctv = new Create_Test_Variables();
			Account Testacct = ctv.fetchTestAccount();
			Contact Testctct = ctv.fetchTestContact();
			Testctct.MobilePhone = '1234567';
			Testctct.Preferred_Email__c = null;
			Testctct.Personal_Email__c = null;
			update Testctct;

			IdentifyOrCreatePerson IOCP1 = new IdentifyOrCreatePerson();
			Contact pcontact = new Contact(
					accountid = Testacct.Id,
					firstname = 'Test',
					lastname = 'TestContact',
					Email = 'nottestcontact@dontbotherme.org',
					MobilePhone = '1234567',
					MailingPostalCode = '33333');
			List<MatchObject> matchesList = IdentifyOrCreatePerson.matchesList(pcontact);
			System.debug('ListResults is ' + matchesList);
			System.assertEquals('Match On First Last Mobile',matchesList[0].MatchMethod,'Should have matched the ctv.TestContact');
			List<Contact> checkResult = [select id, lastname, MailingPostalCode, Email, Description, MobilePhone,
					Personal_Email__c, Work_Email__c, Other_Email__c, Preferred_Email__c, Legacy_Emails__c from Contact
			where id = :matchesList[0].PersonId];
			system.debug('checkResult is ' + checkResult);
			System.assertEquals('TestContact',checkResult[0].lastname);

			// Was the Email updated?
			System.assertEquals('nottestcontact@dontbotherme.org',checkResult[0].Email);
			// Is the old MobilePhone (which was just the zip code) saved in the Description field?
			system.debug('Is the old address saved in the Other email? ' + checkResult[0].Other_Email__c);
			system.assertEquals('nottestcontact@dontbotherme.org',checkResult[0].Other_Email__c,'The old email testcontact@dontbotherme.org should have been moved into Other_Email__c field.');
			system.assertEquals('Other',checkResult[0].Preferred_Email__c);
			// system.assertEquals(checkResult[0].Legacy_Emails__c,'testcontact@dontbotherme.org','Should have stored old email in Legacy Emails');
		}

	}