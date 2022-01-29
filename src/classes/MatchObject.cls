// Created Feb 2021
// Allows me to pull from custom metadata

global with sharing class MatchObject
{   
    public Id PersonId;
    public SObject Person;
    public Id AccountId;
    public string MatchMethod;
    public integer MatchRank;

    public MatchObject(){}
    
    public MatchObject(Id PId, SObject Sobj, Id AId, string MM, Integer i) {
        PersonId = PId;
        Person = Sobj;
        AccountId = AId;
        MatchMethod = MM;
        MatchRank = i;
    }
}