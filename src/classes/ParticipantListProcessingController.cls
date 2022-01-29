// Jan 31 Jose revises so users can add campaign members without refreshing whole page and erasing data they've already input.
// Nov 10 2016 Baird makes sure this inserts addressee and dear.
public class ParticipantListProcessingController 
{
    public list<Attendee> AttendeesRSVPed {get; set;}
    public list<Attendee> AttendeesAttended {get; set;}
    public List<CampaignMember> UpdateCMs;
        public Campaign Camp {get; set;}
        public List<CampaignMember> Campmmbrs {get; set;}
        public Boolean review {get; set;} // Value to render review pageBlock;
        public id VolContribId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        public Decimal TotalHours {get; set;}
        public LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        public id accountToDeleteId {get; set;}
        public id cid {get; set;}
        public id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
    
    	static public String DefaultRating = getDefaultValue(Opportunity.Supervisor_Satisfaction__c.getDescribe(), 2);
   		static public List<Schema.PicklistEntry> LeadershipLevels = Opportunity.Leadership_Level__c.getDescribe().getPicklistValues();
    	static public String DefaultLeadership = getDefaultValue(Opportunity.Leadership_Level__c.getDescribe(), 0);
    
        public Attendee attendee { get; set; }
    	public Attendee all { get; set; }
        
        public AccountController account {
                get; set;
            }
    
    public ParticipantListProcessingController(ApexPages.StandardController controller) {
        
        review = false;
        //FamilyRTID = [select id from RecordType where Name = 'Family'][0].id;
        
        this.cid = System.currentPageReference().getParameters().get('cid');
        if (this.cid==null) DisplayNoCAmpaignWarning();
        
        this.Camp = [select Id, campaign.name, Event_Date_Time__c from Campaign where id = :this.cid];       
       
        
        this.attendee = new Attendee(this);      
        this.all = new Attendee(this); 
        this.account = new AccountController(this);
        this.SetRSVP();
    }
    
    public void SetRSVP() {        
         this.AttendeesRSVPed = new List<Attendee>();
        for(CampaignMember cm: [select id, contactId, contact.FirstName, contact.LastName, contact.email, contact.accountid, LeadId, lead.firstname, 
                                lead.lastname, lead.isconverted, hours__c, status, Role__c from CampaignMember
        where campaign.id = :this.Camp.Id and Processed__c <> true order by contact.firstName, lead.firstName limit 1000]) {
            // As each campaignMember is processed we create a new Attendee object and add it to the AttendeesRSVPed
            this.AttendeesRSVPed.add(new Attendee(cm));
            // We also capture its status value so that we can check later to see whether the user has changed the status
            }
        
    }

//Get List of Status Values
public List<SelectOption> getStati() {
    List<SelectOption> stati = new List<SelectOption>();
    //Schema.DescribeFieldResult fieldResult = campaignMember.status.getDescribe();
    //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   // for (Schema.PicklistEntry f : ple) {
      //  
      //  stati.add(new SelectOption(f.getLabel(), f.getValue()));
       // }
       // 
        // Baird revised Jose's query to pull the CampaignMemberStati from the campaign itself
         for(CampaignMemberStatus cms : [SELECT Id, Label FROM CampaignMemberStatus WHERE CampaignId = :cid])
                stati.add(new SelectOption(cms.Label, cms.Label));
    
        return stati;
}
    
    
    static public String getDefaultValue(Schema.DescribeFieldResult field, Integer index) {
    
    List<Schema.PicklistEntry> sspl = field.getPicklistValues();
    
     if(index >= sspl.size())     
         index = 0;
        
     return sspl[index].getLabel();
}
    public void setAllStatus()
    {
        for(Attendee a : AttendeesRSVPed) {
            if(String.isNotBlank(all.cm.Status))
            	a.cm.Status = all.cm.Status;
            
            if(a.Hours == 0)
            	a.Hours = null;
        }
        
        if(all.Hours == 0)
        	all.Hours = null;
    }
    
    public void setAllHours()
    {
        for(Attendee a : AttendeesRSVPed) {
            a.Hours = all.Hours;
            
            if(a.Hours == 0)
            	a.Hours = null;
        }
        
        if(all.Hours == 0)
        	all.Hours = null;
    }


    public void addCMToList(CampaignMember cm) {       
        this.formatsRSVPedList();
        this.AttendeesRSVPed.add(new Attendee(CM));
    }
    
