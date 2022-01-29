/**
 * Created by Baird on 5/17/2021.
 */

@IsTest
private class VolPortalURLComponentTEST {
    @IsTest
    static void testBehavior() {
        List<Site> TestSites = [SELECT Subdomain,UrlPathPrefix,Name FROM Site];
        system.debug('TestSites is ' + TestSites);
        string TestString = testsites[0].Name;
        VolPortalURLComponent VPUC = new VolPortalURLComponent();
        string result = VPUC.getSiteURL();
        system.debug('Resulting SiteURL is ' + result);
    }
}