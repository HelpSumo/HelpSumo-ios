//
//  TicketDetailController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 14/12/16.
//
//

import UIKit
import FMDB

class TicketDetailController: UITableViewController {
    
    var currentTicketID:String! = ""
    
    var currentAttachementURL:String! = ""

    var selectedRowIndex: [Int] = []
    
    let defaults = UserDefaults.standard
    
    var commentsData: [[String:String]] = []
    
    let constants = Constants()
    
    @IBOutlet var ticketDetailsTable: UITableView!
    
    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let storyboard = UIStoryboard(name: "Ticket", bundle: resourceBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController") as! UINavigationController
        
        let viewController = controller.topViewController as! NewTicketController
        
        viewController.isEdit = true
        viewController.editTicketID = self.currentTicketID!
        viewController.pageTitle = "Edit Ticket"
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @IBAction func onDeletePressed(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Delete Ticket", message: "Are you sure you want to delete this ticket?", preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            
            self.deleteTicket(){
                results in
                
                
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                
                if (dbObj?.open())!
                {
                    
                    let deleteSQL1 = "DELETE FROM TABLE_COMMENT WHERE ticket_id ='\(self.currentTicketID!)'"
                    
                    let deleteSQL2 = "DELETE FROM TABLE_TICKET WHERE ticket_id ='\(self.currentTicketID!)'"
                    
                    do {
                        
                        let result1 = dbObj?.executeUpdate(deleteSQL1,withArgumentsIn: nil)
                        let result2 = dbObj?.executeUpdate(deleteSQL2,withArgumentsIn: nil)
                        
                    }
                    catch {
                      
                    }
                    
                    
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        


        
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        self.commentsData = []
        
        self.ticketDetailsTable.reloadData()
        
        self.navigationController?.isToolbarHidden = false
        
        self.initializeDatabase()
        
        self.configureTableView()
        
        if (HSConfig.isInternetAvailable())
        {
            self.downloadTicketDetails(){
                results in
            
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_id, ticket_subject, ticket_description, ticket_attachment, ticket_status, ticket_date FROM TABLE_TICKET WHERE ticket_id = '\(self.currentTicketID!)'"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                    
                        var attachment : String = (results?.string(forColumn: "ticket_attachment"))!
                    
                        var attachmentArray = attachment.components(separatedBy: "/")
                    
                        let fileName = attachmentArray[attachmentArray.count - 1]
                    
                        let date = "Reported on "+(results?.string(forColumn: "ticket_date"))!
                    
                        let jsonObject: [String: String] = [
                            "Name": self.defaults.value(forKey: "userName") as! String,
                            "TicketLogID" : (results?.string(forColumn: "ticket_id"))!,
                            "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "ticket_status"))!)!],
                            "Message" : (results?.string(forColumn: "ticket_description"))!,
                            "Date": date,
                            "Attachment": fileName,
                            "AttachmentURL": attachment
                        ]
                    
                        self.commentsData.append(jsonObject)
                    
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_log, ticket_id, log_name, log_status, log_message, log_date, log_attachment FROM TABLE_COMMENT WHERE ticket_id ='\(self.currentTicketID)'"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                    
                        let attachment : String = (results?.string(forColumn: "log_attachment"))!
                    
                        var attachmentArray = attachment.components(separatedBy: "/")
                    
                        let fileName = attachmentArray[attachmentArray.count - 1]
                    
                        let date = "Replied on "+(results?.string(forColumn: "log_date"))!
                    
                        let jsonObject: [String: String] = [
                            "Name": (results?.string(forColumn: "log_name"))!,
                            "TicketLogID" : (results?.string(forColumn: "ticket_log"))!,
                            "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "log_status"))!)!],
                            "Message" : (results?.string(forColumn: "log_message"))!,
                            "Date": date,
                            "Attachment": fileName,
                            "AttachmentURL": attachment
                        ]
                    
                        self.commentsData.append(jsonObject)
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
                DispatchQueue.main.async {
                    self.ticketDetailsTable.reloadData()
                }
            
            }
            
        }else
        {
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_id, ticket_subject, ticket_description, ticket_attachment, ticket_status, ticket_date FROM TABLE_TICKET WHERE ticket_id = '\(self.currentTicketID!)'"
                    
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                   withArgumentsIn: nil)
                    
                    
                    while results?.next() == true {
                        
                        let attachment : String = (results?.string(forColumn: "ticket_attachment"))!
                        
                        var attachmentArray = attachment.components(separatedBy: "/")
                        
                        let fileName = attachmentArray[attachmentArray.count - 1]
                        
                        let date = "Reported on "+(results?.string(forColumn: "ticket_date"))!
                        
                        let jsonObject: [String: String] = [
                            "Name": self.defaults.value(forKey: "userName") as! String,
                            "TicketLogID" : (results?.string(forColumn: "ticket_id"))!,
                            "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "ticket_status"))!)!],
                            "Message" : (results?.string(forColumn: "ticket_description"))!,
                            "Date": date,
                            "Attachment": fileName,
                            "AttachmentURL": attachment
                        ]
                        
                        self.commentsData.append(jsonObject)
                        
                        
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
                
                
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_log, ticket_id, log_name, log_status, log_message, log_date, log_attachment FROM TABLE_COMMENT WHERE ticket_id ='\(self.currentTicketID)'"
                    
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                   withArgumentsIn: nil)
                    
                    
                    while results?.next() == true {
                        
                        let attachment : String = (results?.string(forColumn: "log_attachment"))!
                        
                        var attachmentArray = attachment.components(separatedBy: "/")
                        
                        let fileName = attachmentArray[attachmentArray.count - 1]
                        
                        let date = "Replied on "+(results?.string(forColumn: "log_date"))!
                        
                        let jsonObject: [String: String] = [
                            "Name": (results?.string(forColumn: "log_name"))!,
                            "TicketLogID" : (results?.string(forColumn: "ticket_log"))!,
                            "Status" : self.constants.TicketStatus[Int((results?.string(forColumn: "log_status"))!)!],
                            "Message" : (results?.string(forColumn: "log_message"))!,
                            "Date": date,
                            "Attachment": fileName,
                            "AttachmentURL": attachment
                        ]
                        
                        self.commentsData.append(jsonObject)
                        
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
                
                DispatchQueue.main.async {
                    self.ticketDetailsTable.reloadData()
                }
            
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func didMove(toParentViewController parent: UIViewController?)
    {
        if parent == nil
        {
            TicketHomeController().navigationController?.isToolbarHidden = true
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            if selectedRowIndex.contains(indexPath.row)
            {
                return UITableViewAutomaticDimension
            }
        return 130.0
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
        if let index = selectedRowIndex.index(of: indexPath.row)
        {
            selectedRowIndex.remove(at: index)
        }
        else
        {
            selectedRowIndex.append(indexPath.row)
        }
        
        ticketDetailsTable.beginUpdates()
        ticketDetailsTable.endUpdates()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! TicketDetailsCell
        
        cell.labelName.text = commentsData[indexPath.row]["Name"]
        cell.labelStatus.text = commentsData[indexPath.row]["Status"]
        cell.labelDescription.text = commentsData[indexPath.row]["Message"]
        
        
        cell.attachmentButton.setTitle("View Attachments", for: .normal)
        
        cell.attachmentButton.tag = indexPath.row
        
        cell.attachmentButton.addTarget(self, action: #selector(self.onAttachmentPressed), for: .touchUpInside)
        
        if (commentsData[indexPath.row]["AttachmentURL"]! == "")
        {
            cell.attachmentButton.isHidden = true
            cell.attachmentButton.isEnabled = false
        }
        
        cell.labelDate.text = commentsData[indexPath.row]["Date"]
        
        cell.attachmentURL = commentsData[indexPath.row]["AttachmentURL"]!
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        
        return cell
    }
    
    func onAttachmentPressed(_ sender: UIButton) {

        self.currentAttachementURL = commentsData[sender.tag]["AttachmentURL"]
        
        self.performSegue(withIdentifier: "showAllSegue", sender: sender)

    }
    
    func configureTableView() {
        self.ticketDetailsTable.delegate = self
        self.ticketDetailsTable.dataSource = self
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        
        self.ticketDetailsTable.register(UINib(nibName: "TicketDetailCell", bundle: resourceBundle), forCellReuseIdentifier: "detailCell")
        self.ticketDetailsTable.estimatedRowHeight = 130.0
    }
    
    func initializeDatabase()
    {
        let dbObj = FMDatabase(path: defaults.value(forKey: "databasePath") as! String)
        
        if dbObj == nil {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        if (dbObj?.open())!
        {
            let sql_stmt = "CREATE TABLE IF NOT EXISTS TABLE_COMMENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, TICKET_LOG TEXT, TICKET_ID TEXT, LOG_NAME TEXT, LOG_STATUS TEXT, LOG_MESSAGE TEXT, LOG_DATE TEXT, LOG_ATTACHMENT TEXT)"
            if !(dbObj?.executeStatements(sql_stmt))! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            dbObj?.close()
        }
        else
        {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        if (dbObj?.open())! {
            
            let deleteSQL = "DELETE FROM TABLE_COMMENT WHERE ticket_id = '\(self.currentTicketID!)'"
            
            let result = dbObj?.executeUpdate(deleteSQL,
                                              withArgumentsIn: nil)
            
            if !result! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }

        
    }
    
    func downloadTicketDetails(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var lastUpdateDateTime:String = ""
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let constants = Constants()
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())! {
            let querySQL = "SELECT ticket_update_time,ticket_id, ticket_description FROM TABLE_TICKET WHERE ticket_id = '\(self.currentTicketID!)'"
            
            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                           withArgumentsIn: nil)
            
            
            while results?.next() == true {
                
                lastUpdateDateTime = (results?.string(forColumn: "ticket_update_time"))!
                
            }
            dbObj?.close()
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        
        let url = URL(string: constants.AppUrl+"ticketlog")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "action":"list",
            "ticket_id": self.currentTicketID,
            "modified_datetime" : lastUpdateDateTime
        ]
        
        var data : AnyObject
        
        let dict = jsonObject as NSDictionary
        do
        {
            
            data = try JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted) as AnyObject
            
            
            let strData = NSString(data: (data as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            data = strData.data(using: String.Encoding.utf8)! as AnyObject
            
            
            let task = defaultSession.uploadTask(with: request, from: (data as! NSData) as Data, completionHandler:
                {(data,response,error) in
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                        
                        
                        
                        let alertController:UIAlertController? = UIAlertController(title: "",
                                                                                   message: "Error loading ticket details",
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
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    for i in 0..<json["response"]["TicketLog"].count
                    {
                        
                        if (dbObj?.open())!
                        {
                            if String(describing: json["response"]["TicketLog"][i]["log_id"]) != "null"
                            {
                     
                                let logName = String(describing: json["response"]["TicketLog"][i]["first_name"])+" "+String(describing: json["response"]["TicketLog"][i]["last_name"])
                                
                                let attachments = String(describing: json["response"]["TicketLog"][i]["attachfiles"])
                                
                                var attachementString = attachments.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                                
                                let insertSQL = "INSERT INTO TABLE_COMMENT (ticket_log, ticket_id, log_name, log_status, log_message, log_date, log_attachment) VALUES ('\(String(describing: json["response"]["TicketLog"][i]["log_id"]))', '\(self.currentTicketID)', '\(logName)', '\(String(describing: json["response"]["TicketLog"][i]["ticket_status"]))', '\(String(describing: json["response"]["TicketLog"][i]["reply_message"]))','\(String(describing: json["response"]["TicketLog"][i]["reply_date"]))', '\(String(describing: json["response"]["TicketLog"][i]["attachfiles"][0]))')"
                                
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
                    
                    if (dbObj?.open())!
                    {
                        let updatedTime = String(describing: json["response"]["CurrentDateTime"])
                        let deleteSQL = "UPDATE TABLE_TICKET SET ticket_update_time = '\(updatedTime)' WHERE ticket_id ='\(self.currentTicketID!)'"
                       
                        do {
                        
                            try dbObj?.executeUpdate("UPDATE TABLE_TICKET SET ticket_update_time=? WHERE ticket_id=?", withArgumentsIn: [updatedTime, self.currentTicketID!])
                            

                        }
                        catch {

                        }
                        
                    
                    } else {
                        print("Error: \(dbObj?.lastErrorMessage())")
                    }
                    
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
        
    }
    
    func deleteTicket(completionHandler: @escaping (_ results: String) -> ())
    {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let constants = Constants()
        
        var ticketNo : String! = ""
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())! {
            let querySQL = "SELECT ticket_id, ticket_no FROM TABLE_TICKET WHERE ticket_id = '\(self.currentTicketID!)'"
            
            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                           withArgumentsIn: nil)
            
            
            while results?.next() == true {
                
                ticketNo = results?.string(forColumn: "ticket_no")
                
            }
            dbObj?.close()
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        let url = URL(string: constants.AppUrl+"ticket")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "action":"delete",
            "ticket_id": self.currentTicketID,
            "ticket_no": ticketNo
        ]
        
        var data : AnyObject
        
        let dict = jsonObject as NSDictionary
        do
        {
            
            data = try JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted) as AnyObject
            
            
            let strData = NSString(data: (data as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)! as String

            data = strData.data(using: String.Encoding.utf8)! as AnyObject
            
            
            let task = defaultSession.uploadTask(with: request, from: (data as! NSData) as Data, completionHandler:
                {(data,response,error) in
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                        
                        
                        
                        let alertController:UIAlertController? = UIAlertController(title: "",
                                                                                   message: "Error deleting ticket",
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
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addCommentSegue") {
            let viewController = segue.destination as! CommentController

            viewController.currentTicketID = self.currentTicketID
        }
        
        if (segue.identifier == "showAllSegue") {
            let viewController = segue.destination as! ViewAllAttachmentsController

            
            viewController.allAttachmentURL = self.currentAttachementURL
        }

    }


}