    public void formatsRSVPedList(){
        for(Attendee a: AttendeesRSVPed) {
             if(a.hours == 0)
                 a.hours = null;               
        }
    }
    

public void processSelected() {
        this.account.newContactForm = false;
    
        UpdateCMs = new List<CampaignMember>();
        AttendeesAttended = new List<Attendee>();
     	TotalHours = 0;
    
        for(Attendee a: AttendeesRSVPed) {                                            
            system.debug('Going through AttendeesRSVPed to add to AttendeesAttended');
           
            if(addToAttendedList(a)){
            	if(a.hours != null)
            		TotalHours += a.hours;
            }                
        }
    
    	 if(all.Hours == 0)
        	all.Hours = null;
    
        if(AttendeesAttended.size() == 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No members were processed'));
    
        if(!ApexPages.hasMessages())
            review = true;            
    }

    public Boolean addToAttendedList(Attendee a) {
        
          if(a.hours == 0)
          	a.hours = null;
        
        // If user has changed hours, comments, rating, or status
        
        if(a.hours != null  || a.Comments != '' || a.Contribution.Supervisor_Satisfaction__c != ParticipantListProcessingController.DefaultRating || a.OriginalStatus != a.CM.Status) {
            AttendeesAttended.add(a);      
        	return true;
        }
        
        return false;
    }    
        
    
//Back to WaterGrass
    public pageReference exitToWaterGrass(){
        PageReference nextPage = new PageReference('/'+camp.id);
        nextPage.setRedirect(true);
        return nextPage;
    }    


//REturn to Edit List
    public pageReference returnToEditList(){
        review=false;
        AttendeesAttended.clear();
        return null;
    } 

//Submit Data
    public pageReference submitData(){
        List<Opportunity> InsertOpps = new List<Opportunity>();
        
        if(this.camp.Event_Date_Time__c == null) {
            this.Camp.Event_Date_Time__c = this.attendee.Contribution.CloseDate;
            
            update this.Camp;
        }
            
        
        For (Attendee a : AttendeesAttended) {            
   			setCM(a);
            
            UpdateCMs.add(a.cm);
            
            Opportunity opp = this.createContribution(a);            
            
            if (opp != null) 
                InsertOpps.add(opp);             
        }
        
        if (UpdateCMs.size() > 0) update UpdateCMs; // We set all the CMs in the AttendeeRSVPed list to 'processed' so we won't pull them in the next batch.
        
        if (InsertOpps.size() > 75) 
            Id batchId = Database.executeBatch(new OpportunityBatch(InsertOpps), 75);
        else if (InsertOpps.size() > 0) insert InsertOpps;
        
        PageReference nextPage = new PageReference('/'+camp.id);
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public void setCM(Attendee a)
    {
    	a.cm.Hours__c = a.hours;
        a.cm.Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c;
        a.cm.Comments__c = a.comments;
        a.cm.Leadership_Level__c = a.Contribution.Leadership_Level__c;
        a.cm.Processed__c = true;
    }
    
    public Opportunity createContribution(Attendee a)
    {        
    	if(a.hours > 0) {            
    		Opportunity opp = new Opportunity(
                Name = 'autofill',
                closedate = attendee.Contribution.CloseDate,
                hours_actual__c = a.hours,
                campaignid = camp.id,
                recordTypeId = VolContribId,
                description = a.comments,
                Leadership_Level__c = a.Contribution.Leadership_Level__c,
                stageName = 'Completed',
                Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c
            );
            
            if (a.cm.lead.lastname != null && a.cm.lead.isconverted != true) {
                    system.debug('Just found this is a lead, opp is ' + opp);
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(a.cm.leadid);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    lc.setOverwriteLeadSource(true);
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                	//Feb 3 - Baird: This values need to get assigned after the lead conversion in order for them to be properly inserted in the opportunity
                	// Make sure conversion was successful
                    System.assert(lcr.isSuccess());
                   
                    opp.contact__c = lcr.getContactId();
                    opp.accountid = lcr.getAccountId();
                
                    //system.debug('Just set contact__c and accountid for opp, which is now is ' + opp + ' and account is ' + acct);
            } 
            else {
                system.debug('Just found this is a contact, opp is ' + opp);
                opp.contact__c = a.cm.contactid;
                opp.accountid = a.cm.contact.accountid;
                system.debug('Just set contact__c and accountid for opp, which is now is ' + opp);
            }
            
            
            // Add Dear__c and Addressee to account
            Account acct = [select Id, Dear__c, Addressee__c, Name from account where id = :opp.accountid];
            
            if(String.isBlank(acct.Dear__c) || String.isBlank(acct.Addressee__c)) {
                 Contact ctct = [select id, firstname, lastname from Contact where id = :opp.contact__c];
                if (acct.name == 'none') acct.name = ctct.lastname + ', ' + ctct.firstname + ' Household';
                
                if(String.isBlank(acct.Dear__c))
                	acct.Dear__c = ctct.firstname;
                
               if(String.isBlank(acct.Addressee__c)) 
                	acct.Addressee__c = ctct.FirstName + ' ' + ctct.LastName;
                
                system.debug('In lcr, Account Name is ' + Acct.name);
                update acct;
                            
            }
            return opp;
        }
        else        
        	return null;
    }
    
//Wrapper Class
    public class Attendee {
        
         public String Id {
            get; set;
        }
        
        ParticipantListProcessingController Controller;
        
        public CampaignMember CM {get; set;}
        public Decimal Hours {get; set;}
        public String Comments {get; set;}
        public String OriginalStatus {get; set;}
        
        public CampaignMember selected {get; set;}
        
        public Person Person {
            get; set;
        }     
        
        public Opportunity Contribution {get; set;}
        
        public Attendee(ParticipantListProcessingController con) {
           this.Controller = con;
           this.selected = new CampaignMember();
           this.CM = new CampaignMember();
             OriginalStatus = cm.Status;
            this.Contribution = new Opportunity();
            this.Contribution.Supervisor_Satisfaction__c = ParticipantListProcessingController.DefaultRating;
            this.Contribution.Leadership_Level__c = ParticipantListProcessingController.DefaultLeadership;
            this.Contribution.CloseDate = this.Controller.camp.Event_Date_Time__c == null ? system.today() : this.Controller.camp.Event_Date_Time__c.date();
        }
        
        public Attendee(CampaignMember campmmbr) {
            cm = campmmbr;
            OriginalStatus = cm.Status;
            this.Contribution = new Opportunity();
            this.Contribution.Supervisor_Satisfaction__c = ParticipantListProcessingController.DefaultRating;
            this.Contribution.Leadership_Level__c = ParticipantListProcessingController.DefaultLeadership;
        }
        
        public void preAddToList() {
            this.Controller.account.newContactForm = false;
        }
        
        public void addToList() {
            if(String.isNotBlank(this.Id)) {
                this.Person = new Person(this.Id, null);                     
                
                List<CampaignMember> check = Database.query('SELECT Id, Processed__c FROM CampaignMember WHERE ' + this.Person.Type + 'Id = \'' + this.Id + '\' AND ' +
                                                            'CampaignId = \'' + this.Controller.Camp.Id + '\'');
                                 
                if (check.size() == 0) {
                     this.CM = new CampaignMember();
                    
                     if(this.Person.Type == 'Lead')
                         this.CM.LeadId = this.Id;
                     else
                        this.CM.ContactId = this.Id;
                     
                     this.CM.CampaignId = this.Controller.Camp.Id;
                     this.CM.Status = 'Attended';
                     
                     insert this.CM;   
                    
                     this.CM = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.AccountId, ContactId, Lead.FirstName, Lead.LastName, Status, Lead.IsConverted, LeadId, Role__c
                                FROM CampaignMember WHERE Id = :this.CM.Id];
                    
                    this.Controller.addCMToList(this.CM);
                }
                else
                {                    
                    CampaignMember check_cm = check[0];
                    
                    if(check_cm.Processed__c)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'That campaign member has already been processed. If you want to process them again, or un-process them, go to the campaign member list, edit them, and remove the check in the "Processed" check box.'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign Member is already in this list.'));
                    
                    
                    this.Controller.formatsRSVPedList();
                }
             }
         }
        
        public void insertCM(){
            
        }
        
        public void deleteCM() {
            delete this.selected;
            
            this.Controller.SetRSVP();
        }
    }
    
    public class AccountController  {
        ParticipantListProcessingController Controller;
        
        public String Id {
            get; set;
        }
        
        public Boolean newContactForm {
            get; set;
        }   
                
        public Contact newContact {
            get; set;
        }   

        public AccountController(ParticipantListProcessingController con) {
            this.Controller = con;
        } 
        
        public void addNewContact() {
            this.newContact = new Contact();
            this.newContactForm = true;
                   
            this.id = null;
        }
        
        public void SaveContact() {
            Account a = new Account();
            
            if(String.isBlank(this.Id)) { // Create Account
                enterAccountContact eac = new enterAccountContact(new ApexPages.StandardController(new Account()));
                eac.ctct = this.newContact;
                // JOSE, IS THERE A WAY WE CAN PULL THE FAMILY RECORDTYPE ONCE ABOVE AND REFERENCE IT HERE?
                // I TRIED BUT GET "NO FIELD NAMED FAMILYRTID"
                //eac.acct.recordtypeID = [select id from RecordType where Name = 'Family'][0].id; // Family
                // The eac.setAccount() ought to set the account record type
                eac.setAccount();
                system.debug('eac.acct is ' + eac.acct);
                a = eac.acct;
                
                insert a;
            }
            else
                a.Id = this.Id; 
            
            this.newContact.AccountId = a.Id;
            
            insert this.newContact;
            
            CampaignMember cm = new CampaignMember();          
            cm.ContactId =  this.newContact.Id;            
            cm.CampaignId = this.Controller.Camp.Id;
            cm.Status = 'Attended';
            
            insert cm;
            
            cm.Contact = this.newContact;
                        
            this.newContactForm = false;
                       
            this.Controller.addCMToList(cm);
        }
        
         public void cancelContact() {
            this.newContactForm = false;
        }
            }  
        
        public PageReference DisplayNoCAmpaignWarning() {               
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Error: Not sure which Campaign to use.  Please send a copy of this message to support@watergrass.org.');
            ApexPages.addMessage(myMsg);
            return null;
        }
}