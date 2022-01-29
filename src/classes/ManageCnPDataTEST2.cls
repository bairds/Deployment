// 18 June 2015. Accepts eChecks.  Inserts orderItem.CampaignName as campaign if it exists.  Avoids matching on email=null.  
//      Escapes all apostrophes which exist in the CnP DataXML object.
// 11 June 2015.  Added test for Virtual Terminal, when the email is blank.
// Version of 27 Oct 2014, Baird.  Added test for "Dinner Attendee" as well as "Event Attendee"
// Version of 29 Sept 2015, Baird.  Changed test for stripping data to check for the CnP data stripping rather than
// the WAterGrass version.  Removed the WaterGrass beforeInsert() trigger.  CnP now strips the middle 8 digits of a credit card number.
// Version of 20 Nov 2015.  Baird and Peter add .tolowercase() to avoid campaigns being missed because of capitalization errors in the Virtual Terminal.
// // 15 DEC 2015.  SECTION ADDED TO test DataXML FROM THE CONNECT APPLICATION.
// 14 Aug 2016 ConvertLead() to handle conversion of leads while inserting Dear__c and Attendee__c
// 1 Sept 2016 Amended to accepted SKU's with the the RecordType anywhere in the SKU.
// 15 Nov added code to catch Connect CampaignIds, to identify recurring donations, added GravityForms code
// 29 July switch to CnPData__c object, catch errors with bad campaign Ids coming from CnP.
// Nov 2021 Split the original test into 2 parts.  This is the second.
@isTest
private class ManageCnPDataTEST2 {

    // single transaction test with recurring, existing contact, campaign specified, installments=999
    // periodicity "6 Months"
    @isTest
    static void SingleRecurringDonationTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;


        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Test Membership Campaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>1.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMlstring += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringID>47212</RecurringID>';
        XMlstring += '<MasterTransactionNumber>1307101607584781111</MasterTransactionNumber><Installments>999</Installments>';
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>6 Months</Periodicity>';
        XMlstring += '<InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>1.00</InstallmentAmount><TotalAmount>1.00</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>1.00</TotalMade><TotalDue>2.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Recurring Donation</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Donation</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];

        //Has TestData credit card # and expiration date been masked?
        Dom.Document docx = new Dom.Document();
        docx.load(TestDataUpdated.DataXML__c);

        // Has one donation and one pledge been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
                CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
                Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id order by Amount];
        // Two opps created - the pledge and the payment
        system.AssertEquals(2,Payments.size());
        // Is the pledge amount = null and pledge_amount__c = 3 and Number_Installments__c = 3
        system.AssertEquals(null,Payments[0].amount);
        system.Assert(Payments[0].name.CONTAINS('Recurring Payment begun on'),'Installments is 999 so this should be a recurring payment not a pledge.');
        System.assertEquals(0,Payments[0].Pledge_Amount__c,'Installments is 999 so this should be a recurring payment without a pledge amount.');
        // Is the payment amount = 1 and the pledge_amount__c = null and recordType "Donation" and Intallment Number 1?
        system.AssertEquals(1,Payments[1].amount);
        system.AssertEquals(null,Payments[1].pledge_amount__c);
        System.assertEquals('Donation',Payments[1].recordtype.name);
        System.assertEquals(1.0,Payments[1].installment_nr__c);
        // Do the two IDs match for the pledge and payment?
        System.assertEquals(Payments[0].id,Payments[1].Matches_Which_Challenge_or_Pledge__c);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestMemberCamp.ID,Payments[0].CampaignId);
    }

