//
//  TicketHomeController.swift
//  HelpSumoSDK
//
//  Created by APP DEVELOPEMENT on 16/11/16.
//  Copyright © 2016 APP DEVELOPEMENT. All rights reserved.
//

import UIKit
import CoreData
import FMDB

public class TicketHomeController: UITableViewController {
    
    var ticketsData: [[String:String]] = []
    
    var databasePath = String()
    
    let defaults = UserDefaults.standard
    
    let constants = Constants()
    
    var selectedTicketID: String! = ""

    @IBOutlet var ticketsTable: UITableView!
    
    @IBAction func onAddPressed(sender: UIBarButtonItem) {
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let storyboard = UIStoryboard(name: "Ticket", bundle: resourceBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController") as! UINavigationController
        
        let viewController = controller.topViewController as! NewTicketController
        
        viewController.pageTitle = "Create Ticket"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        
        super.viewDidAppear(animated)
        self.ticketsData = []
        self.initializeDatabase()
        self.ticketsTable.reloadData()
        
        self.navigationController?.isToolbarHidden = true
        
        self.ConfigureTableView()
        
        if (HSConfig.getAPIKey() == "")
        {
            let alertController:UIAlertController? = UIAlertController(title: "Error",
                                                                       message: "Invalid API Key",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            
            self.present(alertController!,animated: true, completion: nil)
            
            return
            
        }
        
        if(self.defaults.value(forKey: "userName") == nil || self.defaults.value(forKey: "userMail") == nil)
        {
            
            let alertController = UIAlertController(title: "Login", message: "Enter name and email address", preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                textField.placeholder = "Name"
                textField.textColor = UIColor.black
                textField.clearButtonMode = .whileEditing
                textField.borderStyle = .roundedRect
            })
            
            
            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                textField.placeholder = "Email Address"
                textField.textColor = UIColor.black
                textField.clearButtonMode = .whileEditing
                textField.borderStyle = .roundedRect
            })
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                let textfields = alertController.textFields
                let namefield = textfields?[0]
                let emailfield = textfields?[1]
                
                
                if(namefield?.text! == "" || emailfield?.text! == "" || !self.isValidEmail(testStr: (emailfield?.text!)!))
                {
                    self.present(alertController, animated: true, completion: { _ in })
                }
                else
                {
                    let name : String! = namefield!.text!
                    let email : String! = emailfield!.text!
                    
                    self.defaults.set(name!, forKey: "userName")
                    self.defaults.set(email!, forKey: "userMail")
                    
                    self.downloadTickets(){
                        results in
                        
                        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                        
                        if (dbObj?.open())! {
                            let querySQL = "SELECT ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_name, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date FROM TABLE_TICKET"
                            
                            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                           withArgumentsIn: nil)
                            
                            
                            while results?.next() == true {
                                
                                
                                let jsonObject: [String: String] = [
                                    "Requester": "Carey sam",
                                    "TicketID" : (results?.string(forColumn: "ticket_id"))!,
                                    "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "ticket_status"))!)!],
                                    "Title" : (results?.string(forColumn: "ticket_subject"))!,
                                    "Date": (results?.string(forColumn: "ticket_date"))!
                                ]
                                
                                self.ticketsData.append(jsonObject)
                                
 
                            }
                            dbObj?.close()
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        DispatchQueue.main.async {
                            self.ticketsTable.reloadData()
                        }
                        
                    }
                    
                }
                
            }))
            self.present(alertController, animated: true, completion: { _ in })
        }
        
        if (HSConfig.isInternetAvailable())
        {
        
            self.downloadTickets(){
                results in
            
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_name, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date FROM TABLE_TICKET"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                    
                        let jsonObject: [String: String] = [
                            "Requester": "Carey sam",
                            "TicketID" : (results?.string(forColumn: "ticket_id"))!,
                            "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "ticket_status"))!)!],
                            "Title" : (results?.string(forColumn: "ticket_subject"))!,
                            "Date": (results?.string(forColumn: "ticket_date"))!
                        ]
                    
                        self.ticketsData.append(jsonObject)
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
                DispatchQueue.main.async {
                    self.ticketsTable.reloadData()
                }
            
            }
        }else
        {
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_name, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date FROM TABLE_TICKET"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    let jsonObject: [String: String] = [
                        "Requester": "Carey sam",
                        "TicketID" : (results?.string(forColumn: "ticket_id"))!,
                        "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "ticket_status"))!)!],
                        "Title" : (results?.string(forColumn: "ticket_subject"))!,
                        "Date": (results?.string(forColumn: "ticket_date"))!
                    ]
                    
                    self.ticketsData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.ticketsTable.reloadData()
            }
        }
        
        
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsData.count
    }

    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleCell", for: indexPath) as! TicketsCell
        
        cell.labelStatus.text = ticketsData[indexPath.row]["Status"]
        
        cell.labelTitle.text = ticketsData[indexPath.row]["Title"]
        
        cell.labelDate.text = ticketsData[indexPath.row]["Date"]
        
        cell.statusIndicator.backgroundColor = UIColor.red
        
        cell.ticketID = ticketsData[indexPath.row]["TicketID"]
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! TicketsCell
        
        self.selectedTicketID = cell.ticketID
        
    
        self.performSegue(withIdentifier: "ticketDetailSegue", sender: tableView)
    }

    func ConfigureTableView() {
        self.ticketsTable.delegate = self
        self.ticketsTable.dataSource = self
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)

        self.ticketsTable.register(UINib(nibName: "TicketCell", bundle: resourceBundle), forCellReuseIdentifier: "singleCell")
        self.ticketsTable.rowHeight = 100.0
    }
    
    func initializeDatabase()
    {
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let databasePath = dirPaths[0].appendingPathComponent("database.db").path
        

        defaults.set(String(databasePath), forKey: "databasePath")
        
        let dbObj = FMDatabase(path: defaults.value(forKey: "databasePath") as! String)
        
        if dbObj == nil {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        if (dbObj?.open())!
        {
            let sql_stmt = "CREATE TABLE IF NOT EXISTS TABLE_TICKET (ID INTEGER PRIMARY KEY AUTOINCREMENT, TICKET_SUBJECT TEXT, TICKET_DESCRIPTION TEXT, DEPARTMENT_ID TEXT, PRIORITY_ID TEXT NOT NULL, TYPE_ID TEXT NOT NULL, TICKET_ATTACHMENT TEXT, STAFF_NAME TEXT NOT NULL, TICKET_NO TEXT NOT NULL, TICKET_ID TEXT NOT NULL, TICKET_STATUS TEXT NOT NULL,TICKET_OFFLINE_FLAG TEXT NOT NULL,TICKET_DATE TEXT NOT NULL, TICKET_UPDATE_TIME TEXT )"
            if !(dbObj?.executeStatements(sql_stmt))! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            dbObj?.close()
        }
        else
        {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
    
    }

    
    func downloadTickets(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let constants = Constants()
        
        
        let url = URL(string: constants.AppUrl+"ticket")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "email": String(describing: defaults.value(forKey: "userMail")) == "nil" ? "" : String(describing: defaults.value(forKey: "userMail")!),
            "action":"list",
            "modified_date" : String(describing: defaults.value(forKey: "ticketSyncDateTime")) == "nil" ? "" : String(describing: defaults.value(forKey: "ticketSyncDateTime")!)
        ]
        
        var data : AnyObject
        
        let dict = jsonObject as NSDictionary
        do
        {
            
            data = try JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted) as AnyObject
            
            print(data)
            
            let strData = NSString(data: (data as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            data = strData.data(using: String.Encoding.utf8)! as AnyObject
            
            let task = defaultSession.uploadTask(with: request, from: (data as! NSData) as Data, completionHandler:
                {(data,response,error) in
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                        
                        
                        
                        let alertController:UIAlertController? = UIAlertController(title: "",
                                                                                   message: "Error loading tickets",
                                                                                   preferredStyle: .alert)
                        
                        let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                        handler:nil)
                        
                        alertController!.addAction(alertAction)
                        
                        
                        self.present(alertController!,animated: true, completion: nil)
                        
                        
                        return
                    }
                    
                    let json = JSON(data: data!)
                    
                    if (String(describing: json["ERROR"]) != "null")
                    {
                        let alertController:UIAlertController? = UIAlertController(title: "Error",
                                                                                   message: String(describing: json["ERROR"]),
                                                                                   preferredStyle: .alert)
                        
                        let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                        handler:nil)
                        
                        alertController!.addAction(alertAction)
                        
                        
                        self.present(alertController!,animated: true, completion: nil)
                        
                        return
                        
                    }
                    
                    print(json)
                    
                    if String(describing: json["response"]["CurrentDateTime"]) != "null"
                    {
                    
                        self.defaults.set(String(describing: json["response"]["CurrentDateTime"]), forKey: "ticketSyncDateTime")
                    }
                        
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    var ticket_IDs = [String]()
                    
                    if json["response"]["Ticket"].count > 0
                    {
                    
                        if (dbObj?.open())! {
                            let querySQL = "SELECT ticket_id FROM TABLE_TICKET"
                        
                            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                       withArgumentsIn: nil)
                        
                        
                            while results?.next() == true {
                                
                                ticket_IDs.append((results?.string(forColumn: "ticket_id"))!)
                            
                            }
                            dbObj?.close()
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["response"]["Ticket"].count
                    {

                        let newTicketID: String! = String(describing: json["response"]["Ticket"][i]["ticket_id"])
                        
                        if (dbObj?.open())!
                        {
                            if let existingTicket = ticket_IDs.index(of:newTicketID)
                            {
                                let assignedTo = String(describing: json["response"]["Ticket"][i]["first_name"])+" "+String(describing: json["response"]["Ticket"][i]["last_name"])
                                
                                var attachementString:String = ""
                                
                                for j in 0..<json["response"]["Ticket"][i]["ticket_files"].count
                                {
                                    attachementString = "\(attachementString)" + "\(String(describing: json["response"]["Ticket"][i]["ticket_files"][j]))" + ","
                                }
                                
                                let updateSQL = "UPDATE TABLE_TICKET SET ticket_subject = '\(String(describing: json["response"]["Ticket"][i]["subject"]))', ticket_description = '\(String(describing: json["response"]["Ticket"][i]["message"]))', department_id = '\(String(describing: json["response"]["Ticket"][i]["assign_department_id"]))', priority_id = '\(String(describing: json["response"]["Ticket"][i]["ticket_priority_id"]))', type_id = '\(String(describing: json["response"]["Ticket"][i]["ticket_type_id"]))', ticket_attachment = '\(attachementString)', staff_name = '\(assignedTo)', ticket_no = '\(String(describing: json["response"]["Ticket"][i]["ticket_no"]))',  ticket_status = '\(String(describing: json["response"]["Ticket"][i]["ticket_status"]))', ticket_offline_flag = '1', ticket_date = '\(String(describing: json["response"]["Ticket"][i]["tickets_posted_date"]))' WHERE ticket_id = '\(newTicketID!)'"
                                
                                let result = dbObj?.executeUpdate(updateSQL,
                                                                  withArgumentsIn: nil)
                                
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }

                                
                                
                            }
                            else
                            {
                                let assignedTo = String(describing: json["response"]["Ticket"][i]["first_name"])+" "+String(describing: json["response"]["Ticket"][i]["last_name"])
                            
                                var attachementString:String = ""
                                
                                for j in 0..<json["response"]["Ticket"][i]["ticket_files"].count
                                {
                                    attachementString = "\(attachementString)" + "\(String(describing: json["response"]["Ticket"][i]["ticket_files"][j]))" + ","
                                }
                                
                                var attachments = String(describing: json["response"]["Ticket"][i]["ticket_files"][0])

                                let insertSQL = "INSERT INTO TABLE_TICKET (ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_name, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date, ticket_update_time) VALUES ('\(String(describing: json["response"]["Ticket"][i]["subject"]))', '\(String(describing: json["response"]["Ticket"][i]["message"]))', '\(String(describing: json["response"]["Ticket"][i]["assign_department_id"]))', '\(String(describing: json["response"]["Ticket"][i]["ticket_priority_id"]))', '\(String(describing: json["response"]["Ticket"][i]["ticket_type_id"]))', '\(attachementString)', '\(assignedTo)', '\(String(describing: json["response"]["Ticket"][i]["ticket_no"]))', '\(String(describing: json["response"]["Ticket"][i]["ticket_id"]))', '\(String(describing: json["response"]["Ticket"][i]["ticket_status"]))', '1', '\(String(describing: json["response"]["Ticket"][i]["tickets_posted_date"]))','')"

                                let result = dbObj?.executeUpdate(insertSQL,
                                                              withArgumentsIn: nil)
                            
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        
                        
                    }
                    
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }

    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        
        if (segue.identifier == "ticketDetailSegue") {
            let viewController = segue.destination as! TicketDetailController

            viewController.currentTicketID = self.selectedTicketID
        }
    }


}
