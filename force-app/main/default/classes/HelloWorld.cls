public class HelloWorld {

    public static Account createAccout(String name){
        Account account = new Account();
        account.Name=name;
        insert account;
        return account;
    }

}