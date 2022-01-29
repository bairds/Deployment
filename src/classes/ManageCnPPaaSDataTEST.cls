/**
 * Created by HP on 7/29/2021.
 */

@isTest
private class ManageCnPPaaSDataTEST {

        @isTest
        static void SingleContactTransactionCampaignInOrderItemTest() {
            WGHelpers.BMinimumAcceptableMatchRank = 4;
            WGHelpers.SAddTransactionFeeTo = 'Another donation';
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

            string XMLstring='<?xml version=\'1.0\' encoding=\'UTF-8\'?>';
            XMLstring+='<CnPTransactionData>';
            XMLstring+='<Version>40</Version>';
            XMLstring+='<PostedDateTime>2021-08-03 11:34:41</PostedDateTime>';
            XMLstring+='<Application>';
            XMLstring+='<Name>Connect.Forms</Name>';
            XMLstring+='<Version>1.5</Version>';
            XMLstring+='</Application>';
            XMLstring+='<Patron>';
            XMLstring+='<BillingInformation>';
            XMLstring+='<BillingFirstName>Test</BillingFirstName>';
            XMLstring+='<BillingMI>';
            XMLstring+='</BillingMI>';
            XMLstring+='<BillingLastName>TestContact</BillingLastName>';
            XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
            XMLstring+='<BillingPhone>33333333333333333</BillingPhone>';
            XMLstring+='</BillingInformation>';
            XMLstring+='<BillingAddress>';
            XMLstring+='<BillingAddress1>Test Street</BillingAddress1>';
            XMLstring+='<BillingAddress2>';
            XMLstring+='</BillingAddress2>';
            XMLstring+='<BillingAddress3>';
            XMLstring+='</BillingAddress3>';
            XMLstring+='<BillingCity>Test City</BillingCity>';
            XMLstring+='<BillingStateProvince>Maryland</BillingStateProvince>';
            XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
            XMLstring+='<BillingCountryName>United States</BillingCountryName>';
            XMLstring+='<BillingCountryABV>US</BillingCountryABV>';
            XMLstring+='</BillingAddress>';
            XMLstring+='<CustomParameters>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>SocialComment</Field>';
            XMLstring+='<Value>';
            XMLstring+='</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>SocialCommentStatus</Field>';
            XMLstring+='<Value>1</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>FullName</Field>';
            XMLstring+='<Value>';
            XMLstring+='</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='</CustomParameters>';
            XMLstring+='</Patron>';
            XMLstring+='<TransactionDetail>';
            XMLstring+='<OrderNumber>18801-2108031134282681111</OrderNumber>';
            XMLstring+='<ReceiptNumber>';
            XMLstring+='</ReceiptNumber>';
            XMLstring+='<TransactionID>17618556</TransactionID>';
            XMLstring+='<OrderMode>Live</OrderMode>';
            XMLstring+='<Tracker>';
            XMLstring+='</Tracker>';
            XMLstring+='<ConnectCampaignAlias>OpposeTaconiteMine</ConnectCampaignAlias>';
            XMLstring+='<TransactionType>Live</TransactionType>';
            XMLstring+='<OrganizationID>18801</OrganizationID>';
            XMLstring+='<OrganizationName>LeadGreen.org</OrganizationName>';
            XMLstring+='<CurrencyCode>840</CurrencyCode>';
            XMLstring+='<AuthorizationCode>373726</AuthorizationCode>';
            XMLstring+='<WindowName>Support Our Efforts to Stop the Mine!</WindowName>';
            XMLstring+='<WindowId>e9255e4e-468a-40a7-81a4-4f57fb38b37d</WindowId>';
            XMLstring+='<GatewayTransactionNumber>610815d7-a343-3000-0086-005056a63d00</GatewayTransactionNumber>';
            XMLstring+='<TotalCharge>1.46</TotalCharge>';
            XMLstring+='<TotalDue>1.46</TotalDue>';
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
            XMLstring+='<ChargAmount>0.00</ChargAmount>';
            XMLstring+='<ChargeAmount>0.00</ChargeAmount>';
            XMLstring+='<CouponCode>';
            XMLstring+='</CouponCode>';
            XMLstring+='<TransactionDate>2021-08-03 11:34:33</TransactionDate>';
            XMLstring+='<TransactionTimeZone>2021-08-03 11:34:33</TransactionTimeZone>';
            XMLstring+='<UrlReferrer>https://login.connect.clickandpledge.com/</UrlReferrer>';
            XMLstring+='<VaultGUID>5b6c3f38-24b8-4aec-84dd-ee380e3403a8</VaultGUID>';
            XMLstring+='<TransactionResult>Authorized</TransactionResult>';
            XMLstring+='<PaymentMethod>';
            XMLstring+='<PaymentType>Credit Card</PaymentType>';
            XMLstring+='<CreditCard>';
            XMLstring+='<NameOnCard>Bd St</NameOnCard>';
            XMLstring+='<CardNumber>41111111</CardNumber>';
            XMLstring+='<CardName>VISA</CardName>';
            XMLstring+='<ExpirationDate>2112</ExpirationDate>';
            XMLstring+='</CreditCard>';
            XMLstring+='</PaymentMethod>';
            XMLstring+='<CampaignList>';
            XMLstring+='<CampaignNode>';
            XMLstring+='<CampaignName>Oppose Taconite Mine</CampaignName>';
            XMLstring+='<CampaignID>112314</CampaignID>';
            XMLstring+='<AccountID>18801</AccountID>';
            XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
            XMLstring+='<CampaignScope>Transaction</CampaignScope>';
            XMLstring+='</CampaignNode>';
            XMLstring+='</CampaignList>';
            XMLstring+='<CustomParameters>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>GiveBigCampaignId</Field>';
            XMLstring+='<Value>48334</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>PostItID</Field>';
            XMLstring+='<Value>0</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>PostItAlias</Field>';
            XMLstring+='<Value>';
            XMLstring+='</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>PaymentWidgetID</Field>';
            XMLstring+='<Value>8881</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>Pay-105</Field>';
            XMLstring+='<Value>Site.20210716.002.040.019</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='<Parameter>';
            XMLstring+='<Field>ConnectCampaignId</Field>';
            XMLstring+='<Value>48334</Value>';
            XMLstring+='</Parameter>';
            XMLstring+='</CustomParameters>';
            XMLstring+='</TransactionDetail>';
            XMLstring+='<CustomFieldList>';
            XMLstring+='<CustomField>';
            XMLstring+='<FieldName>Anonymous Donation</FieldName>';
            XMLstring+='<FieldValue>Yes</FieldValue>';
            XMLstring+='</CustomField>';
            XMLstring+='<CustomField>';
            XMLstring+='<FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName>';
            XMLstring+='<FieldValue>';
            XMLstring+='</FieldValue>';
            XMLstring+='</CustomField>';
            XMLstring+='</CustomFieldList>';
            XMLstring+='<OrderItemList>';
            XMLstring+='<OrderItem>';
            XMLstring+='<ItemID>1400</ItemID>';
            XMLstring+='<ItemName>Stop the Mine Other</ItemName>';
            XMLstring+='<Quantity>1</Quantity>';
            XMLstring+='<UnitPriceCharge>1.11</UnitPriceCharge>';
            XMLstring+='<UnitPriceDue>1.11</UnitPriceDue>';
            XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
            XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
            XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
            XMLstring+='<DiscountCharge>0</DiscountCharge>';
            XMLstring+='<DiscountDue>0</DiscountDue>';
            XMLstring+='<SKU>Donation</SKU>';
            XMLstring+='</OrderItem>';
            XMLstring+='<OrderItem>';
            XMLstring+='<ItemID>1401</ItemID>';
            XMLstring+='<ItemName>Additional Fee</ItemName>';
            XMLstring+='<Quantity>1</Quantity>';
            XMLstring+='<UnitPriceCharge>0.35</UnitPriceCharge>';
            XMLstring+='<UnitPriceDue>0.35</UnitPriceDue>';
            XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
            XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
            XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
            XMLstring+='<DiscountCharge>0</DiscountCharge>';
            XMLstring+='<DiscountDue>0</DiscountDue>';
            XMLstring+='<SKU>Donation</SKU>';
            XMLstring+='</OrderItem>';
            XMLstring+='</OrderItemList>';
            XMLstring+='</CnPTransactionData>';

            // create new CnP_Data record
            CnP_PaaS__CnPData__c TestCnPPaaSData = new CnP_PaaS__CnPData__c(
                    CnP_PaaS__Message__c = 'successfully transacted',
                    CnP_PaaS__DataXML__c = XMLstring,
                    CnP_PaaS__OrderNumber__c = '1207181600564311111',
                    CnP_PaaS__StatusID__c = 1);
            insert testCnPPaaSdata;
            // Was one record inserted in the CnPData__c object?
            List<WG_CnPData__c> testrecords = [SELECT Id from WG_CnPData__c];
            system.assertEquals(1,testrecords.size());
            system.debug('Testdata record now contains: '+ testrecords);
            WG_CnPData__c CheckResults = [SELECT ProcessedByWG__c from WG_CnPData__c WHERE Id =: testrecords[0].Id];
            System.assertEquals('Processed',CheckResults.ProcessedByWG__c,'ProcessedByWG__c should be Processed');
            // Capture errors
            List<WG_Error_Log__c> ErrorLogs = [SELECT Category__c, Description__c, Error_Level__c, Status_Code__c from WG_Error_Log__c];
            system.assertEquals(0,ErrorLogs.size(),'Error inserting CnP testdata which generated a WG_Error_Log ');
            if (ErrorLogs.size()>0) system.debug('On line 71 inserted testdata, which generated an error: '+ErrorLogs);
            WG_CnPData__c TestDataUpdated = [select id, DataXML__c from WG_CnPData__c
            where id = :testrecords[0].id];

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
            system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');

            // Have one new donations been created?
            system.debug('TestAcct.id is ' + TestAcct.ID);
            system.debug('All Payments are ' + [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity]);
            Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
            system.debug(Payments);
            system.AssertEquals(1,Payments.size());
            system.AssertEquals(1.46,Payments[0].amount);
            system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
            system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
            system.AssertEquals('Testcampaign', Payments[0].Campaign.Name);
            system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
            system.AssertEquals('TestAccount 2021-08-03 Testcampaign',Payments[0].Name);
            Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode,
                    account.billingCity, account.ShippingState, account.dear__c, account.addressee__c
            from Contact where id = :Payments[0].contact__c];
            system.debug('checkContact is ' + checkContact);
            system.AssertEquals('TestContact',checkContact.lastname);
            System.assertEquals('Test Street',checkContact.mailingStreet);
            System.assertEquals('33333', checkContact.mailingPostalCode);
            System.assertEquals('Test Street',[select id, MailingStreet from contact where id = :TestCtct.id].mailingStreet);
        }
}