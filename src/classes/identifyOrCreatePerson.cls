// TEsting dummy change
// Sept 29 2016 Baird updates to set Lead.Addressee__c and Dear__c
// March 2018 Baird adds return of AccountId.  Now results LIst<string> is contactId or LeadId, "lead" or "contact", and accountId if a Contact
// JJune 2020 switch to "without sharing," remove function that updates contact info
// TEsting dummy change
// Feb 2021
// By using the formula field Contact.Lookup_Key__c we can vary the components of the Lookup Key
// Add a new method MatchesList which brings back multiple matches against multiple emails.
// identifyOrCreatePerson now contains both this new method and the old one.



public without sharing class identifyOrCreatePerson {

    public static List<MatchObject> MatchesList(Contact signer) {
        String sEmailQuery = null;
        String sMobilePhoneQuery = null;
        String sLookupKeyQuery = null;
        Boolean createNewPerson;
        String LookupKey;
        Contact UpdateContact;
        MatchObject MO;
        List<MatchObject> Matches;
        List<MatchObject> MatchesByRank;

        // set of email addresses with no blanks in it
        Set<string> EmailsToMatch = new set<string>();
        if (String.isNotBlank(signer.Email)) {
            system.debug('signer.Email is ' + signer.Email);
            EmailsToMatch.add(signer.Email);
        }
        if (String.isNotBlank(signer.Personal_Email__c)) EmailsToMatch.add(signer.Personal_Email__c);
        if (String.isNotBlank(signer.Work_Email__c)) EmailsToMatch.add(signer.Work_Email__c);
        if (String.isNotBlank(signer.Other_Email__c)) EmailsToMatch.add(signer.Other_Email__c);
        system.debug('EmailsToMatch list is ' + EmailsToMatch);

        // Set LookupKey
        if (signer.LastName != null && signer.FirstName != null && signer.MailingPostalCode != null) {
            LookupKey = signer.FirstName.toLowerCase() + signer.LastName.toLowerCase() + signer.MailingPostalCode;
        }
        // Set MobPhone
        if (signer.MobilePhone != null) string MobPhone = signer.MobilePhone;

        // The base Contact query with all the fields
        String sContactQuery = 'SELECT Id, Legacy_Contact_ID__c, Name, accountid, email, firstname, lastname, homephone, mobilephone, ' +
                ' MailingStreet, MailingCity, MailingState,MailingPostalCode, MailingCountry,OtherPhone, Salutation, Lookup_Key__c, ' +
                ' Personal_Email__c,Other_Email__c, Work_Email__c, Preferred_Email__c, Title, Volunteer_Interests__c, Description, ' +
                'Mailing_Lists__c, Do_Not__c FROM Contact ';
        // The conditions for matching against email
        if (EmailsToMatch != null) {
            sEmailQuery = sContactQuery + ' WHERE ( ' +
                    ' email IN :EmailsToMatch OR Personal_Email__c IN :EmailsToMatch ' +
                    ' OR Other_Email__c IN :EmailsToMatch OR ' +
                    '(Work_Email__c IN :EmailsToMatch AND (NOT Work_Email__c LIKE \'info%\'))) ';
        }
        // The conditions for matching against Lookup_Key__c, currently Last+First+Zip
        if (!String.Isblank(LookupKey))
            sLookupKeyQuery = sContactQuery + ' WHERE Lookup_Key__c =: LookupKey ';
        // The conditions for matching against MobilePhone
        if (signer.MobilePhone != null) {
            sMobilePhoneQuery = sContactQuery + 'WHERE MobilePhone =: MobPhone ';
            system.debug('signer.MobilePhone is ' + signer.MobilePhone);
        }

        Matches = new List<MatchObject>();
        MatchesByRank = new List<MatchObject>();
        // Go through each query and add to the matches
        If (sEmailQuery != null)
            for (Contact MC : database.query(sEmailQuery)) {
                // TRAP CASE ANOMALIES
                if (MC.FirstName.toLowerCase() == signer.FirstName.toLowerCase()
                        && MC.LastName.toLowerCase() == signer.LastName.toLowerCase()) {
                    MO = new MatchObject();
                    MO.PersonId = MC.Id;
                    MO.Person = MC;
                    MO.AccountId = MC.AccountId;
                    MO.MatchMethod = 'Match On First Last Email';
                    MO.MatchRank = 1;
                } else {
                    MO = new MatchObject();
                    MO.PersonId = MC.Id;
                    MO.Person = MC;
                    MO.AccountId = MC.AccountId;
                    MO.MatchMethod = 'Match On Email Only';
                    MO.MatchRank = 5;
                }
                // At this point I could catch duplicates.
                Matches.add(MO);
                system.debug('Matches is ' + Matches);
            }

        // Does it match on Lookup_Key__c
        If (sLookupKeyQuery != null) {
            for (Contact MC : database.query(sLookupKeyQuery)) {
                MO = new MatchObject();
                MO.PersonId = MC.Id;
                MO.Person = MC;
                MO.AccountId = MC.AccountId;
                MO.MatchMethod = 'Match On Lookup_Key__c';
                MO.MatchRank = 3;
                Matches.add(MO);
            }
        }

        // Does it match on MobilePhone
        If (sMobilePhoneQuery != null)
            for (Contact MC : database.query(sMobilePhoneQuery)) {
                if (MC.FirstName == signer.FirstName && MC.LastName == signer.LastName) {
                    MO = new MatchObject();
                    MO.PersonId = MC.Id;
                    MO.Person = MC;
                    MO.AccountId = MC.AccountId;
                    MO.MatchMethod = 'Match On First Last Mobile';
                    MO.MatchRank = 2;
                } else {
                    MO = new MatchObject();
                    MO.PersonId = MC.Id;
                    MO.Person = MC;
                    MO.AccountId = MC.AccountId;
                    MO.MatchMethod = 'Match On Mobile Only';
                    MO.MatchRank = 4;
                }
                // At this point I could catch duplicates.
                Matches.add(MO);
            }

        // If this organization uses leads
        If (WGHelpers.getDontUseLeads() != true) {
            // The base Lead query with all the fields
            String sLeadQuery = 'SELECT Id, Legacy_Contact_ID__c, Name, Company, email, firstname, lastname, home_phone__c, mobilephone, ' +
                    ' Street, City, State,PostalCode, Country, Salutation, Lookup_Key__c, ' +
                    ' Personal_Email__c,Other_Email__c, Work_Email__c, Preferred_Email__c, Title, Volunteer_Interests__c, Description, ' +
                    'Mailing_Lists__c, Do_Not__c FROM Lead ';
            if (EmailsToMatch != null) {
                sEmailQuery = sLeadQuery + ' WHERE ( ' +
                        ' email IN :EmailsToMatch OR Personal_Email__c IN :EmailsToMatch ' +
                        ' OR Other_Email__c IN :EmailsToMatch OR ' +
                        '(Work_Email__c IN :EmailsToMatch AND (NOT Work_Email__c LIKE \'info%\'))) ';
            }
            // The conditions for matching against Lookup_Key__c, currently Last+First+Zip
            if (!String.Isblank(LookupKey))
                sLookupKeyQuery = sLeadQuery + ' WHERE Lookup_Key__c =: LookupKey ';
            // The conditions for matching against MobilePhone
            if (signer.MobilePhone != null) {
                sMobilePhoneQuery = sLeadQuery + 'WHERE MobilePhone =: MobPhone ';
                system.debug('signer.MobilePhone is ' + signer.MobilePhone);
            }
            If (sEmailQuery != null)
                for (Lead MC : database.query(sEmailQuery)) {
                    // TRAP CASE ANOMALIES
                    if (MC.FirstName.toLowerCase() == signer.FirstName.toLowerCase()
                            && MC.LastName.toLowerCase() == signer.LastName.toLowerCase()) {
                        MO = new MatchObject();
                        MO.PersonId = MC.Id;
                        MO.Person = MC;
                        MO.MatchMethod = 'Match On First Last Email';
                        MO.MatchRank = 1;
                    } else {
                        MO = new MatchObject();
                        MO.PersonId = MC.Id;
                        MO.Person = MC;
                        MO.MatchMethod = 'Match On Email Only';
                        MO.MatchRank = 5;
                    }
                    // At this point I could catch duplicates.
                    Matches.add(MO);
                    system.debug('Matches is ' + Matches);
                }

            // Does it match on Lookup_Key__c
            If (sLookupKeyQuery != null) {
                for (Lead MC : database.query(sLookupKeyQuery)) {
                    MO = new MatchObject();
                    MO.PersonId = MC.Id;
                    MO.Person = MC;
                    MO.MatchMethod = 'Match On Lookup_Key__c';
                    MO.MatchRank = 3;
                    Matches.add(MO);
                }
            }

            // Does it match on MobilePhone
            If (sMobilePhoneQuery != null)
                for (Lead MC : database.query(sMobilePhoneQuery)) {

                    if (MC.FirstName.toLowerCase() == signer.FirstName.toLowerCase()
                            && MC.LastName.toLowerCase() == signer.LastName.toLowerCase()) {
                        MO = new MatchObject();
                        MO.PersonId = MC.Id;
                        MO.Person = MC;
                        MO.MatchMethod = 'Match On First Last Mobile';
                        MO.MatchRank = 2;
                    } else {
                        MO = new MatchObject();
                        MO.PersonId = MC.Id;
                        MO.Person = MC;
                        MO.MatchMethod = 'Match On Mobile Only';
                        MO.MatchRank = 4;
                    }
                    // At this point I could catch duplicates.
                    Matches.add(MO);
                }

        }


        // Order the Matches by the quality of the match
        system.debug('Before ordering the Matches list it is ' + Matches);
        // Assume that createNewPerson will be needed.
        createNewPerson = true;
        // Create a list of ranks
        if (!Matches.isEmpty()) {
            For (integer i = 0; i < 10; i++) {
                For (MatchObject m : Matches) {
                    if (m.MatchRank == i) MatchesByRank.add(m);
                    // If the match method is better than 4, then do not create a new person.
                    // Later we can link '4' to Custom Metadata and allow users to customize it.
                    system.debug('Is the match solidity > 4? ' + m.MatchRank);
                    if (m.MatchRank <= 4) createNewPerson = false;
                }
            }
        }

        // Create a new lead or contact if no matches or if createNewPerson is true
        if (Matches.size() == 0 || createNewPerson == true) {
            If (WGHelpers.getDontUseLeads() != true) {
                // Create new Lead
                Lead lTemp = New Lead(
                        // Are these all the fields we need to create?
                        FirstName = signer.FirstName,
                        LastName = signer.LastName,
                        Email = signer.Email,
                        Company = Signer.LastName + ', ' + signer.FirstName + ' Household',
                        Dear__c = signer.FirstName,
                        MobilePhone = signer.MobilePhone,
                        Street = signer.MailingStreet,
                        City = signer.MailingCity,
                        State = signer.MailingState,
                        PostalCode = signer.MailingPostalCode,
                        Country = signer.MailingCountry);
                insert lTemp;
                MO = new MatchObject();
                MO.PersonId = lTemp.Id;
                MO.Person = lTemp;
                MO.MatchMethod = 'Created New Person';
                MO.MatchRank = 0;
                MatchesByRank.add(MO);
            } else {
                // Create account then contact
                Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
                Map<String, Schema.RecordTypeInfo> RTBN = R.getRecordTypeInfosByName();
                Id FamilyRTId = RTBN.get('Family').getRecordTypeId();
                Account aTemp = new Account(
                        RecordTypeId = FamilyRTId,
                        Name = signer.LastName + ', ' + signer.FirstName + ' Household',
                        Is_Dummy__c = true,
                        Dear__c = signer.Dear__c,
                        Addressee__c = signer.FirstName + ' ' + signer.LastName,
                        Phone = signer.MobilePhone,
                        BillingStreet = signer.MailingStreet,
                        BillingCity = signer.MailingCity,
                        BillingState = signer.MailingState,
                        BillingPostalCode = signer.MailingPostalCode,
                        BillingCountry = signer.MailingCountry);
                // Will have to move these two DML lines to a method Without Sharing
                // NPSP gets around this.  Look up "by reference" and "by Value"
                insert aTemp;
                Insert signer;
                MO = new MatchObject();
                MO.PersonId = signer.Id;
                MO.Person = signer;
                MO.AccountId = signer.AccountId;
                MO.MatchMethod = 'Created New Person';
                MO.MatchRank = 0;
                MatchesByRank.add(MO);
            }
            // If not creating a new lead or contact then update the contact information
        } else {
            // Update address information in top-ranked matching contact or lead
            if (MatchesByRank[0].MatchMethod != 'Match On Lookup_Key__c') {
                UpdateContactAddress(signer, MatchesByRank[0].Person);

                // Update emails
                if (MatchesByRank[0].MatchMethod != 'Match On First Last Email' && MatchesByRank[0].MatchMethod != '5Match On Email Only') {
                    // if incoming email does not match any existing
                    if (!(EmailsToMatch.CONTAINS(String.valueOf(MatchesByRank[0].Person.get('Email'))) &&
                            EmailsToMatch.CONTAINS(String.valueOf(MatchesByRank[0].Person.get('Personal_Email__c'))) &&
                            EmailsToMatch.CONTAINS(String.valueOf(MatchesByRank[0].Person.get('Other_Email__c'))) &&
                            EmailsToMatch.CONTAINS(String.valueOf(MatchesByRank[0].Person.get('Work_Email__c')))
                    )) {
                        UpdateEmails(signer, MatchesByRank[0].Person);
                    }
                }

                // Update Mobile Phone
                if (MatchesByRank[0].MatchMethod != 'Match On First Last Mobile' && MatchesByRank[0].MatchMethod != 'Match On Mobile Only')
                    UpdateMobilePhone(signer, MatchesByRank[0].Person);


            }
        }
        update MatchesByRank[0].Person;
        system.debug('MatchesByRank is ' + MatchesByRank);
        return MatchesByRank;
    }

    static void UpdateEmails(Contact NewContact, SObject Existing) {
        // This is insufficient for cases where Personal, Work or Other Email is populated.
        // But good enough for a simple scenario.
        Existing.put('email',NewContact.Email);
    }

    static void UpdateMobilePhone(Contact NewContact, SObject Existing) {
        // if incoming mobile does not match existing
        if (NewContact.MobilePhone != null && NewContact.MobilePhone != Existing.get('MobilePhone')) {
            if (Existing.get('MobilePhone') == null) {
                Existing.put('MobilePhone',NewContact.MobilePhone);
            } else {
                Existing.put('Description', Existing.get('Description') + 'On ' + String.ValueOf(System.today().format()) +
                        ' we received a new mobile phone number: ' + NewContact.MobilePhone);
            }
        }
    }

    static void updateContactAddress(Contact NewContact, SObject Existing) {
// if the incoming address is complete or existing address is empty && incoming has information
// in at least one field
// Under the following conditions ignore the zip code, which will often be filled
// in WaterGrass because we require it on many forms.
        // Add the case that existing values match new values while some fields are incomplete
        if ((STRING.IsNotBlank(NewContact.MailingStreet) &&
                STRING.IsNotBlank(NewContact.MailingCity) &&
                STRING.IsNotBlank(NewContact.MailingState) &&
                STRING.IsNotBlank(NewContact.MailingPostalCode)) ||
                (((Existing.getSObjectType().getDescribe().getName() == 'Contact' &&
                        STRING.IsBlank(String.valueOf(Existing.get('MailingStreet'))) &&
                        STRING.IsBlank(String.valueOf(Existing.get('MailingCity'))) &&
                        STRING.IsBlank(String.valueOf(Existing.get('MailingState'))))
                        ||
                        (Existing.getSObjectType().getDescribe().getName() == 'Lead' &&
                                STRING.IsBlank(String.valueOf(Existing.get('Street'))) &&
                                STRING.IsBlank(String.valueOf(Existing.get('City'))) &&
                                STRING.IsBlank(String.valueOf(Existing.get('State')))))
                        &&
                        (STRING.IsNotBlank(NewContact.MailingStreet))) ||
                STRING.IsNotBlank(NewContact.MailingCity) ||
                STRING.IsNotBlank(NewContact.MailingState) ||
                STRING.IsNotBlank(NewContact.MailingPostalCode)
                ) {
// Add old address to Description field.
            String OldAddress =
                    Existing.getSObjectType().getDescribe().getName() == 'Contact'
                            ? String.valueOf(Existing.get('MailingStreet')) + String.valueOf(Existing.get('MailingCity')) +
                            String.valueOf(Existing.get('MailingState')) + String.valueOf(Existing.get('MailingPostalCode'))
                            : String.valueOf(Existing.get('Street')) + String.valueOf(Existing.get('City')) +
                            String.valueOf(Existing.get('State')) + String.valueOf(Existing.get('PostalCode'));
            if (OldAddress != null) {
                OldAddress =
                        Existing.getSObjectType().getDescribe().getName() == 'Contact'
                                ? Existing.get('MailingStreet') + ' ' + Existing.get('MailingCity') + ', ' +
                                Existing.get('MailingState') + ' ' + Existing.get('MailingPostalCode')
                                : Existing.get('Street') + ' ' + Existing.get('City') + ', ' +
                                Existing.get('State') + ' ' + Existing.get('PostalCode');
            }
            String ExistingDescription = String.ValueOf(Existing.get('Description'));
            ExistingDescription =
                    String.IsBlank(ExistingDescription)
                            ? 'On ' + String.ValueOf(System.today().format()) + ' address was changed from ' + OldAddress
                            : 'On ' + String.ValueOf(System.today().format()) + ' address was changed from ' + OldAddress + ExistingDescription;
            Existing.put('Description', ExistingDescription);
// Insert new address in Address field
            if (Existing.getSObjectType().getDescribe().getName() == 'Contact') {
                if (NewContact.MailingStreet != null) Existing.put('MailingStreet', NewContact.MailingStreet);
                if (NewContact.MailingCity != null) Existing.put('MailingCity', NewContact.MailingCity);
                if (NewContact.MailingState != null) Existing.put('MailingState', NewContact.MailingState);
                if (NewContact.MailingPostalCode != null) Existing.put('MailingPostalCode', NewContact.MailingPostalCode);
            } else {
                if (NewContact.MailingStreet != null) Existing.put('Street', NewContact.MailingStreet);
                if (NewContact.MailingCity != null) Existing.put('City', NewContact.MailingCity);
                if (NewContact.MailingState != null) Existing.put('State', NewContact.MailingState);
                if (NewContact.MailingPostalCode != null) Existing.put('PostalCode', NewContact.MailingPostalCode);
            }
        }
    }

    //This is the old method, pre 2021
    public static String [] identifyOrCreatePerson(Contact signer) {
//declare a list to store results
        List<string> results = new String[3];
//If contact exists
//If email exists
        // if (!signer.email.isEmpty()) {
        Contact[] pccheck = [Select ID, AccountID from Contact where email = :signer.email AND FirstName =: signer.FirstName];
        system.debug('signer.email is ' + signer.email);
        system.debug('signer.lastname is ' + signer.lastname);
        system.debug('signer is ' + signer);
        //Make sure that there's a match, and that it's not a match on "null"
        if (pccheck.size() > 0 && signer.Email != null && signer.email != '') {
            if (signer.phone <> null) pccheck[0].phone=signer.phone;
            if (signer.MailingStreet<> null) pccheck[0].MailingStreet=signer.MailingStreet;
            if (signer.MailingCity <> null) pccheck[0].MailingCity=signer.MailingCity;
            if (signer.MailingState <> null) pccheck[0].MailingState=signer.MailingState;
            // if (signer.MailingPostalCode <> null) pccheck[0].MailingPostalCode=signer.MailingPostalCode;
            update pccheck[0];
            results[0] = pccheck[0].id;
            results[1] = 'Contact';
            results[2] = pccheck[0].accountId;
            system.debug('In ICP, just found Contact based on email ' + pccheck[0].id);
            return results;
        }
        // } // end of if email exists
        ELSE {
            //If lead exists based on email,   Make sure it's not one that's been converted.  And not null.
            Lead[] lcheck = [Select Id, Dear__c, Addressee__c from Lead where email = :signer.email AND
            FirstName =: signer.FirstName AND status <> 'Closed - Converted'];
            if (lcheck.size() > 0  && signer.Email != null) {
                if (signer.phone <> null) lcheck[0].phone=signer.phone;
                if (signer.MailingStreet<> null) lcheck[0].Street=signer.MailingStreet;
                if (signer.MailingCity <> null) lcheck[0].City=signer.MailingCity;
                if (signer.MailingState <> null) lcheck[0].State=signer.MailingState;
                // if (signer.MailingPostalCode <> null) lcheck[0].PostalCode=signer.MailingPostalCode;
                // Update Lead.Dear__c and Addressee__c if blank.
                if (lcheck[0].Dear__c == null) lcheck[0].Dear__c=signer.Firstname;
                if (lcheck[0].Addressee__c == null) lcheck[0].Addressee__c=signer.firstname + ' ' +  signer.lastname;
                update lcheck[0];
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                system.debug('In ICP, just found Lead based on email ' + lcheck[0].id);
                return results;
            }
            ELSE {
                //does contact exist based on name and zip code?
                system.debug('signer.firstname is ' + signer.firstname);
                pccheck = [Select ID, AccountID,firstname,lastname,MailingPostalCode from Contact
                where (firstname = :signer.firstname AND lastname = :signer.lastname
                and MailingPostalCode = :signer.MailingPostalCode)];
                if (pccheck.size() > 0) {
                    if (signer.phone <> null) pccheck[0].phone=signer.phone;
                    if (signer.MailingStreet<> null) pccheck[0].MailingStreet=signer.MailingStreet;
                    if (signer.MailingCity <> null) pccheck[0].MailingCity=signer.MailingCity;
                    if (signer.MailingState <> null) pccheck[0].MailingState=signer.MailingState;
                    // if (signer.MailingPostalCode <> null) pccheck[0].MailingPostalCode=signer.MailingPostalCode;
                    update pccheck[0];
                    results[0] = pccheck[0].ID;
                    results[1] = 'Contact';
                    results[2] = pccheck[0].accountId;
                    system.debug('In ICP, just found Contact based on first+last+zip ' + pccheck[0].id);
                    return results;
                }
                ELSE {
                    //does LEAD exist based on name and zip code?  Make sure it's not one that's been converted.
                    lcheck = [Select ID, firstname, lastname, PostalCode, Dear__c, Addressee__c from Lead
                    where (firstname = :signer.firstname AND lastname = :signer.lastname
                    AND PostalCode = :signer.MailingPostalCode) and status <> 'Closed - Converted'];
                    if (lcheck.size() > 0) {
                        if (signer.phone <> null) lcheck[0].phone=signer.phone;
                        if (signer.MailingStreet<> null) lcheck[0].Street=signer.MailingStreet;
                        if (signer.MailingCity <> null) lcheck[0].City=signer.MailingCity;
                        if (signer.MailingState <> null) lcheck[0].State=signer.MailingState;
                        // if (signer.MailingPostalCode <> null) lcheck[0].PostalCode=signer.MailingPostalCode;
                        // Update Lead.Dear__c and Addressee__c if blank.
                        if (lcheck[0].Dear__c == null) lcheck[0].Dear__c=signer.Firstname;
                        if (lcheck[0].Addressee__c == null) lcheck[0].Addressee__c=signer.firstname + ' ' +  signer.lastname;
                        update lcheck[0];
                        results[0] = lcheck[0].Id;
                        results[1] = 'Lead';
                        system.debug('In ICP, just found Lead based on first+last+zip. ' + lcheck[0].id );
                        return results;
                    } //end does Lead exist based on name and zip code?
                    ELSE {
                        //create new lead
                        system.debug('In ICP, didnt find Contact or Lead, just entered Create New Lead');
                        lead newlead = new Lead (lastname = signer.lastname,
                                firstname=signer.firstname,
                                email=signer.email,
                                dear__c=signer.firstname,
                                Addressee__c=signer.firstname + ' ' + signer.lastname,
                                postalcode=signer.MailingPostalCode,
                                company= signer.lastname + ', ' + signer.firstname + ' Household',
                                RecordTypeID = [select ID from RecordType where name = 'Online Signup'].id);
                        if (signer.phone <> null) newlead.phone=signer.phone;
                        if (signer.MailingStreet<> null) newlead.Street=signer.MailingStreet;
                        if (signer.MailingCity <> null) newlead.City=signer.MailingCity;
                        if (signer.MailingState <> null) newlead.State=signer.MailingState;
                        if (signer.MailingPostalCode <> null) newlead.PostalCode=signer.MailingPostalCode;
                        system.debug('Just before insert, signer.lastname is ' + signer.lastname);
                        try {
                            insert newlead;
                            results[0] = newlead.id;
                            results[1] = 'Lead';
                        }
                        catch (exception x) {
                            results[0] = null;
                            results[1] = 'Error ' + x.getmessage();
                        }
                        return results;
                    } //end create new lead
                } //end ELSE does lead exist?
            } //end ELSE does contact exist?
        } // end ELSE does lead exist based on email?
    } // end does contact exist based on email?

}