// recurring transaction test with existing contact, campaign specified, through Gravity Forms
    @isTest
    static void SingleContactTransactionGravityFormsTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><PostedDateTime>2016-11-15 08:55:24</PostedDateTime>';
        XMLstring += '<Application><ID>CnP_PaaS_FM_GravityForm</ID><Name>CnP_PaaS_FM_GravityForm</Name><Version>3.400.000/WP:v4.6.1/GF:v2.1.1</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron><BillingInformation><BillingFirstName>Test</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestContact</BillingLastName>';
        XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail><BillingPhone>(217) 344-2371</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>1902 Fox Drive</BillingAddress1>';
        XMLstring += '<BillingCity>Champaign</BillingCity><BillingStateProvince>IL</BillingStateProvince><BillingPostalCode>61820</BillingPostalCode><BillingCountryName></BillingCountryName></BillingAddress></Patron>';
        XMLstring += '<TransactionDetail><OrderNumber>1611150855085977266</OrderNumber><ReceiptNumber></ReceiptNumber><TransactionID>6018541</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode><Campaign>Testcampaign</Campaign><TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationName>Prairie Rivers Network</OrganizationName><CurrencyCode>840</CurrencyCode><AuthorizationCode>834326</AuthorizationCode>';
        XMLstring += '<WindowId>-1</WindowId><GatewayTransactionNumber>978313298</GatewayTransactionNumber><TotalCharge>5.00</TotalCharge><TotalDue>5.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge><DeductibleDue>0.00</DeductibleDue><DiscountCharge>0.00</DiscountCharge><DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge><TaxAmountDue>0.00</TaxAmountDue><TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue><TransactionTaxCharge>0.00</TransactionTaxCharge><TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge><ChargAmount>0.15</ChargAmount><CouponCode></CouponCode><TransactionDate>2016-11-15 08:55:08</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2016-11-15 01:55:08</TransactionTimeZone><UrlReferrer>https://prairierivers.org/monarch/</UrlReferrer><VaultGUID>a1321af3-a758-4dc2-970b-96fb2256489f</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard><NameOnCard>Vickie Nudelman</NameOnCard><CardNumber>XXXXXXX</CardNumber>';
        XMLstring += '<CardName>VISA</CardName><ExpirationDate>1801</ExpirationDate></CreditCard></PaymentMethod>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringStatus>Active</RecurringStatus><RecurringID>224657</RecurringID>';
        XMLstring += '<RecurringIDUpdate></RecurringIDUpdate><MasterTransactionNumber>1611150855085977266</MasterTransactionNumber><MasterTransactionDate>2016-11-15 01:55:08</MasterTransactionDate>';
        XMLstring += '<Installments>999</Installments><ToDateRemainingInstallments>998</ToDateRemainingInstallments><RecurringMethod>Subscription</RecurringMethod>';
        XMLstring += '<Periodicity>Monthly</Periodicity><InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2016-12-15 08:55:00</NextInstallmentDate>';
        XMLstring += '<InstallmentAmount>5.00</InstallmentAmount><TotalAmount>5.00</TotalAmount><TotalCommitted>4995.00</TotalCommitted><TotalMade>5.00</TotalMade>';
        XMLstring += '<TotalDue>4990.00</TotalDue></Recurring>';
        XMLstring += '<CustomFieldList><CustomField><FieldName>Memorial gift or other special instructions?</FieldName>';
        XMLstring += '<FieldValue>$5 monthly test donation</FieldValue></CustomField><CustomField><FieldName>Would you like a set of 12 notecards featuring 6 landscapes from around Illinois?</FieldName>';
        XMLstring += '<FieldValue>Yes.</FieldValue></CustomField><CustomField><FieldName>Payment type</FieldName><FieldValue>Credit Card</FieldValue>';
        XMLstring += '</CustomField></CustomFieldList>';
        XMLstring += '<OrderItemList><OrderItem><ItemID>101101</ItemID><ItemName>Select Your Monthly Donation Amount ($5)</ItemName><Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>5</UnitPriceCharge><UnitPriceDue>5</UnitPriceDue><UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge><DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>RT_Membership-$5</SKU></OrderItem></OrderItemList>';
        XMLstring += '</CnPTransactionData>';



        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];

        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(2,Payments.size());
        system.AssertEquals(null,Payments[0].amount);
        system.AssertEquals(5,Payments[1].amount);
        //system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        //system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.AssertEquals('Recurring Payment begun on ' + System.today().format(),Payments[0].Name);
    }

    static testmethod void GiftMembershipWithTransactionCampaign() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        system.assertEquals(testAcct.Id, testCtct.AccountId);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Testcampaign';
        update testMemberCamp;


        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>1612021526446747266</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>6144849</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<Campaign>Testcampaign</Campaign>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>25820</OrganizationID>';
        XMLstring += '<OrganizationName>Prairie Rivers Network</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>217183</AuthorizationCode>';
        XMLstring += '<WindowName></WindowName>';
        XMLstring += '<WindowId>-1</WindowId>';
        XMLstring += '<GatewayTransactionNumber>987423287</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>2.05</TotalCharge>';
        XMLstring += '<TotalDue>2.05</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>0.06</ChargAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2016-12-02 15:26:44</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2016-12-02 08:26:44</TransactionTimeZone>';
        XMLstring += '<UrlReferrer>https://prairierivers.org/gift/</UrlReferrer>';
        XMLstring += '<VaultGUID>9ddb27c0-8ab0-4d8b-957f-8ba5c3fd4ff0</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Vickie Nudelman</NameOnCard>';
        XMLstring += '<CardNumber>44187266</CardNumber>';
        XMLstring += '<CardName>VISA</CardName>';
        XMLstring += '<ExpirationDate>1801</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Gift Membership Recipient:</FieldName>';
        XMLstring += '<FieldValue>Final test of gift membership page.</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Payment type</FieldName>';
        XMLstring += '<FieldValue>Credit Card</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>101101</ItemID>';
        XMLstring += '<ItemName>Other Amount</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>2.05</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>2.05</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Membership</SKU>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '</CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1611301022402635092',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];

        //Has TestData credit card # and expiration date been masked?
        Dom.Document docx = new Dom.Document();
        docx.load(TestDataUpdated.DataXML__c);

        dom.XmlNode xroot = docx.getrootelement() ;
        dom.XmlNode xr2 = xroot.getchildelement('TransactionDetail', null) ; //Level 2
        dom.XmlNode xr2paymentmethod = xr2.getchildelement('PaymentMethod', null) ; //
        dom.XmlNode xr2paymentmethodCC = xr2paymentmethod.getchildelement('CreditCard', null) ; //
        dom.XmlNode xr2paymentmethodCCName = xr2paymentmethodCC.getchildelement('CardName', null) ; //
        dom.XmlNode xr2paymentmethodCCNr = xr2paymentmethodCC.getchildelement('CardNumber', null) ; //
        dom.XmlNode xr2paymentmethodCCExp = xr2paymentmethodCC.getchildelement('ExpirationDate', null) ; //
        dom.XmlNode xrrecurring = xroot.getchildelement('Recurring', null) ; //

        system.debug('xr2paymentmethodCCName.getText() is ' + xr2paymentmethodCCName.getText());
        system.debug('xr2paymentmethodCCExp.gettext() is ' + xr2paymentmethodCCExp.gettext());
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '44187266');

        // Has one donation been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
                CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
                Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id order by Amount];

        system.AssertEquals(1,Payments.size());
        system.AssertEquals(2.05,Payments[0].amount);

    } // end MembershipTestWithTransactionCampaign

    static testMethod void ConnectWhyGenericCampaign() {
        // Teststring from MRK, why isn't the campaign found?
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', TestCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2016-12-07 13:40:52</PostedDateTime>';
        XMLstring += '<Application><Name>Connect.Forms</Name>';
        XMLstring += '<Version>1.5</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Abby</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>Kuranz</BillingLastName>';
        XMLstring += '<BillingEmail>akuranz@gmail.com</BillingEmail>';
        XMLstring += '<BillingPhone>2626728857</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>1487 N Farwell Ave, Apt M</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>Milwaukee</BillingCity>';
        XMLstring += '<BillingStateProvince>Wisconsin</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>53202</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '<CustomParameters><Parameter>';
        XMLstring += '<Field>SocialComment</Field>';
        XMLstring += '<Value></Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>SocialCommentStatus</Field>';
        XMLstring += '<Value>1</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters>';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>1612071340381417740</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>6164766</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<Campaign></Campaign>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>26913</OrganizationID>';
        XMLstring += '<OrganizationName>Milwaukee Riverkeeper</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>733214</AuthorizationCode>';
        XMLstring += '<WindowName>2016 Year End Appeal CnP</WindowName>';
        XMLstring += '<WindowId>cd13251e-cd09-4695-9bf8-e659cea16cd7</WindowId>';
        XMLstring += '<GatewayTransactionNumber>989733214</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>1.00</TotalCharge>';
        XMLstring += '<TotalDue>1.00</TotalDue>';
        XMLstring += '<DeductibleCharge>1.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>1.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>0.18</ChargAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2016-12-07 13:40:38</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2016-12-07 12:40:38</TransactionTimeZone>';
        XMLstring += '<UrlReferrer></UrlReferrer>';
        XMLstring += '<VaultGUID>f83bf4e9-3a1d-4172-afc9-89b8398c7543</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Abby Kuranz</NameOnCard>';
        XMLstring += '<CardNumber>45357740</CardNumber>';
        XMLstring += '<CardName>VISA</CardName>';
        XMLstring += '<ExpirationDate>1805</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
        XMLstring += '<CampaignID>36332</CampaignID>';
        XMLstring += '<AccountID>26913</AccountID>';
        XMLstring += '<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring += '<CampaignScope>Transaction</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '<CustomParameters><Parameter>';
        XMLstring += '<Field>GiveBigCampaignId</Field>';
        XMLstring += '<Value>36327</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>PostItID</Field>';
        XMLstring += '<Value>0</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>PostItAlias</Field>';
        XMLstring += '<Value></Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>PaymentWidgetID</Field>';
        XMLstring += '<Value>2783</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>Pay09</Field>';
        XMLstring += '<Value>Site.20161207.002.004.010</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>0</ItemID>';
        XMLstring += '<ItemName>Other</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>1</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>1</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU></SKU>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '</CnPTransactionData>';


        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);


        WG_CnPData__c TestData2 = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207131327206181111');
        insert testdata2;

        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Attendee__c
        from Opportunity ];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(1.00,Payments[0].amount);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
    } // end test

