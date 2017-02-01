//
//  FaqController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 29/12/16.
//
//

import UIKit
import FMDB

class FaqController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var faqTable: UITableView!
    
    @IBOutlet weak var categoryDropDown: UIButton!
    
    @IBAction func onCategorySelected(_ sender: UIButton) {
        if self.catDropDown.isHidden {
            self.catDropDown.show()
        } else {
            self.catDropDown.hide()
        }
        
    }
    
    let catDropDown = DropDown()
    
    var faqData: [[String:String]] = []
    
    var selectedRowIndex: [Int] = []
    
    let defaults = UserDefaults.standard
    
    let constants = Constants()
    
    var categoryArray = [String]()
    
    var categoryIDArray = [String]()
    
    var selectedCategoryID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.catDropDown.anchorView = categoryDropDown
        
        self.catDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedCategoryID = self.categoryIDArray[index]
            self.categoryDropDown.setTitle(item, for: .normal)
            
            
            self.faqData = []
            self.faqTable.reloadData()
            
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT faq_id, category_id, question, answer, status FROM TABLE_FAQ where status = '1' and category_id = '\(self.selectedCategoryID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "FaqID" : (results?.string(forColumn: "faq_id"))!,
                        "Question" : (results?.string(forColumn: "question"))!,
                        "Answer": (results?.string(forColumn: "answer"))!
                    ]
                    
                    self.faqData.append(jsonObject)
                
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.faqTable.reloadData()
            }

            
        }
        
        faqTable.tableFooterView = UIView()
        
        self.loadDropdownData(){
            results in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

        self.initializeDatabase()
        
        if (HSConfig.isInternetAvailable())
        {
        
            self.downloadFaq(){
                results in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT faq_id, category_id, question, answer, status FROM TABLE_FAQ where status = '1'"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                
                    
                        let jsonObject: [String: String] = [
                            "FaqID" : (results?.string(forColumn: "faq_id"))!,
                            "Question" : (results?.string(forColumn: "question"))!,
                            "Answer": (results?.string(forColumn: "answer"))!
                        ]
                    
                        self.faqData.append(jsonObject)
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
                DispatchQueue.main.async {
                    self.faqTable.reloadData()
                }
            
            }
        }else
        {
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT faq_id, category_id, question, answer, status FROM TABLE_FAQ where status = '1'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "FaqID" : (results?.string(forColumn: "faq_id"))!,
                        "Question" : (results?.string(forColumn: "question"))!,
                        "Answer": (results?.string(forColumn: "answer"))!
                    ]
                    
                    self.faqData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.faqTable.reloadData()
            }
        }
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        
        self.faqTable.register(UINib(nibName: "FaqCell", bundle: resourceBundle), forCellReuseIdentifier: "singleFaqCell")
        self.faqTable.estimatedRowHeight = 130.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.faqData.count;
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if selectedRowIndex.contains(indexPath.row)
        {
            return UITableViewAutomaticDimension
        }
        return 130.0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let index = selectedRowIndex.index(of: indexPath.row)
        {
            selectedRowIndex.remove(at: index)
        }
        else
        {
            selectedRowIndex.append(indexPath.row)
        }
        
        faqTable.beginUpdates()
        faqTable.endUpdates()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleFaqCell", for: indexPath) as! FaqCell
        
        
        
        let attributedString = NSMutableAttributedString()
        
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string:self.faqData[indexPath.row]["Question"]!, attributes:attrs)
        
        attributedString.append(boldString)
        
        cell.labelQuestion.attributedText = attributedString
        
        cell.labelAnswer.text = self.faqData[indexPath.row]["Answer"]
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell

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
            let sql_stmt = "CREATE TABLE IF NOT EXISTS TABLE_FAQ (ID INTEGER PRIMARY KEY AUTOINCREMENT, FAQ_ID TEXT, CATEGORY_ID TEXT, QUESTION TEXT, ANSWER TEXT , STATUS TEXT)"
            if !(dbObj?.executeStatements(sql_stmt))! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            dbObj?.close()
        }
        else
        {
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
    
    func downloadFaq(completionHandler: @escaping (_ results: String) -> ())
    {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URL(string: constants.AppUrl+"faq")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "action": "list",
            "modified_date": String(describing: defaults.value(forKey: "faqModifiedDate")) == "nil" ? "" : String(describing: defaults.value(forKey: "faqModifiedDate")!),
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
                                                                                   message: "Error downloading faq",
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
     
                    var faqIDs = [String]()
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    if json["response"]["FAQ"].count > 0
                    {
                        
                        if (dbObj?.open())! {
                            let querySQL = "SELECT faq_id FROM TABLE_FAQ"
                            
                            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                           withArgumentsIn: nil)
                            
                            
                            while results?.next() == true {
                                
                                faqIDs.append((results?.string(forColumn: "faq_id"))!)
                                
                            }
                            dbObj?.close()
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    
                    for i in 0..<json["response"]["FAQ"].count
                    {
                        
                        let newFaqID: String! = String(describing: json["response"]["FAQ"][i]["faq_id"])
                        
                        if (dbObj?.open())!
                        {
                            if let existingFaq = faqIDs.index(of:newFaqID)
                            {
                                let updateSQL = "UPDATE TABLE_FAQ SET category_id = '\(String(describing: json["response"]["FAQ"][i]["category_id"]))', question = '\(String(describing: json["response"]["FAQ"][i]["questions"]))', answer = '\(String(describing: json["response"]["FAQ"][i]["answer"]))', status = '\(String(describing: json["response"]["FAQ"][i]["status"]))' WHERE faq_id = '\(newFaqID)' "
  
                                let result = dbObj?.executeUpdate(updateSQL,
                                                                  withArgumentsIn: nil)
                                
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }
                                
                            }
                            else
                            {
                                let insertSQL = "INSERT INTO TABLE_FAQ (faq_id, category_id, question, answer, status) VALUES ('\(String(describing: json["response"]["FAQ"][i]["faq_id"]))','\(String(describing: json["response"]["FAQ"][i]["category_id"]))','\(String(describing: json["response"]["FAQ"][i]["questions"]))','\(String(describing: json["response"]["FAQ"][i]["answer"]))', '\(String(describing: json["response"]["FAQ"][i]["status"]))')"
 
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
                    
                    self.defaults.set(String(describing: json["response"]["CurrentDateTime"]), forKey: "faqModifiedDate")
                    
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
        
        
    }
    
    func loadDropdownData(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        
        let url = URL(string: constants.AppUrl+"faqcategory")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "action":"list",
            "modified_date": String(describing: defaults.value(forKey: "categoryModifiedDate")) == "nil" ? "" : String(describing: defaults.value(forKey: "categoryModifiedDate")!)
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
                                                                                   message: "Error loading category",
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
                    
                    self.defaults.set(String(describing: json["response"]["CurrentDateTime"]), forKey: "categoryModifiedDate")
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    
                    if json["response"]["FAQ_CATEGORY"].count > 0
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 4"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["response"]["FAQ_CATEGORY"].count
                    {
                        if (dbObj?.open())! {
                            
                            let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status) VALUES (4, '\(String(describing:json["response"]["FAQ_CATEGORY"][i]["category_id"]))', '\(String(describing:json["response"]["FAQ_CATEGORY"][i]["category_title"]))','\(String(describing:json["response"]["FAQ_CATEGORY"][i]["status"]))')"
                            
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
                        let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 4 AND status = '1'"
                        
                        let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                       withArgumentsIn: nil)
                        
                        
                        while results?.next() == true {
                            
                            self.categoryArray.append((results?.string(forColumn: "name"))!)
                            
                            self.categoryIDArray.append((results?.string(forColumn: "serverid"))!)
                            
                        }
                        dbObj?.close()
                    } else {
                        print("Error: \(dbObj?.lastErrorMessage())")
                    }
                    
                    
                    self.catDropDown.dataSource = self.categoryArray
                    
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
        
    }
    

}
