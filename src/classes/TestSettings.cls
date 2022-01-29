//Tests for the existence of all custom settings, triggers, workflows,
//documents and static resources necesssary for the proper functioning of 
//WaterGrass code

@isTest(SeeAllData=true)
private class TestSettings {
    
    static testMethod void AutoFillContribName(){
        // NOTE: I think this one testmethod could hold many of the basic tests
        // for workflows that fire when an account, contact, campaign or opportunity
        // is created.  So let's add here.
        Create_Test_Variables CTV = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestcampaign();
        Opportunity TestOpp = ctv.fetchTestOpportunity();
        Opportunity retrieveOppAgain = [select name, closeDate from Opportunity where Id = :TestOpp.Id LIMIT 1];
        system.assertEquals(retrieveOppAgain.name,TestAcct.name + ' ' + string.valueOf(retrieveOppAgain.CloseDate) + ' ' + Testcamp.name,'Workflow autofill contribution name not as expected.  Check Autofill contribution name.  Does it pull the contact.name rather than account?');                         
		
    }

    // Can we turn off duplicate blocking using DMLOptions
    // so that unit tests can run?
    @IsTest
    static void DuplicateContactsNotBlocked(){
        List<DuplicateRule> ListDR = [select id  from DuplicateRule where isActive = true
            and sObjectType = 'Contact'];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        If (ListDR.size() > 0){
            // Insert two matching contacts
            Contact c1 = new Contact(
                    lastname = 'DuplicateContact',
                    firstname = 'Test'
            );
            Database.SaveResult dsr = Database.Insert(c1,dml);
            Contact c2 = new Contact(
                    lastname = 'DuplicateContact',
                    firstname = 'Test'
            );
            dsr = Database.Insert(c2,dml);
        }
        // Do two contacts exist now?  If not, there's been an error.
        List<Contact> Results = [SELECT Id from Contact WHERE lastname = 'DuplicateContact'];
        system.assertEquals(2,results.size(),'Duplicate Accounts not saved even though allowSave=true, which suggests that the Contact Duplicate Rule is erroneously set to Block');

    }


    // Can we turn off duplicate blocking using DMLOptions
    // so that unit tests can run?
    @IsTest
    static void DuplicateAccountsNotBlocked(){
        List<DuplicateRule> ListDR = [select id  from DuplicateRule where isActive = true
        and sObjectType = 'Account'];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        If (ListDR.size() > 0){
            // Insert two matching contacts
            Account c1 = new Account(
                    name = 'DuplicateAccount'
            );
            Database.SaveResult dsr = Database.Insert(c1,dml);
            Account c2 = new Account(
                    name = 'DuplicateAccount'
            );
            dsr = Database.Insert(c2,dml);
        // Do two Accounts exist now?  If not, there's been an error.
        List<Account> Results = [SELECT Id from Account WHERE name = 'DuplicateAccount'];
        system.assertEquals(2,results.size(),'Duplicate Accounts not saved even though allowSave=true, which suggests that the Account Duplicate Rule is erroneously set to Block');
        }
    }

}