// single transaction test with existing contact, campaign specified in orderItem
    static testmethod void SingleContactTransactionCampaignCnPConnectTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring+='<CnPTransactionData><Version>40</Version>';
        XMLstring+='<PostedDateTime>2017-12-27 13:23:23</PostedDateTime>';
        XMLstring+='<Application><Name>Connect.Forms</Name>';
        XMLstring+='<Version>1.5</Version>';
        XMLstring+='</Application>';
        XMLstring+='<Patron>';
        XMLstring+='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring+='<BillingMI>E</BillingMI>';
        XMLstring+='<BillingLastName>TestContact</BillingLastName>';
        XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring+='<BillingPhone>16109458795</BillingPhone>';
        XMLstring+='</BillingInformation>';
        XMLstring+='<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring+='<BillingAddress2></BillingAddress2>';
        XMLstring+='<BillingAddress3></BillingAddress3>';
        XMLstring+='<BillingCity>Media</BillingCity>';
        XMLstring+='<BillingStateProvince>Pennsylvania</BillingStateProvince>';
        XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
        XMLstring+='<BillingCountryName>United States</BillingCountryName>';
        XMLstring+='</BillingAddress>';
        XMLstring+='<CustomParameters><Parameter>';
        XMLstring+='<Field>SocialComment</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>SocialCommentStatus</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters>';
        XMLstring+='</Patron>';
        XMLstring+='<TransactionDetail>';
        XMLstring+='<OrderNumber>28702-1712271323147429925</OrderNumber>';
        XMLstring+='<ReceiptNumber></ReceiptNumber>';
        XMLstring+='<TransactionID>8063294</TransactionID>';
        XMLstring+='<OrderMode>Live</OrderMode>';
        XMLstring+='<Tracker></Tracker>';
        XMLstring+='<Campaign></Campaign>';
        XMLstring+='<ConnectCampaignAlias>MembershipsOnline</ConnectCampaignAlias>';
        XMLstring+='<TransactionType>Live</TransactionType>';
        XMLstring+='<OrganizationID>28702</OrganizationID>';
        XMLstring+='<OrganizationName>ShoreRivers, Inc.</OrganizationName>';
        XMLstring+='<CurrencyCode>840</CurrencyCode>';
        XMLstring+='<AuthorizationCode>07086D</AuthorizationCode>';
        XMLstring+='<WindowName>Membership</WindowName>';
        XMLstring+='<WindowId>4a10a15c-d022-4621-8bdd-e1523ec866d0</WindowId>';
        XMLstring+='<GatewayTransactionNumber>1204763005</GatewayTransactionNumber>';
        XMLstring+='<TotalCharge>500.00</TotalCharge>';
        XMLstring+='<TotalDue>500.00</TotalDue>';
        XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
        XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
        XMLstring+='<DiscountDue>0.00</DiscountDue>';
        XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring+='<SurCharge>0.00</SurCharge>';
        XMLstring+='<ChargAmount>13.90</ChargAmount>';
        XMLstring+='<CouponCode></CouponCode>';
        XMLstring+='<TransactionDate>2017-12-27 13:23:14</TransactionDate>';
        XMLstring+='<TransactionTimeZone>2017-12-27 13:23:14</TransactionTimeZone>';
        XMLstring+='<UrlReferrer></UrlReferrer>';
        XMLstring+='<VaultGUID>b609e06c-89b0-4af0-bef6-98ad9de0b7bf</VaultGUID>';
        XMLstring+='<TransactionResult>Authorized</TransactionResult>';
        XMLstring+='<PaymentMethod>';
        XMLstring+='<PaymentType>Credit Card</PaymentType>';
        XMLstring+='<CreditCard>';
        XMLstring+='<NameOnCard>Paul Edward Schlenker</NameOnCard>';
        XMLstring+='<CardNumber>42649925</CardNumber>';
        XMLstring+='<CardName>VISA</CardName>';
        XMLstring+='<ExpirationDate>2011</ExpirationDate>';
        XMLstring+='</CreditCard>';
        XMLstring+='</PaymentMethod>';
        XMLstring+='<CampaignList><CampaignNode>';
        XMLstring+='<CampaignName>Testcampaign</CampaignName>';
        XMLstring+='<CampaignID>50244</CampaignID>';
        XMLstring+='<AccountID>28702</AccountID>';
        XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring+='<CampaignScope>Transaction</CampaignScope>';
        XMLstring+='</CampaignNode>';
        XMLstring+='</CampaignList>';
        XMLstring+='<CustomParameters><Parameter>';
        XMLstring+='<Field>GiveBigCampaignId</Field>';
        XMLstring+='<Value>50240</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItID</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItAlias</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PaymentWidgetID</Field>';
        XMLstring+='<Value>9752</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>Pay-04</Field>';
        XMLstring+='<Value>Site.20171219.002.018.004</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters>';
        XMLstring+='</TransactionDetail>';
        XMLstring+='<CustomFieldList>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>Which watershed are you most interested in?</FieldName>';
        XMLstring+='<FieldValue>Sassafras River</FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>Would you like your donation to go toward a specific program, project or river? If so, please indicate below.</FieldName>';
        XMLstring+='<FieldValue>Sassafras River</FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>Would you like to volunteer with us? Select a volunteer opportunity below.</FieldName>';
        XMLstring+='<FieldValue>Select</FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>COMMENTS</FieldName>';
        XMLstring+='<FieldValue></FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='</CustomFieldList>';
        XMLstring+='<OrderItemList>';
        XMLstring+='<OrderItem>';
        XMLstring+='<ItemID>0</ItemID>';
        XMLstring+='<ItemName>Sustaining Member - 500</ItemName>';
        XMLstring+='<Quantity>1</Quantity>';
        XMLstring+='<UnitPriceCharge>500</UnitPriceCharge>';
        XMLstring+='<UnitPriceDue>500</UnitPriceDue>';
        XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
        XMLstring+='<DiscountCharge>0</DiscountCharge>';
        XMLstring+='<DiscountDue>0</DiscountDue>';
        XMLstring+='<SKU>MembershipMembershipMemberships Online</SKU>';
        XMLstring+='</OrderItem>';
        XMLstring+='</OrderItemList>';
        XMLstring+='</CnPTransactionData>';

        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        WG_CnPData__c TestData2 = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207131327206181111');
        List<WG_CnPData__c> ListTestData = new List<WG_CnPData__c>();
        ListTestData.add(TestData2);
        ManageCnPData MCPDB = new ManageCnPData();
        List<WG_CnPData__c> EmptyDataList = new List<WG_CnPData__c>();
        MCPDB.afterInsert(ListTestData,EmptyDataList);
        system.AssertEquals(TestCamp.Id,MCPDB.OptyCampaignId,'Did not identify correct campaign');
        //system.AssertEquals(TestCamp.name,MCPDB.sOptyCampaignName,'Did not identify correct campaign');
        system.debug('NewOpps is ' + MCPDB.NewOpps);
        Opportunity opp = MCPDB.NewOpps[0];
        system.AssertEquals(opp.Amount,500);
        system.AssertEquals('Credit Card through C&P', opp.Payment_Type__c);

        system.AssertEquals(TestCamp.Id,opp.campaignID);
        system.AssertEquals(TestCtct.Id,opp.contact__c);
        system.AssertEquals(TestAcct.Id,opp.accountID);


        system.AssertEquals('TestContact',MCPDB.scontact.lastname);
        // BAIRD: RESTORE THE NEXT LINE WHEN WE FIGURE OUT WHAT THE PROBLEM IS.
        String teststring = 'Test Street';
        System.assertEquals(teststring,MCPDB.sContact.mailingStreet.left(11),'Address should have been updated from null to Test Street');
        System.assertEquals(true,MCPDB.sContact.mailingStreet.contains(teststring),'Address should have been updated from null to Test Street');
        System.assertEquals('33333', MCPDB.sContact.mailingPostalCode,'PostalCode should have been updated from null to 33333');
    }

// single transaction test with existing contact, campaign specified in orderItem
// SKU blank because CnP leaves SKU blank if amount is "Other" custom amount
// created Mar 16 2018 to handle errors identified by Jaron at SHTA
    static testmethod void RecurringPaymentWithAdditionalCharge() {
        WGHelpers.SAddTransactionFeeTo='Its own contribution';
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);
        // populate WG_Settings
