trigger ManageCnPPaaSDataTrigger on CnP_PaaS__CnPData__c (before insert, after insert, before delete) {
//enums declared in separate class - 

//     if(Trigger.isInsert && Trigger.isBefore){
//            ManageCnPDataController.BeforeInsert(Trigger.New,Trigger.Old); 
//        }
    if(Trigger.isInsert && Trigger.isBefore){
        for (CnP_PaaS__CnPData__c c : Trigger.new) {
            c.Transferred_to_WaterGrass__c = 'Saved';
        }
    }


    if(Trigger.isInsert && Trigger.isAfter){
        List<WG_CnPData__c> NewCnPData = new List<WG_CnPData__c>();
        for (CnP_PaaS__CnPData__c c : Trigger.new) {
            WG_CnPData__c WGCnP = new WG_CnPData__c(
                    DataXML__c = c.CnP_PaaS__DataXML__c,
                    Order_Number__c = c.CnP_PaaS__OrderNumber__c,
                    ProcessedByWG__c = 'Ready to Process',
                    StatusId__c = c.CnP_PaaS__StatusID__c,
                    CnPMessage__c = c.CnP_PaaS__Message__c,
                    TransactionResult__c = c.CnP_PaaS__Transaction_Result__c
            );
            NewCnPData.add(WGCnP);
        }
        if (!NewCnPData.IsEmpty()){
            insert NewCnPData;
            system.debug('Just inserted new WG CnPData object.');
       }
    }

}