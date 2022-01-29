/**
 * Created by Baird on 5/17/2021.
 */

global with sharing class VolPortalURLComponent {
    global String SiteURL;
    global String VToken {get;set;}
    global String RecipId {get;set;}
    global String SiteName {get;set;}

    global String getSiteURL(){
        List<Site> SignupSites;
            SignupSites = [SELECT Subdomain, UrlPathPrefix FROM Site where name = :SiteName];
        if (SignupSites.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Could not find a Site named ' + SiteName));
            return null;
        } else {
            /*
        if ([SELECT isSandbox from Organization].IsSandbox){
            SiteURL = 'https://' + SignupSite[0].Subdomain + '.secure.force.com/VolPortal?cid=' +
                    RecipId + '&VToken=' + VToken;
        } else {
            String EditionType = [SELECT OrganizationType FROM Organization].OrganizationType;
            if (EditionType == 'Developer Edition') {
                SiteURL = 'https://' + SignupSite[0].Subdomain + '.secure.force.com/VolPortal?cid=' +
                    RecipId + '&VToken=' + VToken;
            } else {
                SiteURL = 'https://' + SignupSite[0].Subdomain + '.secure.force.com/VolPortal?cid=' +
                        RecipId + '&VToken=' + VToken;
            }
        }
        */
            SiteURL = 'https://' + SignupSites[0].Subdomain + '.secure.force.com/VolPortal?cid=' +
                    RecipId + '&VToken=' + VToken;
            return SiteURL;
        }
    }

}