@istest
private class ParticipantListProcessingTest {
        
    static testMethod void test() { 
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) { 
            insert new CampaignStati__c(Name='Attended', HasResponded__c=true);       
            insert new CampaignStati__c(Name='Contributed', HasResponded__c=true);          
         }           
       
        Create_Test_Variables ctv = new Create_Test_Variables();
		        
        Campaign c = ctv.fetchTestCampaign();
                
        ApexPages.currentPage().getParameters().put('cid', c.Id);
        
        ParticipantListProcessingController pehc = new ParticipantListProcessingController(new ApexPages.StandardController(new CampaignMember()));         
        
        List<SelectOption> stati = pehc.getStati();
        
        ///////////////////////////////////////////////
        Opportunity opp;
        List<Opportunity> Opps;
        Lead l = ctv.fetchTestLead();
        
        pehc.attendee.Id = l.Id; 
        pehc.attendee.Hours = 4;
        
        pehc.attendee.addToList();    
                
        pehc.all.cm.Status = 'Attended';
        pehc.all.Hours = 5;
        
        pehc.setAllStatus();
        pehc.setAllHours();
        
        pehc.all.Hours = 0;
        pehc.setAllHours();
			        
        pehc.createContribution(pehc.attendee);
		
        ///////////////////////////////////////////////
        
        Contact co = ctv.fetchTestContact();
        
        pehc.attendee = new ParticipantListProcessingController.Attendee(pehc);
        pehc.attendee.Id = co.Id;
        
        pehc.attendee.addToList();
            pehc.attendee.addToList();
        
        //////////////////////////////////////////////////////////////
        
        pehc.account.addNewContact();
        
		//Normally a user would have to insert a recordType in order to use the EnterAccountContact page
		//But we reprogrammed the controller to guard against recordTypeId == null       
		
        pehc.account.newContact.firstName = 'TestFN';
        pehc.account.newContact.lastName = 'TestLN';
        
        pehc.account.SaveContact();
        
        /////////////////////////////////////////////////////////////////////////
                                     
        pehc.processSelected();        
        
        // pehc.submitData();
/*        
         ////////////////////////////////////
        // Baird Specific Requested Tests //
       ////////////////////////////////////
       
       // 1) If a user changes only status, then the campaignMember record is updated, but no opportunity is created.
        
        pehc.attendee = createTestAttendee(pehc);        
        
        System.assertEquals('Attended', pehc.attendee.CM.Status);		
                
        pehc.attendee.CM.Status = 'Contributed';
        
        pehc.setCM(pehc.attendee);
        
        update pehc.attendee.CM;
        
        Opp = pehc.createContribution(pehc.attendee);
        
        CampaignMember cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :pehc.attendee.CM.Id];        
        Opportunity[] opps = [SELECT Id, account.addressee__c FROM Opportunity WHERE Contact__c = :pehc.attendee.Id AND CampaignId = :pehc.Camp.Id];
        
        System.assertEquals('CONTRIBUTED', cmTest.Status.TOUPPERCASE());	// Updated Status	
        System.assertEquals(0, opps.size());	// No Contribution Created
        
        // 2) Controller is changing the CM status from attended to "responded yes" in all cases.  Test that this isn't happening.
       
        pehc.attendee = createTestAttendee(pehc);         
        pehc.attendee.hours = 2;
                      
        System.assertEquals('Attended', pehc.attendee.CM.Status);
        
        pehc.setCM(pehc.attendee);
        
        update pehc.attendee.CM;
        
        opp = pehc.createContribution(pehc.attendee);
        
        insert opp;
        
        cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :pehc.attendee.CM.Id];    
        System.assertEquals('Attended', cmTest.Status);	// Status remains the same
        
        // 3) If a user adds only a comment, then the comment is added to campaignmember record, but no opportunity is created.
       
        pehc.attendee = createTestAttendee(pehc); 
        
        pehc.attendee.comments = 'Testing comments';
        
        System.assertEquals('Testing comments', pehc.attendee.comments);		
                        
        pehc.setCM(pehc.attendee);
        
        update pehc.attendee.CM;
        
        opp = pehc.createContribution(pehc.attendee);
        
        cmTest = [SELECT Id, Comments__c FROM CampaignMember WHERE Id = :pehc.attendee.CM.Id];        
        opps = [SELECT Id FROM Opportunity WHERE Contact__c = :pehc.attendee.Id AND CampaignId = :pehc.Camp.Id];
        
        System.assertEquals('Testing comments', cmTest.Comments__c);	// Updated Comments	
        System.assertEquals(0, opps.size());	// No Contribution Created
        
        // 4) If a user changes hours, or adds a comment, or changes supervisor rating, then the campaignMember is added to the Attended list.
        
        pehc.attendee = createTestAttendee(pehc);    
        pehc.setCM(pehc.attendee);
        System.assertEquals(false, pehc.addToAttendedList(pehc.attendee));  
        
        pehc.attendee = createTestAttendee(pehc);         
        pehc.attendee.hours = 4;
        pehc.setCM(pehc.attendee);
        System.assertEquals(true, pehc.addToAttendedList(pehc.attendee));      
        
        pehc.attendee = createTestAttendee(pehc);         
        pehc.attendee.comments = 'Testing comments';     
        pehc.setCM(pehc.attendee);
        System.assertEquals(true, pehc.addToAttendedList(pehc.attendee));      
        
        pehc.attendee = createTestAttendee(pehc);         
        pehc.attendee.Contribution.Supervisor_Satisfaction__c = '5 - Amazing!';    
        pehc.setCM(pehc.attendee);
        System.assertEquals(true, pehc.addToAttendedList(pehc.attendee)); 
        pehc.exitToWaterGrass();
        pehc.returnToEditList();
 */       
        // 5) Does account.addressee__c and dear__c get set?
       
        pehc.attendee = createTestAttendee(pehc);        
        pehc.attendee.hours = 4;
        
        pehc.setCM(pehc.attendee);
        System.assertEquals(true, pehc.addToAttendedList(pehc.attendee));  
        
        update pehc.attendee.CM;
        
        opp = pehc.createContribution(pehc.attendee);
        pehc.submitData();
        
        Opps = [SELECT Id, account.addressee__c, account.name, account.dear__c FROM Opportunity WHERE CampaignId = :pehc.Camp.Id];
        
        System.assertEquals(1, opps.size(), 'Either none or more than one opportunity came through.  Should be 1.');
        System.assertEquals('Test TestContact', Opps[0].account.addressee__c,'No addressee for '+ Opps[0].account.name);
         System.assertEquals('Test', Opps[0].account.dear__c,'No dear for '+ Opps[0].account.name);
           
    }
    
    static private ParticipantListProcessingController.Attendee createTestAttendee(ParticipantListProcessingController pehc) {
         Create_Test_Variables ctv = new Create_Test_Variables();
        
        Contact co = ctv.fetchTestContact();
        
        system.assertEquals('Test TestContact', co.firstname + ' ' + co.lastname);
        ParticipantListProcessingController.Attendee attendee = new ParticipantListProcessingController.Attendee(pehc);

        attendee.Id = co.Id;
        
        attendee.addToList();	
        
        attendee.Comments = '';
        attendee.OriginalStatus = attendee.CM.Status;
        attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';
        
        return attendee;
    }
}