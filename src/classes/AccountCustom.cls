global with sharing class AccountCustom 
{   
    public  List<Account> accounts;   
    public	String query;
    public	String message;
//    public  Counter count;
    private List<AccountCustom> processedAccounts;
    private List<Account> updatedAccounts;    
    
    private Account account;
    private AccountCustom ac;

    private Account accountOld;
    public List<Account> accountsOld;
    
    public AccountCustom()
    {           
    }
/*    public AccountCustom(Counter c)
    {           
        this.count = c;
    }
*/
    public AccountCustom(Account a)
    {
        this.account = a;        
    }
    
    public AccountCustom(List<Account> al)
    {
        this.accounts = al;        
    }

    webservice static String createContract(Id id)
    {  
        if(String.isNotEmpty(id)) {            
            Lead l = [ SELECT Id, Special_Request__c FROM Lead WHERE Id =: id ];
            Contact co = [ SELECT Id, AccountId, Account.Name FROM Contact WHERE Id =: ConvertLeadToContact.ConvertLeadToContact(id) ];
            
            Contract c = new Contract();
            c.AccountId = co.AccountId;
            
            insert c;
            
            return c.Id;
           
        }
        
        return null;
    }
}