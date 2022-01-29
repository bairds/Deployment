public class updateCampaignMemberStatusClass {
    public static void UpdateCMStatus(Id contact, Id campaign, Decimal amount) {
        // Retrieve campaign member record for this primary contributor and campaign.
        // CampaignMember[] cml = [select c.Status, c.ContactId, c.CampaignId from CampaignMember c where c.ContactId = :contact and c.CampaignId = :campaign and c.HasResponded=false];
        List<CampaignMember> cml = [select c.Status, c.ContactId, c.CampaignId from CampaignMember c where c.ContactId = :contact and c.CampaignId = :campaign and c.HasResponded=false];
        
            // Check to see if any campaign members were returned.
        if(cml.size() > 0) {            
            CampaignMember cm = cml[0];       
            if(amount != null) {
                cm.Status = 'Donated';
            } else {
                cm.Status = 'Completed';
            }
            system.debug('CM status is set to ' + cm.Status);                
            update cm;
        }    
    }
    
    public static void updateCampaignMemberStatus(Id contactMember, Id contactCampaign, String newStatusLabel) {
        // Retrieve campaign member record for this primary contributor and campaign.
        CampaignMember[] cml = [select c.Status, c.ContactId, c.CampaignId from CampaignMember c where c.ContactId = :contactMember and c.CampaignId = :contactCampaign and c.HasResponded=false];
        
            // Check to see if any campaign members were returned.
        if(cml.size() > 0) {            
            CampaignMember cm = cml[0];
            
            cm.Status = newStatusLabel;
                            
            update cm;
        }    
    }
    
    public static void updateCampaignMemberStatusWithCheck(Id contactMember, Id contactCampaign, String newStatus, Set<String> statusValues) {
        // Same as the function above.  The difference is that this function will check the existing campaign 
        // member status against the list of values passed in before updating the campaign member status.
        CampaignMember[] cm = [select c.Status, c.ContactId, c.CampaignId from CampaignMember c where c.ContactId = :contactMember and c.CampaignId = :contactCampaign];
        
        // Check to see if any campaign members were returned.
        if(!cm.isEmpty()) {
            for(Integer i =0; i<cm.size(); i++) {
                // Check to see if the campaign member status value is contained within the list of values passed into this method.
                if(statusValues.contains(cm[i].Status)) {
                    cm[i].Status=newStatus;
                }
            }
            update cm;
        }       
    }
}