/**
 * Created by Baird on 8/9/2020.
 */

@IsTest
private class inviteVolsInInterestCampaignTEST {

    @IsTest
    static void TwoCampaignMembers(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign VolIntCampaign = ctv.fetchTestCampaign();
        VolIntCampaign.Name = 'Stream Cleanups';
        VolIntCampaign.Type = 'Volunteer Interest';
        VolIntCampaign.RecordTypeId =
                Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Signup').getRecordTypeId();

        Update VolIntCampaign;
        Campaign Subcampaign = new Campaign(
                name = 'Subcampaign',
                Vol_Interest_Campaign__c = VolIntCampaign.Id,
                Description_Long__c = 'Come join the Stream Cleanup.  Details details details',
                Description = 'We will have fun in this stream cleanups.',
                Event_Date_Time__c = datetime.newInstance(2021,10,06,10,0,0)
        );
        insert Subcampaign;
        // Put subcampaign in stdController
        Contact Testcontact = ctv.fetchTestContact();
        CampaignMember Testcm = new CampaignMember(
                contactId = Testcontact.Id,
                campaignId = VolIntCampaign.Id,
                status = 'Responded Yes'
        );
        Insert Testcm;
        Contact Testcontact2 = new Contact(
                firstname = 'Test2',
                lastname = 'Testcontact'
        );
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(SubCampaign);
        inviteVolsInInterestCampaign iVIIC = new inviteVolsInInterestCampaign(stdcontroller);
        iVIIC.sendInvitationEmails();
        List<Messaging.SendEmailResult> LMSER = iVIIC.results;
        system.assertEquals(true, iVIIC.results[0].success);
        system.assertEquals(1,iVIIC.TotalEmailsSent,'Should have sent invitation email to both CMs');
        // Add a second campaign member
        Insert Testcontact2;
        CampaignMember Testcm2 = new CampaignMember(
                contactId = Testcontact2.Id,
                campaignId = VolIntCampaign.Id,
                status = 'Responded Yes'
        );
        Insert Testcm2;
        inviteVolsInInterestCampaign.CMExtended newCMX = new inviteVolsInInterestCampaign.CMExtended(TestCM2);
        iVIIC.CmpMmbrs.add(newCMX);
        // Test deletion from list
        iVIIC.CmpMmbrs[0].ToDelete = true;
        iVIIC.deleteRefresh();
        // Now 1 email should go out;
        system.assertEquals(1,iVIIC.TotalEmailsSent,'Since we removed one CM from the list, only one email should go out.');
        // But there should still be two campaign members in the Signup Campaign
        List<CampaignMember> resultCMs = [SELECT Id from CampaignMember where CampaignId =: VolIntCampaign.Id];
        system.assertEquals(2,resultCMs.size(),'Should not have deleted cms from Signup Campaign.');

    }
}