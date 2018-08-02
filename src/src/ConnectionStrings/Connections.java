/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ConnectionStrings;


public class Connections {
    String connectionString = "jdbc:oracle:thin:@localhost:1521:orcl";
    String usrname =  "*****";
    String pwd = "*****";
    
    //returns connection string of DB
    public String getConnectionString(){
        return connectionString;
    }
    
    //returns username of DB
    public String getUserName(){
        return usrname;
    }
    
    //returns password of DB
    public String getPassword(){
        return pwd;
    }
    
    public void setUserName(String u){
        usrname = u;
    }
    
    //returns password of DB
    public void setPassword(String p){
        pwd = p;
    }
}