//        populateWGCustomSettings.populateWGSettings();

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring+='<CnPTransactionData><Version>40</Version>';
        XMLstring+='<PostedDateTime>2018-02-13 10:47:19</PostedDateTime>';
        XMLstring+='<Application><Name>Connect.Forms</Name>';
        XMLstring+='<Version>1.5</Version>';
        XMLstring+='</Application>';
        XMLstring+='<Patron>';
        XMLstring+='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring+='<BillingMI></BillingMI>';
        XMLstring+='<BillingLastName>Testcontact</BillingLastName>';
        XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring+='<BillingPhone>218-390-4915</BillingPhone>';
        XMLstring+='</BillingInformation>';
        XMLstring+='<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring+='<BillingAddress2></BillingAddress2>';
        XMLstring+='<BillingAddress3></BillingAddress3>';
        XMLstring+='<BillingCity>Duluth</BillingCity>';
        XMLstring+='<BillingStateProvince>Minnesota</BillingStateProvince>';
        XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
        XMLstring+='<BillingCountryName>United States</BillingCountryName>';
        XMLstring+='</BillingAddress>';
        XMLstring+='<CustomParameters><Parameter>';
        XMLstring+='<Field>SocialComment</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>SocialCommentStatus</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters>';
        XMLstring+='';
        XMLstring+='</Patron>';
        XMLstring+='<TransactionDetail>';
        XMLstring+='<OrderNumber>39196-1802131047104886145</OrderNumber>';
        XMLstring+='<ReceiptNumber></ReceiptNumber>';
        XMLstring+='<TransactionID>8303416</TransactionID>';
        XMLstring+='<OrderMode>Live</OrderMode>';
        XMLstring+='<Tracker></Tracker>';
        XMLstring+='<Campaign></Campaign>';
        XMLstring+='<ConnectCampaignAlias>2018websitegifts</ConnectCampaignAlias>';
        XMLstring+='<TransactionType>Live</TransactionType>';
        XMLstring+='<OrganizationID>39196</OrganizationID>';
        XMLstring+='<OrganizationName>Superior Hiking Trail Association</OrganizationName>';
        XMLstring+='<CurrencyCode>840</CurrencyCode>';
        XMLstring+='<AuthorizationCode>225562</AuthorizationCode>';
        XMLstring+='<WindowName>2018 Website Gifts 8</WindowName>';
        XMLstring+='<WindowId>9d7fca76-5b49-4606-a7d3-9df8972a8cc1</WindowId>';
        XMLstring+='<GatewayTransactionNumber>1233803501</GatewayTransactionNumber>';
        XMLstring+='<TotalCharge>5.54</TotalCharge>';
        XMLstring+='<TotalDue>5.54</TotalDue>';
        XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
        XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
        XMLstring+='<DiscountDue>0.00</DiscountDue>';
        XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring+='<SurCharge>0.00</SurCharge>';
        XMLstring+='<ChargAmount>0.56</ChargAmount>';
        XMLstring+='<CouponCode></CouponCode>';
        XMLstring+='<TransactionDate>2018-02-13 10:47:10</TransactionDate>';
        XMLstring+='<TransactionTimeZone>2018-02-13 09:47:10</TransactionTimeZone>';
        XMLstring+='<UrlReferrer>https://shta.org/donate/</UrlReferrer>';
        XMLstring+='<VaultGUID>8584a5b8-479a-43f8-9a81-54eba21dd051</VaultGUID>';
        XMLstring+='<TransactionResult>Authorized</TransactionResult>';
        XMLstring+='<PaymentMethod>';
        XMLstring+='<PaymentType>Credit Card</PaymentType>';
        XMLstring+='<CreditCard>';
        XMLstring+='<NameOnCard>Test T Testcontact</NameOnCard>';
        XMLstring+='<CardNumber>43336135</CardNumber>';
        XMLstring+='<CardName>VISA</CardName>';
        XMLstring+='<ExpirationDate>1803</ExpirationDate>';
        XMLstring+='</CreditCard>';
        XMLstring+='</PaymentMethod>';
        XMLstring+='';
        XMLstring+='<CampaignList><CampaignNode>';
        XMLstring+='<CampaignName>'+TestCamp.Name+'</CampaignName>';
        XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring+='<CampaignScope>Transaction</CampaignScope>';
        XMLstring+='</CampaignNode>';
        XMLstring+='</CampaignList>';
        XMLstring+='<CustomParameters>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>GiveBigCampaignId</Field>';
        XMLstring+='<Value>49012</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItID</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItAlias</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PaymentWidgetID</Field>';
        XMLstring+='<Value>10935</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>Pay-02</Field>';
        XMLstring+='<Value>Site.20180207.002.018.010</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters></TransactionDetail>';
        XMLstring+='<Recurring>';
        XMLstring+='<TransactionResult>Authorized</TransactionResult>';
        XMLstring+='<RecurringStatus>Active</RecurringStatus>';
        XMLstring+='<RecurringID>319266</RecurringID>';
        XMLstring+='<RecurringIDUpdate></RecurringIDUpdate>';
        XMLstring+='<MasterTransactionNumber>39196-1802131047104886145</MasterTransactionNumber>';
        XMLstring+='<MasterTransactionDate>2018-02-13 09:47:10</MasterTransactionDate>';
        XMLstring+='<Installments>999</Installments>';
        XMLstring+='<ToDateRemainingInstallments>998</ToDateRemainingInstallments>';
        XMLstring+='<RecurringMethod>Subscription</RecurringMethod>';
        XMLstring+='<Periodicity>Monthly</Periodicity>';
        XMLstring+='<InstallmentNumber>1</InstallmentNumber>';
        XMLstring+='<NextInstallmentDate>2018-03-13 09:47:00</NextInstallmentDate>';
        XMLstring+='<InstallmentAmount>5.54</InstallmentAmount>';
        XMLstring+='<TotalAmount>5.54</TotalAmount>';
        XMLstring+='<TotalCommitted>5534.46</TotalCommitted>';
        XMLstring+='<TotalMade>5.54</TotalMade>';
        XMLstring+='<TotalDue>5528.92</TotalDue>';
        XMLstring+='';
        XMLstring+='</Recurring>';
        XMLstring+='<CustomFieldList>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>Please provide the name and address of the recipient.</FieldName>';
        XMLstring+='<FieldValue></FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='';
        XMLstring+='</CustomFieldList>';
        XMLstring+='<OrderItemList>';
        XMLstring+='<OrderItem>';
        XMLstring+='<ItemID>0</ItemID>';
        XMLstring+='<ItemName>Generic Donation</ItemName>';
        XMLstring+='<Quantity>1</Quantity>';
        XMLstring+='<UnitPriceCharge>5</UnitPriceCharge>';
        XMLstring+='<UnitPriceDue>5</UnitPriceDue>';
        XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
        XMLstring+='<DiscountCharge>0</DiscountCharge>';
        XMLstring+='<DiscountDue>0</DiscountDue>';
        XMLstring+='<SKU>WrongDonationType</SKU>';
        XMLstring+='</OrderItem>';
        XMLstring+='<OrderItem>';
        XMLstring+='<ItemID>1</ItemID>';
        XMLstring+='<ItemName>Additional Fee</ItemName>';
        XMLstring+='<Quantity>1</Quantity>';
        XMLstring+='<UnitPriceCharge>0.54</UnitPriceCharge>';
        XMLstring+='<UnitPriceDue>0.54</UnitPriceDue>';
        XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
        XMLstring+='<DiscountCharge>0</DiscountCharge>';
        XMLstring+='<DiscountDue>0</DiscountDue>';
        XMLstring+='<SKU></SKU>';
        XMLstring+='<CampaignList><CampaignNode>';
        XMLstring+='<CampaignName>'+TestCamp.Name+'</CampaignName>';
        XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring+='<CampaignScope>Transaction</CampaignScope>';
        XMLstring+='</CampaignNode>';
        XMLstring+='</CampaignList>';
        XMLstring+='</OrderItem>';
        XMLstring+='';
        XMLstring+='</OrderItemList>';
        XMLstring+='</CnPTransactionData>';

        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        WG_CnPData__c TestData2 = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207131327206181111');
        List<WG_CnPData__c> ListTestData = new List<WG_CnPData__c>();
        ListTestData.add(TestData2);
        ManageCnPData MCPDB = new ManageCnPData();
        MCPDB.afterInsert(ListTestData,null);
        // system.debug('TestCamp.Name is ' + TestCamp.Name + ', MCPDB.OptyCampaignName is ' + [SELECT name from Campaign where id =: MCPDB.OptyCampaignId].Name);
        system.AssertEquals(TestCamp.Id,MCPDB.OptyCampaignId,'Did not identify correct campaign');
        system.debug('NewOpps is ' + MCPDB.NewOpps);
        system.assertEquals(2,MCPDB.NewOpps.size(),'Should be 2 Opps - a payment of 5.54 which serves as the Master, and a payment of .54');
        Opportunity opp = MCPDB.NewOpps[0];
        // The first payment records an amount of 5.00
        system.AssertEquals(5,opp.Amount);
        system.AssertEquals('Credit Card through C&P', opp.Payment_Type__c);
        // The first payment is 5.00
        system.assertEquals(.54,MCPDB.NewOpps[1].Amount,'Second opp created should be $.54 payment for processing fee.');

        system.AssertEquals(TestCamp.Id,opp.campaignID);
        system.AssertEquals(TestCtct.Id,opp.contact__c);
        system.AssertEquals(TestAcct.Id,opp.accountID);

        system.AssertEquals('TestContact',MCPDB.scontact.lastname);
        String teststring = 'Test Street';
        System.assertEquals(teststring,MCPDB.sContact.mailingStreet.left(11),'Address should have been updated from null to Test Street');
        System.assertEquals(true,MCPDB.sContact.mailingStreet.contains(teststring),'Address should have been updated from null to Test Street');
        System.assertEquals('33333', MCPDB.sContact.mailingPostalCode,'PostalCode should have been updated from null to 33333');
        // TEST THAT ADDITIONAL FEE DOESN'T RESULT IN DUPLICATE DONATION
        System.assertEquals(2,MCPDB.newOpps.size(),'Should have been two order items');
        System.assertEquals(5.54,MCPDB.NewOpps[0].amount + MCPDB.NewOpps[1].amount,'Two item amounts should equal total paid amount');

        // Has only one pledge been created?
        List<Opportunity> TestPledges = [select id, Installment_Amount__c from Opportunity where recordType.Name = 'Pledge'];
        system.assertEquals(1,TestPledges.size(),'The DATAXML had two orderitems but should only have created one pledge.');
        system.assertEquals(5.54,TestPledges[0].Installment_Amount__c,'Pledge.Installment_Amount__c should come from parseresults.installmentamount.');
    }

    @isTest
    static void SingleLeadWithLeadSource() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Lead TestLead = ctv.fetchTestLead();
        system.assertEquals('TestLead', testLead.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        TestCamp.name = 'Reviving the Dream (2017)';
        update TestCamp;


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2017-03-28 12:47:32</PostedDateTime>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestLead</BillingLastName>';
        XMLstring += '<BillingEmail>testlead@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>414-312-3507</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>2972 S Wentworth Ave</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>Milwaukee</BillingCity>';
        XMLstring += '<BillingStateProvince>Wisconsin</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>53207</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>1703281247192266546</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>6702087</TransactionID>';
        XMLstring += '<OrderMode>Test</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<Campaign>Reviving the Dream (2017)</Campaign>';
        XMLstring += '<ConnectCampaignAlias></ConnectCampaignAlias>';
        XMLstring += '<TransactionType>Test</TransactionType>';
        XMLstring += '<OrganizationID>29024</OrganizationID>';
        XMLstring += '<OrganizationName>Diverse and Resilient</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>9f0630</AuthorizationCode>';
        XMLstring += '<WindowName>Reviving the Dream 2017</WindowName>';
        XMLstring += '<WindowId>126411</WindowId>';
        XMLstring += '<GatewayTransactionNumber>24fb7302-8c6b-4030-94e0-ccd128a2b788</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>100.00</TotalCharge>';
        XMLstring += '<TotalDue>100.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>3.10</ChargAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2017-03-28 12:47:00</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2017-03-28 11:47:00</TransactionTimeZone>';
        XMLstring += '<UrlReferrer>https://www.diverseandresilient.org/reviving/</UrlReferrer>';
        XMLstring += '<VaultGUID></VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>MORGAN J TILLEMAN</NameOnCard>';
        XMLstring += '<CardNumber>41476546</CardNumber>';
        XMLstring += '<CardName>VISA</CardName>';
        XMLstring += '<ExpirationDate>1908</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>In honor of:</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your meal preference?</FieldName>';
        XMLstring += '<FieldValue>Chicken Entrée</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName>';
        XMLstring += '<FieldValue>Web</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>What is your guests name?</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>0</ItemID>';
        XMLstring += '<ItemName>Individual Ticket</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>100</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>100</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '</CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];

        //Has TestData credit card # and expiration date been masked?
        Dom.Document docx = new Dom.Document();
        docx.load(TestDataUpdated.DataXML__c);

        dom.XmlNode xroot = docx.getrootelement() ;
        dom.XmlNode xr2 = xroot.getchildelement('TransactionDetail', null) ; //Level 2
        dom.XmlNode xr2paymentmethod = xr2.getchildelement('PaymentMethod', null) ; //
        dom.XmlNode xr2paymentmethodCC = xr2paymentmethod.getchildelement('CreditCard', null) ; //
        dom.XmlNode xr2paymentmethodCCName = xr2paymentmethodCC.getchildelement('CardName', null) ; //
        dom.XmlNode xr2paymentmethodCCNr = xr2paymentmethodCC.getchildelement('CardNumber', null) ; //
        dom.XmlNode xr2paymentmethodCCExp = xr2paymentmethodCC.getchildelement('ExpirationDate', null) ; //
        system.debug('xr2paymentmethodCCName.getText() is ' + xr2paymentmethodCCName.getText());
        system.debug('xr2paymentmethodCCExp.gettext() is ' + xr2paymentmethodCCExp.gettext());
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41476546');

        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
        from Opportunity where campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(100,Payments[0].amount);
        //system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCamp.Name, Payments[0].Campaign.Name);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        //  system.AssertEquals('Event Attendee-Tester TestContact for Testcampaign paid on ' + String.valueOf(System.today()),Payments[0].Name);
        //  System.assertEquals('Tester TestContact',Payments[0].attendee__c);
        Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode, leadsource,
                account.billingCity, account.ShippingState, account.dear__c, account.addressee__c
        from Contact where id = :Payments[0].contact__c];
        system.AssertEquals('TestLead',checkContact.lastname);
        system.AssertEquals('Web',checkContact.leadsource);
    }
    @istest
    static void BadCampaignId() {
        // Create test string, this time with campaign in campaign node format as per Connect Donation
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        TestCamp.name = 'Membership Renewal';
        update TestCamp;
        system.assertEquals('Membership Renewal', TestCamp.name);
        // createCustomSettings CCS = new createCustomSettings();
        // CreateCustomSettings.createCustomSettings();
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug('Have inserted these payments:' + Payments);
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Account.Name, Attendee__c
        from Opportunity ];
        system.debug('Before inserting DataXML we have ' + Payments.size() + ' payments.');

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2019-04-07 12:53:44</PostedDateTime>';
        XMLstring += '<Application><Name>AM</Name>';
        XMLstring += '<Version>1.0</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName>';
        XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>2698613001</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>1618 Pear St</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>Ann Arbor</BillingCity>';
        XMLstring += '<BillingStateProvince>Michigan</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>48105</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>29011-190407125336798</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>11104408</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<Campaign>New Membership</Campaign>';
        XMLstring += '<ConnectCampaignAlias>membership-renewal</ConnectCampaignAlias>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>29011</OrganizationID>';
        XMLstring += '<OrganizationName>Huron River Watershed Council</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>148571</AuthorizationCode>';
        XMLstring += '<WindowName>New Membership</WindowName>';
        XMLstring += '<WindowId>90740</WindowId>';
        XMLstring += '<GatewayTransactionNumber>1490786489</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>10.00</TotalCharge>';
        XMLstring += '<TotalDue>10.00</TotalDue>';
        XMLstring += '<DeductibleCharge>10.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>10.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>0.04</ChargAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2019-04-07 12:53:36</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2019-04-07 12:53:36</TransactionTimeZone>';
        XMLstring += '<UrlReferrer>http://www.hrwc.org/donate/membership.html</UrlReferrer>';
        XMLstring += '<VaultGUID>77212401-2a7e-472c-b962-7ef6be66c7e2</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Joel Panozzo</NameOnCard>';
        XMLstring += '<CardNumber>37953000</CardNumber>';
        XMLstring += '<CardName>American Express</CardName>';
        XMLstring += '<ExpirationDate>2107</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName>Membership</CampaignName>';
        XMLstring += '<CampaignID>43728</CampaignID>';
        XMLstring += '<AccountID>29011</AccountID>';
        XMLstring += '<CampaignExternalID>a01o00000017Tiu</CampaignExternalID>';
        XMLstring += '<CampaignScope>Transaction</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<Recurring>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<RecurringStatus>Active</RecurringStatus>';
        XMLstring += '<RecurringID>213534</RecurringID>';
        XMLstring += '<RecurringIDUpdate></RecurringIDUpdate>';
        XMLstring += '<MasterTransactionNumber>1609071021080923000</MasterTransactionNumber>';
        XMLstring += '<MasterTransactionDate>2016-09-07 10:21:00</MasterTransactionDate>';
        XMLstring += '<Installments>999</Installments>';
        XMLstring += '<ToDateRemainingInstallments>967</ToDateRemainingInstallments>';
        XMLstring += '<RecurringMethod>Subscription</RecurringMethod>';
        XMLstring += '<Periodicity>Monthly</Periodicity>';
        XMLstring += '<InstallmentNumber>32</InstallmentNumber>';
        XMLstring += '<NextInstallmentDate>2019-05-07 00:00:00</NextInstallmentDate>';
        XMLstring += '<InstallmentAmount>10.00</InstallmentAmount>';
        XMLstring += '<TotalAmount>10.00</TotalAmount>';
        XMLstring += '<TotalCommitted>9990.00</TotalCommitted>';
        XMLstring += '<TotalMade>320.00</TotalMade>';
        XMLstring += '<TotalDue>9670.00</TotalDue>';
        XMLstring += '';
        XMLstring += '</Recurring>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>How did you hear about HRWC?</FieldName>';
        XMLstring += '<FieldValue>Web</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Online newsletter only?</FieldName>';
        XMLstring += '<FieldValue>Yes</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>2507190</ItemID>';
        XMLstring += '<ItemName>Additional Donation or Other Amount</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>10</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>10</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>10</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>10</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Donation</SKU>';
        XMLstring += '</OrderItem>';
        XMLstring += '';
        XMLstring += '</OrderItemList>';
        XMLstring += '</CnPTransactionData>';

        WG_CnPData__c TestData2 = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207131327206181111');
        insert testdata2;

        List<WG_Error_Log__c> ErrorList = [SELECT id, Description__c, Category__c from WG_Error_Log__c];
        system.assertEquals(1,ErrorList.size());
        // Since guarding against WGCampaignId errors, this no longer causes an error
        // system.debug('ErrorList[0].Description__c is ' + ErrorList[0].Description__c);
        // system.debug('ErrorList[0].Category__c is ' + ErrorList[0].Category__c);

        List<WG_CnPData__c> CnPData = [SELECT id, Order_Number__c FROM WG_CnPData__c];
        system.assertEquals(1,CnPData.size(),'If try/catch worked, the CnPData should have been saved.');

        // No Opportunity saved
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, campaign.Name, Account.Name, Attendee__c from Opportunity ];
        For (Opportunity opp : Payments) system.debug('Payment is ' + opp);
        system.assertEquals(1,Payments.size(),'Should have created a payment linked to the orphanage');
        system.assertEquals('Lost Payments',Payments[0].campaign.name,'Should have created a payment linked to Lost Payments');
    } // end test

    // single transaction test with recurring, existing contact, campaign specified, bad periodicity value
    @isTest
    static void SingleRecurringBadPeriodicityError() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Test Membership Campaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>1.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMlstring += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringID>47212</RecurringID>';
        XMlstring += '<MasterTransactionNumber>1307101607584781111</MasterTransactionNumber><Installments>3</Installments>';
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Manthly</Periodicity>'; // INTENTIONALLY INSERTED BAD PERIODICITY HERE
        XMlstring += '<InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>1.00</InstallmentAmount><TotalAmount>1.00</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>1.00</TotalMade><TotalDue>2.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Membership</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: ' + testdata);
        WG_CnPData__c TestDataUpdated = [
                select id, DataXML__c
                from WG_CnPData__c
                where id = :testdata.id
        ];
        List<WG_Error_Log__c> ErrorList = [SELECT id, Description__c, Category__c from WG_Error_Log__c];
        system.assertEquals(1, ErrorList.size(),'Should have created error.  Is the Periodicity Picklist set to restricted?  If not, no error.');
        system.debug('ErrorList[0].Description__c is ' + ErrorList[0].Description__c);
        system.debug('ErrorList[0].Category__c is ' + ErrorList[0].Category__c);

        List<WG_CnPData__c> CnPData = [SELECT id, Order_Number__c FROM WG_CnPData__c];
        system.assertEquals(1, CnPData.size(), 'If try/catch worked, the CnPData should have been saved.');

        // No Opportunity saved
        List<Opportunity> Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, campaign.Name, Account.Name, Attendee__c from Opportunity];
        system.assertEquals(0, Payments.size(), 'Should have created a payment linked to the orphanage');
    }
    @isTest
    static void OrderItemCampaignNodeId() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2019-09-16 14:10:14</PostedDateTime>';
        XMLstring += '<Application><ID>Salesforce:CnP_PaaS_Evt</ID>';
        XMLstring += '<Name>Salesforce:CnP_PaaS_Evt:Site</Name>';
        XMLstring += '<Version>5.1906090100</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>Tester</BillingLastName>';
        XMLstring += '<BillingEmail>tester@donotbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>(646) 496-3380</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>Main St.</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>BRONX</BillingCity>';
        XMLstring += '<BillingStateProvince>NY</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>10457</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>60116-1909161410050826853</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>12480465</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<ConnectCampaignAlias>eventdonotsendreceipt</ConnectCampaignAlias>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>60116</OrganizationID>';
        XMLstring += '<OrganizationName>Bronx River Alliance</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>96405P</AuthorizationCode>';
        XMLstring += '<WindowName></WindowName>';
        XMLstring += '<WindowId></WindowId>';
        XMLstring += '<GatewayTransactionNumber>188</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>5.00</TotalCharge>';
        XMLstring += '<TotalDue>5.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>0.00</ChargAmount>';
        XMLstring += '<ChargeAmount>0.00</ChargeAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2019-09-16 14:10:05</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2019-09-16 14:10:05</TransactionTimeZone>';
        XMLstring += '<UrlReferrer></UrlReferrer>';
        XMLstring += '<VaultGUID>fc5909e8-6f41-4819-9a4b-8615f6d322e2</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Karla G. Cabrera Carrera</NameOnCard>';
        XMLstring += '<CardNumber>54246853</CardNumber>';
        XMLstring += '<CardName>MasterCard</CardName>';
        XMLstring += '<ExpirationDate>2105</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '<CampaignExternalID></CampaignExternalID>';
        XMLstring += '<CampaignScope>Transaction</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '<CustomParameters>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>sfeventid</Field>';
        XMLstring += '<Value>a1i0b000005B2AwAAK</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>registrantid</Field>';
        XMLstring += '<Value>a1m0b000001eturAAA</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>ProcessedBy</Field>';
        XMLstring += '<Value>c_p_default@bronxriveralliance.force.com</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters></TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Name and phone number of someone we can contact in case of an emergency</FieldName>';
        XMLstring += '<FieldValue>Ofelia Gonzalez, 646. 391.3228</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>3000</ItemID>';
        XMLstring += '<ItemName>Boogie Up the Bronx River Registration-Karla Cabrera Carrera</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>5</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>5</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Boogie Up the Bronx River 2019</SKU>';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName>' + TestMemberCamp + '</CampaignName>';
        XMLstring += '<CampaignString>' + TestMemberCamp + '</CampaignString>';
        XMLstring += '<CampaignExternalID>'+TestMemberCamp.Id+'</CampaignExternalID>';
        // Add another Campaign Node to see whether it ignores that as it should.
        XMLstring += '<CampaignScope>Item</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '<PassThroughList><PassThrough>';
        XMLstring += '<Name>CnP.SF.eVT.Setting</Name>';
        XMLstring += '</PassThrough>';
        XMLstring += '</PassThroughList>';
        XMLstring += '</CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];
        List<Opportunity> Payments = [select id,Name, CampaignID,Amount,AccountID,Contact__c, Campaign.Id, campaign.Name, Account.Name, Attendee__c from Opportunity ];
        system.debug('Payments is ' + Payments);
        system.assertEquals('Tester, Test Household',Payments[0].account.name,'Should have created a payment for Tester, Test Household');
        system.assertEquals('Test Membership Campaign', Payments[0].campaign.name,'Should have pulled name from OrderItem.CampaignExternalId');
        system.assertEquals(TestMemberCamp.Id, Payments[0].campaign.Id,'Should have pulled Id from OrderItem.CampaignExternalId');
    } // end test

    @isTest
    static void OrderItemCampNodeName() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2019-09-16 14:10:14</PostedDateTime>';
        XMLstring += '<Application><ID>Salesforce:CnP_PaaS_Evt</ID>';
        XMLstring += '<Name>Salesforce:CnP_PaaS_Evt:Site</Name>';
        XMLstring += '<Version>5.1906090100</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName>';
        XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>(646) 496-3380</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>Main St.</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>BRONX</BillingCity>';
        XMLstring += '<BillingStateProvince>NY</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>10457</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>60116-1909161410050826853</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>12480465</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker></Tracker>';
        XMLstring += '<ConnectCampaignAlias>eventdonotsendreceipt</ConnectCampaignAlias>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>60116</OrganizationID>';
        XMLstring += '<OrganizationName>Bronx River Alliance</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>96405P</AuthorizationCode>';
        XMLstring += '<WindowName></WindowName>';
        XMLstring += '<WindowId></WindowId>';
        XMLstring += '<GatewayTransactionNumber>188</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>5.00</TotalCharge>';
        XMLstring += '<TotalDue>5.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>0.00</ChargAmount>';
        XMLstring += '<ChargeAmount>0.00</ChargeAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2019-09-16 14:10:05</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2019-09-16 14:10:05</TransactionTimeZone>';
        XMLstring += '<UrlReferrer></UrlReferrer>';
        XMLstring += '<VaultGUID>fc5909e8-6f41-4819-9a4b-8615f6d322e2</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Karla G. Cabrera Carrera</NameOnCard>';
        XMLstring += '<CardNumber>54246853</CardNumber>';
        XMLstring += '<CardName>MasterCard</CardName>';
        XMLstring += '<ExpirationDate>2105</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '<CampaignExternalID></CampaignExternalID>';
        XMLstring += '<CampaignScope>Transaction</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '<CustomParameters>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>sfeventid</Field>';
        XMLstring += '<Value>a1i0b000005B2AwAAK</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>registrantid</Field>';
        XMLstring += '<Value>a1m0b000001eturAAA</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>ProcessedBy</Field>';
        XMLstring += '<Value>c_p_default@bronxriveralliance.force.com</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters></TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Name and phone number of someone we can contact in case of an emergency</FieldName>';
        XMLstring += '<FieldValue>Ofelia Gonzalez, 646. 391.3228</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>3000</ItemID>';
        XMLstring += '<ItemName>Boogie Up the Bronx River Registration-Karla Cabrera Carrera</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>5</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>5</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Boogie Up the Bronx River 2019</SKU>';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName>' + TestMemberCamp.Name + '</CampaignName>';
        XMLstring += '<CampaignString>' + TestMemberCamp + '</CampaignString>';
        XMLstring += '<CampaignScope>Item</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '<PassThroughList><PassThrough>';
        XMLstring += '<Name>CnP.SF.eVT.Setting</Name>';
        XMLstring += '</PassThrough>';
        XMLstring += '</PassThroughList>';
        XMLstring += '</CnPTransactionData>';


        // create new CnP_Data record
        WG_CnPData__c TestData = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207181600564311111',
                StatusId__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
        where id = :testdata.id];
        List<Opportunity> Payments = [select id,Name, CampaignID,Amount,AccountID,Contact__c, Campaign.Id, campaign.Name, Account.Name, Attendee__c from Opportunity ];
        system.debug('Payments is ' + Payments);
        system.assertEquals('TestAccount',Payments[0].account.name,'Should have created a payment for Tester, Test Household');
        system.assertEquals('Test Membership Campaign', Payments[0].campaign.name,'Should have pulled name from OrderItem.CampaignExternalId');
    } // end test

