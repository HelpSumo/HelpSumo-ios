//
//  NewTicketController.swift
//  HelpSumoSDK
//
//  Created by APP DEVELOPEMENT on 28/11/16.
//  Copyright © 2016 APP DEVELOPEMENT. All rights reserved.
//

import UIKit
import FMDB

class NewTicketController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtEmailHeight: NSLayoutConstraint!
    
    @IBOutlet weak var departmentDropDown: UIButton!
    
    @IBAction func onDepartmentSelected(_ sender: UIButton) {
        if self.depDropDown.isHidden {
            self.depDropDown.show()
        } else {
            self.depDropDown.hide()
        }
    }
    
    @IBOutlet weak var priorityDropDown: UIButton!

    @IBAction func onPrioritySelected(_ sender: UIButton) {
        if self.priorDropDown.isHidden {
            self.priorDropDown.show()
        } else {
            self.priorDropDown.hide()
        }
    }
    
    @IBOutlet weak var typeDropDown: UIButton!
    
    
    @IBAction func onTypeSelected(_ sender: UIButton) {
        if self.typDropDown.isHidden {
            self.typDropDown.show()
        } else {
            self.typDropDown.hide()
        }
    }
    
    @IBOutlet weak var ticketMessage: UITextView!
    
    @IBAction func onUploadImagePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtSubject: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        
        
        let defaults = UserDefaults.standard
        
        let userID = defaults.value(forKey: "userID")
        
        if (userID == nil)
        {
        
        if (!txtName.isHidden)
        {
            if (txtName.text?.isEmpty)!
            {
                let alertController:UIAlertController? = UIAlertController(title: "",
                                                                           message: "Please enter your name",
                                                                           preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                handler:nil)
                
                alertController!.addAction(alertAction)
                
                OperationQueue.main.addOperation {
                    self.present(alertController!,animated: true, completion: nil)
                }
                
                return
            }
            
        }
        
        if (!txtEmail.isHidden)
        {
            if (txtEmail.text?.isEmpty)! || !self.isValidEmail(testStr: txtEmail.text!)
            {
                let alertController:UIAlertController? = UIAlertController(title: "",
                                                                           message: "Please enter a valid email address",
                                                                           preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                handler:nil)
                
                alertController!.addAction(alertAction)
                
                OperationQueue.main.addOperation {
                    self.present(alertController!,animated: true, completion: nil)
                }
                return
            }
        }
            
        }
        
        if (txtSubject.text?.isEmpty)!
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please enter the subject",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            
            return
        }
        
        if (ticketMessage.text.isEmpty)
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please enter the ticket message",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            return
        }
        
        if departmentDropDown.currentTitle! == "Please select"
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please select the department",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            return
        }
        
        if priorityDropDown.currentTitle! == "Please select"
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please select ticket priority",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            return
        }
        
        if typeDropDown.currentTitle! == "Please select"
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please select ticket type",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            return
        }
        
        if (!txtName.isHidden)
        {
            self.AddTicket(requesterName: txtName.text!, emailID: txtEmail.text!,subject: txtSubject.text!, message: ticketMessage.text!,departmentID: selectedDepartmentID,priorityID: selectedPriorityID,typeID: selectedTypeID) {
                results in
            
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if ((self.imageView.image) != nil && self.hasImageChanged)
                {
                    self.myImageUploadRequest(ImageFile: self.imageView.image!)
                }
                
                
                if (self.isSuccessfull != "null")
                {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        else
        {
            self.AddTicket(requesterName: defaults.value(forKey: "userName") as! String, emailID: defaults.value(forKey: "userMail") as! String,subject: txtSubject.text!, message: ticketMessage.text!,departmentID: selectedDepartmentID,priorityID: selectedPriorityID,typeID: selectedTypeID) {
                results in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if ((self.imageView.image) != nil && self.hasImageChanged)
                {
                    self.myImageUploadRequest(ImageFile: self.imageView.image!)
                }
                
                if (self.isSuccessfull != "null")
                {
                    self.navigationController?.popViewController(animated: true)
                }

            }
        
        }
    
        
    }
    
    let constants = Constants()
    
    let depDropDown = DropDown()
    
    let priorDropDown = DropDown()

    let typDropDown = DropDown()
    
    var departmentArray = [String]()
    
    var departmentIDArray = [String]()
    
    var selectedDepartmentID : String = ""
    
    var priorityArray = [String]()
    
    var priorityIDArray = [String]()
    
    var selectedPriorityID : String = ""

    var typeArray = [String]()
    
    var typeIDArray = [String]()
    
    var selectedTypeID : String = ""
    
    var newTicketID : String = ""
    
    var newTicketNumber : String = ""
    
    var isEdit : Bool = false
    
    var hasImageChanged : Bool = false
    
    var editTicketID : String! = ""
    
    var pageTitle : String! = ""
    
    var isSuccessfull : String! = ""

    let imagePicker = UIImagePickerController()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = self.view.bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.pageTitle
        
        ticketMessage.layer.borderColor = UIColor(red: CGFloat(204.0 / 255.0), green: CGFloat(204.0 / 255.0), blue: CGFloat(204.0 / 255.0), alpha: CGFloat(1.0)).cgColor
        ticketMessage.layer.borderWidth = 1.0
        ticketMessage.layer.cornerRadius = 5
        
        imagePicker.delegate = self
        
        let userID = defaults.value(forKey: "userMail")
        
        if (userID != nil)
        {
            txtName.isHidden = true
            txtEmail.isHidden = true
            nameHeight.priority = 1000
            txtNameHeight.priority = 1000
            emailHeight.priority = 1000
            txtEmailHeight.priority = 1000
        }
        
        self.initializeDatabase()
        
        self.scrollView.isScrollEnabled = true
        self.scrollView.frame = self.view.bounds

        self.loadDropdownData(){
            results in

            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if(self.isEdit)
            {
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                
                if (dbObj?.open())! {
                    let querySQL = "SELECT ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_name, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date FROM TABLE_TICKET WHERE ticket_id = '\(self.editTicketID!)'"
                    
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                   withArgumentsIn: nil)
                    
                    
                    while results?.next() == true {
                        
                        let ticketSubject: String! = results?.string(forColumn: "ticket_subject")
                        
                        let ticketDescription: String! = results?.string(forColumn: "ticket_description")
                        
                        let departmentID: String! = results?.string(forColumn: "department_id")
                    
                        let priorityID: String! = results?.string(forColumn: "priority_id")
                        
                        let typeID: String! = results?.string(forColumn: "type_id")
                        
                        let ticketAttachementURL : String! = results?.string(forColumn: "ticket_attachment")
                        
                        if(ticketAttachementURL != "null")
                        {
                            
                            if let checkedUrl = URL(string: ticketAttachementURL) {
                                self.imageView.contentMode = .scaleAspectFit
                                self.downloadImage(url: checkedUrl)
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.txtSubject.text = ticketSubject
                            self.ticketMessage.text = ticketDescription
                            
                            
                            if let depIndex = self.departmentIDArray.index(of: departmentID) {
                                self.depDropDown.selectRow(at: depIndex)
                                self.selectedDepartmentID = self.departmentIDArray[depIndex]
                                self.departmentDropDown.setTitle(self.departmentArray[depIndex], for: .normal)
                            }

                            
                            if let priorIndex = self.priorityIDArray.index(of: priorityID) {
                                self.priorDropDown.selectRow(at: priorIndex)
                                self.selectedPriorityID = self.priorityIDArray[priorIndex]
                                self.priorityDropDown.setTitle(self.priorityArray[priorIndex], for: .normal)
                            }

                            if let typIndex = self.typeIDArray.index(of: typeID) {
                                self.typDropDown.selectRow(at: typIndex)
                                self.selectedTypeID = self.typeIDArray[typIndex]
                                self.typeDropDown.setTitle(self.typeArray[typIndex], for: .normal)
                            }

                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            }
        }


        self.depDropDown.anchorView = departmentDropDown
        
        self.depDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedDepartmentID = self.departmentIDArray[index]
            self.departmentDropDown.setTitle(item, for: .normal)
        }
        
        self.priorDropDown.anchorView = priorityDropDown
        
        
        
        self.priorDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedPriorityID = self.priorityIDArray[index]
            self.priorityDropDown.setTitle(item, for: .normal)
        }
        
        self.typDropDown.anchorView = typeDropDown
        
        
        
        self.typDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedTypeID = self.typeIDArray[index]
            self.typeDropDown.setTitle(item, for: .normal)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            let sql_stmt = "CREATE TABLE IF NOT EXISTS DROPDOWNDATA (ID INTEGER PRIMARY KEY AUTOINCREMENT, TYPE INTEGER, SERVERID TEXT, NAME TEXT, STATUS TEXT, PARENTID TEXT)"
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
    
    func loadDropdownData(completionHandler: @escaping (_ results: String) -> ())
    {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        
        let url = URL(string: constants.AppUrl+"ticketlookup")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "datetime": String(describing: defaults.value(forKey: "ddDateTime")) == "nil" ? "" : String(describing: defaults.value(forKey: "ddDateTime")!)
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
                    
                    self.defaults.set(String(describing: json["datetime"]["CurrentDateTime"]), forKey: "ddDateTime")
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    
                    if json["department"].count > 0
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 1"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["department"].count
                    {
                        
                        if (dbObj?.open())! {
                            
                            let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status) VALUES (1, '\(String(describing: json["department"][i]["department_id"]))', '\(String(describing: json["department"][i]["department_name"]))','')"
                            
                            let result = dbObj?.executeUpdate(insertSQL,
                                                                  withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        
                    }
                    
                    if (dbObj?.open())! {
                        let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 1"
                        
                        let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                           withArgumentsIn: nil)
                        
                        
                        while results?.next() == true {
                            
                            self.departmentArray.append((results?.string(forColumn: "name"))!)
                            
                            self.departmentIDArray.append((results?.string(forColumn: "serverid"))!)
                            
                        }
                        dbObj?.close()
                    } else {
                        print("Error: \(dbObj?.lastErrorMessage())")
                    }

                    
                    self.depDropDown.dataSource = self.departmentArray
                    
                    if json["priority"].count > 0
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 2"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["priority"].count
                    {
                        
                        if (dbObj?.open())! {
                            
                            let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status) VALUES (2, '\(String(describing: json["priority"][i]["id"]))', '\(String(describing: json["priority"][i]["priority_name"]))','')"
                            
                            let result = dbObj?.executeUpdate(insertSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        
                    }
                    
                    if (dbObj?.open())! {
                        let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 2"
                        
                        let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                       withArgumentsIn: nil)
                        
                        
                        while results?.next() == true {
                            
                            self.priorityArray.append((results?.string(forColumn: "name"))!)
                            
                            self.priorityIDArray.append((results?.string(forColumn: "serverid"))!)
                            
                        }
                        dbObj?.close()
                    } else {
                        print("Error: \(dbObj?.lastErrorMessage())")
                    }
                    
                    self.priorDropDown.dataSource = self.priorityArray
                    
                    if json["tickettype"].count > 0
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 3"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["tickettype"].count
                    {
                        
                        if (dbObj?.open())! {
                            
                            let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status) VALUES (3, '\(String(describing: json["tickettype"][i]["ticket_type_id"]))', '\(String(describing: json["tickettype"][i]["type_name"]))','')"
                            
                            let result = dbObj?.executeUpdate(insertSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        
                    }
                    
                    if (dbObj?.open())! {
                        let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 3"
                        
                        let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                       withArgumentsIn: nil)
                        
                        
                        while results?.next() == true {
                            
                            self.typeArray.append((results?.string(forColumn: "name"))!)
                            
                            self.typeIDArray.append((results?.string(forColumn: "serverid"))!)
                            
                        }
                        dbObj?.close()
                    } else {
                        print("Error: \(dbObj?.lastErrorMessage())")
                    }

                    
                    self.typDropDown.dataSource = self.typeArray
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }

    }
    
    func AddTicket(requesterName: String,emailID: String,subject: String,message: String,departmentID: String,priorityID: String,typeID: String,completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        
        let url = URL(string: constants.AppUrl+"ticket")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "requestername": requesterName,
            "email": emailID,
            "subject": subject,
            "message": message,
            "action": isEdit ? "update" : "add",
            "ticket_id": self.editTicketID,
            "ticket_type_id": typeID,
            "ticket_priority_id": priorityID,
            "assign_department_id": departmentID
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
                                                                                   message: "Error creating ticket",
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

                    let defaults = UserDefaults.standard
                    
                    let userID = String(describing: json["response"]["user"][0]["user_id"])
                    
            
                    
                    self.isSuccessfull = String(describing: json["SUCCESS"])
                    
                    self.newTicketID = String(describing: json["response"]["ticket"][0]["ticket_id"])
                    
                    if (self.isEdit)
                    {
                        self.newTicketNumber = String(describing: json["response"]["ticket"]["ticket_no"])
                    }
                    else
                    {
                        self.newTicketNumber = String(describing: json["response"]["ticket"][0]["ticket_no"])
                    
                    }
                    
                    if (!userID.isEmpty && userID != "null" )
                    {
                        defaults.set(userID, forKey: "userID")
                    }
                    
                    if (!self.txtName.isHidden)
                    {
                        defaults.set(self.txtName.text, forKey: "userName")
                        defaults.set(self.txtEmail.text, forKey: "userMail")
                    }
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.hasImageChanged = true
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageView.image = nil
        dismiss(animated: true, completion: nil)
    }
    
    func myImageUploadRequest(ImageFile: UIImage)
    {
        let myUrl = NSURL(string: constants.AppUrl+"ticketattachment");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        let param : [String : String] = [
            "apikey": HSConfig.getAPIKey(),
            "ticket_no": self.newTicketNumber,
            "ticket_id": isEdit ? self.editTicketID : self.newTicketID
        ]

        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(ImageFile, 1)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
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
            
            if (dbObj?.open())! {
                
                let insertSQL = "UPDATE TABLE_TICKET SET ticket_attachment = '\(json["SUCCESS"])' WHERE ticket_id ='\(self.newTicketID)'"
                
                let result = dbObj?.executeUpdate(insertSQL,
                                                  withArgumentsIn: nil)
                
                if !result! {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            if (dbObj?.open())! {
                let querySQL = "SELECT ticket_subject, ticket_description, department_id, priority_id, type_id, ticket_attachment, staff_id, ticket_no, ticket_id, ticket_status, ticket_offline_flag, ticket_date FROM TABLE_TICKET WHERE ticket_id ='\(self.newTicketID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    print(results?.string(forColumn: "ticket_attachment"))
                    print(results?.string(forColumn: "ticket_description"))
                    print(results)
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            
        }
        
        task.resume()
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> Data {
        var body = NSMutableData();
        
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        let filename = randomString(length: 10)
        
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body as Data
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }



}
