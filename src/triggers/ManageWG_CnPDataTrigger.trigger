/**
 * Created by HP on 8/4/2021.
 */

trigger ManageWG_CnPDataTrigger on WG_CnPData__c (before insert, after insert) {

    if (Trigger.IsBefore) {
        ManageCnPData MCD = new ManageCnPData();
        MCD.BeforeInsert(Trigger.New, Trigger.Old);
    }
    if (Trigger.IsAfter) {
        ManageCnPData MCD = new ManageCnPData();
        MCD.AfterInsert(Trigger.New, Trigger.Old);
    }
}