// single transaction test with existing contact, campaign specified in orderItem
// created Mar 16 2018 to handle errors identified by Jaron at SHTA
    // July 2021 added "AddTransactionFeeTo" to see if Trans Fee is added to orderitem0
    static testmethod void AdditionalFeeAddedToDonation() {
        WGHelpers.SAddTransactionFeeTo = 'Another donation';
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);
        // populate WG_Settings
//        populateWGCustomSettings.populateWGSettings();

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c
        from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring+='<CnPTransactionData><Version>40</Version>';
        XMLstring+='<PostedDateTime>2018-02-13 10:47:19</PostedDateTime>';
        XMLstring+='<Application><Name>Connect.Forms</Name>';
        XMLstring+='<Version>1.5</Version>';
        XMLstring+='</Application>';
        XMLstring+='<Patron>';
        XMLstring+='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring+='<BillingMI></BillingMI>';
        XMLstring+='<BillingLastName>Testcontact</BillingLastName>';
        XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring+='<BillingPhone>218-390-4915</BillingPhone>';
        XMLstring+='</BillingInformation>';
        XMLstring+='<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring+='<BillingAddress2></BillingAddress2>';
        XMLstring+='<BillingAddress3></BillingAddress3>';
        XMLstring+='<BillingCity>Duluth</BillingCity>';
        XMLstring+='<BillingStateProvince>Minnesota</BillingStateProvince>';
        XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
        XMLstring+='<BillingCountryName>United States</BillingCountryName>';
        XMLstring+='</BillingAddress>';
        XMLstring+='<CustomParameters><Parameter>';
        XMLstring+='<Field>SocialComment</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>SocialCommentStatus</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters>';
        XMLstring+='';
        XMLstring+='</Patron>';
        XMLstring+='<TransactionDetail>';
        XMLstring+='<OrderNumber>39196-1802131047104886145</OrderNumber>';
        XMLstring+='<ReceiptNumber></ReceiptNumber>';
        XMLstring+='<TransactionID>8303416</TransactionID>';
        XMLstring+='<OrderMode>Live</OrderMode>';
        XMLstring+='<Tracker></Tracker>';
        XMLstring+='<Campaign></Campaign>';
        XMLstring+='<ConnectCampaignAlias>2018websitegifts</ConnectCampaignAlias>';
        XMLstring+='<TransactionType>Live</TransactionType>';
        XMLstring+='<OrganizationID>39196</OrganizationID>';
        XMLstring+='<OrganizationName>Superior Hiking Trail Association</OrganizationName>';
        XMLstring+='<CurrencyCode>840</CurrencyCode>';
        XMLstring+='<AuthorizationCode>225562</AuthorizationCode>';
        XMLstring+='<WindowName>2018 Website Gifts 8</WindowName>';
        XMLstring+='<WindowId>9d7fca76-5b49-4606-a7d3-9df8972a8cc1</WindowId>';
        XMLstring+='<GatewayTransactionNumber>1233803501</GatewayTransactionNumber>';
        XMLstring+='<TotalCharge>5.54</TotalCharge>';
        XMLstring+='<TotalDue>5.54</TotalDue>';
        XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
        XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
        XMLstring+='<DiscountDue>0.00</DiscountDue>';
        XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring+='<SurCharge>0.00</SurCharge>';
        XMLstring+='<ChargAmount>0.56</ChargAmount>';
        XMLstring+='<CouponCode></CouponCode>';
        XMLstring+='<TransactionDate>2018-02-13 10:47:10</TransactionDate>';
        XMLstring+='<TransactionTimeZone>2018-02-13 09:47:10</TransactionTimeZone>';
        XMLstring+='<UrlReferrer>https://shta.org/donate/</UrlReferrer>';
        XMLstring+='<VaultGUID>8584a5b8-479a-43f8-9a81-54eba21dd051</VaultGUID>';
        XMLstring+='<TransactionResult>Authorized</TransactionResult>';
        XMLstring+='<PaymentMethod>';
        XMLstring+='<PaymentType>Credit Card</PaymentType>';
        XMLstring+='<CreditCard>';
        XMLstring+='<NameOnCard>Test T Testcontact</NameOnCard>';
        XMLstring+='<CardNumber>43336135</CardNumber>';
        XMLstring+='<CardName>VISA</CardName>';
        XMLstring+='<ExpirationDate>1803</ExpirationDate>';
        XMLstring+='</CreditCard>';
        XMLstring+='</PaymentMethod>';
        XMLstring+='';
        XMLstring+='<CampaignList><CampaignNode>';
        XMLstring+='<CampaignName>'+TestCamp.Name+'</CampaignName>';
        XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring+='<CampaignScope>Transaction</CampaignScope>';
        XMLstring+='</CampaignNode>';
        XMLstring+='</CampaignList>';
        XMLstring+='<CustomParameters>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>GiveBigCampaignId</Field>';
        XMLstring+='<Value>49012</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItID</Field>';
        XMLstring+='<Value>0</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PostItAlias</Field>';
        XMLstring+='<Value></Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>PaymentWidgetID</Field>';
        XMLstring+='<Value>10935</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='<Parameter>';
        XMLstring+='<Field>Pay-02</Field>';
        XMLstring+='<Value>Site.20180207.002.018.010</Value>';
        XMLstring+='</Parameter>';
        XMLstring+='</CustomParameters></TransactionDetail>';
        XMLstring+='<Recurring>';
        XMLstring+='<TransactionResult>Authorized</TransactionResult>';
        XMLstring+='<RecurringStatus>Active</RecurringStatus>';
        XMLstring+='<RecurringID>319266</RecurringID>';
        XMLstring+='<RecurringIDUpdate></RecurringIDUpdate>';
        XMLstring+='<MasterTransactionNumber>39196-1802131047104886145</MasterTransactionNumber>';
        XMLstring+='<MasterTransactionDate>2018-02-13 09:47:10</MasterTransactionDate>';
        XMLstring+='<Installments>999</Installments>';
        XMLstring+='<ToDateRemainingInstallments>998</ToDateRemainingInstallments>';
        XMLstring+='<RecurringMethod>Subscription</RecurringMethod>';
        XMLstring+='<Periodicity>Monthly</Periodicity>';
        XMLstring+='<InstallmentNumber>1</InstallmentNumber>';
        XMLstring+='<NextInstallmentDate>2018-03-13 09:47:00</NextInstallmentDate>';
        XMLstring+='<InstallmentAmount>5.54</InstallmentAmount>';
        XMLstring+='<TotalAmount>5.54</TotalAmount>';
        XMLstring+='<TotalCommitted>5534.46</TotalCommitted>';
        XMLstring+='<TotalMade>5.54</TotalMade>';
        XMLstring+='<TotalDue>5528.92</TotalDue>';
        XMLstring+='';
        XMLstring+='</Recurring>';
        XMLstring+='<CustomFieldList>';
        XMLstring+='<CustomField>';
        XMLstring+='<FieldName>Please provide the name and address of the recipient.</FieldName>';
        XMLstring+='<FieldValue></FieldValue>';
        XMLstring+='</CustomField>';
        XMLstring+='';
        XMLstring+='</CustomFieldList>';
        XMLstring+='<OrderItemList>';
        XMLstring+='<OrderItem>';
        XMLstring+='<ItemID>0</ItemID>';
        XMLstring+='<ItemName>Generic Donation</ItemName>';
        XMLstring+='<Quantity>1</Quantity>';
        XMLstring+='<UnitPriceCharge>5</UnitPriceCharge>';
        XMLstring+='<UnitPriceDue>5</UnitPriceDue>';
        XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
        XMLstring+='<DiscountCharge>0</DiscountCharge>';
        XMLstring+='<DiscountDue>0</DiscountDue>';
        XMLstring+='<SKU>Donation</SKU>';
        XMLstring+='</OrderItem>';
        XMLstring+='<OrderItem>';
        XMLstring+='<ItemID>1</ItemID>';
        XMLstring+='<ItemName>Additional Fee</ItemName>';
        XMLstring+='<Quantity>1</Quantity>';
        XMLstring+='<UnitPriceCharge>0.54</UnitPriceCharge>';
        XMLstring+='<UnitPriceDue>0.54</UnitPriceDue>';
        XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
        XMLstring+='<DiscountCharge>0</DiscountCharge>';
        XMLstring+='<DiscountDue>0</DiscountDue>';
        XMLstring+='<SKU></SKU>';
        XMLstring+='<CampaignList><CampaignNode>';
        XMLstring+='<CampaignName>'+TestCamp.Name+'</CampaignName>';
        XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
        XMLstring+='<CampaignScope>Transaction</CampaignScope>';
        XMLstring+='</CampaignNode>';
        XMLstring+='</CampaignList>';
        XMLstring+='</OrderItem>';
        XMLstring+='';
        XMLstring+='</OrderItemList>';
        XMLstring+='</CnPTransactionData>';

        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        WG_CnPData__c TestData2 = new WG_CnPData__c(
                DataXML__c = XMLstring,
                Order_Number__c = '1207131327206181111');
        List<WG_CnPData__c> ListTestData = new List<WG_CnPData__c>();
        ListTestData.add(TestData2);
        ManageCnPData MCPDB = new ManageCnPData();
        MCPDB.afterInsert(ListTestData,null);
        // system.debug('TestCamp.Name is ' + TestCamp.Name + ', MCPDB.OptyCampaignName is ' + [SELECT name from Campaign where id =: MCPDB.OptyCampaignId].Name);
        // system.AssertEquals(TestCamp.Id,MCPDB.OptyCampaignId,'Did not identify correct campaign');
        // system.debug('NewOpps is ' + MCPDB.NewOpps);
        system.assertEquals(1,MCPDB.NewOpps.size(),'Should be 1 Opp - a payment of 5.54 which includes the Transaction Fee.');
        Opportunity opp = MCPDB.NewOpps[0];
        // The first payment records an amount of 5.00
        system.AssertEquals(5.54,opp.Amount);
    }

}