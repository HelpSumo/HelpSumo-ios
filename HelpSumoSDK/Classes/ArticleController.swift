//
//  ArticleController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 04/01/17.
//
//

import UIKit
import FMDB

class ArticleController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var articleTable: UITableView!
    
    @IBOutlet weak var categoryDropDown: UIButton!
    
    @IBAction func OnSelectCategory(_ sender: UIButton) {
        if self.catDropDown.isHidden {
            self.catDropDown.show()
        } else {
            self.catDropDown.hide()
        }
    }
    
    
    @IBOutlet weak var subCategoryDropDown: UIButton!
    
    
    @IBAction func OnSelectSubCategory(_ sender: UIButton) {
        if self.subCatDropDown.isHidden {
            self.subCatDropDown.show()
        } else {
            self.subCatDropDown.hide()
        }
    }
    
    let catDropDown = DropDown()
    
    let subCatDropDown = DropDown()
    
    var articleData: [[String:String]] = []
    
    let defaults = UserDefaults.standard
    
    let constants = Constants()
    
    var categoryArray = [String]()
    
    var categoryIDArray = [String]()
    
    var selectedCategoryID : String = ""
    
    var subCategoryArray = [String]()
    
    var subCategoryIDArray = [String]()
    
    var selectedSubCategoryID : String = ""
    
    var selectedArticleID : String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.initializeDatabase()
        
        self.loadDropdownData(){
            results in
            
        }
        
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

        print(self.defaults.value(forKey: "userMail"))
        
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
                    
                    self.downloadArticle(){
                        results in
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                        
                        if (dbObj?.open())! {
                            let querySQL = "SELECT article_id, category_id, subcategory_id, title, date, rating ,comment_count, status, totalviews FROM TABLE_ARTICLE where status = '1'"
                            
                            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                           withArgumentsIn: nil)
                            
                            
                            while results?.next() == true {
                                
                                
                                let jsonObject: [String: String] = [
                                    "ArticleID" : (results?.string(forColumn: "article_id"))!,
                                    "Title" : (results?.string(forColumn: "title"))!,
                                    "Date": (results?.string(forColumn: "date"))!,
                                    "Rating": (results?.string(forColumn: "rating"))!,
                                    "CommentCount": (results?.string(forColumn: "comment_count"))!,
                                    ]
                                
                                self.articleData.append(jsonObject)
                                
                            }
                            dbObj?.close()
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        DispatchQueue.main.async {
                            self.articleTable.reloadData()
                        }
                        
                    }
                }
            
            }))
            self.present(alertController, animated: true, completion: { _ in })
        }
        
        self.catDropDown.anchorView = categoryDropDown
        
        self.catDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedCategoryID = self.categoryIDArray[index]
            self.categoryDropDown.setTitle(item, for: .normal)
            
            
            self.subCategoryArray = []
            self.subCategoryIDArray = []
            
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 6 AND status = '1' AND parentid = '\(self.selectedCategoryID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    self.subCategoryArray.append((results?.string(forColumn: "name"))!)
                    
                    self.subCategoryIDArray.append((results?.string(forColumn: "serverid"))!)
                    
                }
                
                self.subCatDropDown.dataSource = self.subCategoryArray
                
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            self.articleData = []
            
            if (dbObj?.open())! {
                let querySQL = "SELECT article_id, category_id, subcategory_id, title, date, rating ,comment_count, status, totalviews FROM TABLE_ARTICLE where status = '1' and category_id = '\(self.selectedCategoryID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "ArticleID" : (results?.string(forColumn: "article_id"))!,
                        "Title" : (results?.string(forColumn: "title"))!,
                        "Date": (results?.string(forColumn: "date"))!,
                        "Rating": (results?.string(forColumn: "rating"))!,
                        "CommentCount": (results?.string(forColumn: "comment_count"))!,
                        ]
                    
                    self.articleData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.articleTable.reloadData()
            }
            
            
        }
        
        self.subCatDropDown.anchorView = subCategoryDropDown
        
        self.subCatDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedSubCategoryID = self.subCategoryIDArray[index]
            self.subCategoryDropDown.setTitle(item, for: .normal)
            
            self.articleData = []
            
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT article_id, category_id, subcategory_id, title, date, rating ,comment_count, status, totalviews FROM TABLE_ARTICLE where status = '1' and category_id = '\(self.selectedCategoryID)' and subcategory_id = '\(self.selectedSubCategoryID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "ArticleID" : (results?.string(forColumn: "article_id"))!,
                        "Title" : (results?.string(forColumn: "title"))!,
                        "Date": (results?.string(forColumn: "date"))!,
                        "Rating": (results?.string(forColumn: "rating"))!,
                        "CommentCount": (results?.string(forColumn: "comment_count"))!,
                        ]
                    
                    self.articleData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.articleTable.reloadData()
            }
            
        }
        
        if (HSConfig.isInternetAvailable() && String(describing: defaults.value(forKey: "userMail")) != "nil" )
        {
            self.downloadArticle(){
                results in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT article_id, category_id, subcategory_id, title, date, rating ,comment_count, status, totalviews FROM TABLE_ARTICLE where status = '1'"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                    
                    
                        let jsonObject: [String: String] = [
                            "ArticleID" : (results?.string(forColumn: "article_id"))!,
                            "Title" : (results?.string(forColumn: "title"))!,
                            "Date": (results?.string(forColumn: "date"))!,
                            "Rating": (results?.string(forColumn: "rating"))!,
                            "CommentCount": (results?.string(forColumn: "comment_count"))!,
                            ]
                    
                        self.articleData.append(jsonObject)
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
                DispatchQueue.main.async {
                    self.articleTable.reloadData()
                }
            
            }
        }
        else
        {
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT article_id, category_id, subcategory_id, title, date, rating ,comment_count, status, totalviews FROM TABLE_ARTICLE where status = '1'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "ArticleID" : (results?.string(forColumn: "article_id"))!,
                        "Title" : (results?.string(forColumn: "title"))!,
                        "Date": (results?.string(forColumn: "date"))!,
                        "Rating": (results?.string(forColumn: "rating"))!,
                        "CommentCount": (results?.string(forColumn: "comment_count"))!,
                        ]
                    
                    self.articleData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.articleTable.reloadData()
            }
        }
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        
        self.articleTable.register(UINib(nibName: "ArticleCell", bundle: resourceBundle), forCellReuseIdentifier: "singleArticleCell")
        self.articleTable.estimatedRowHeight = 130.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.articleData.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleArticleCell", for: indexPath) as! ArticleCell
        
        
        
        let attributedString = NSMutableAttributedString()
        
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string:self.articleData[indexPath.row]["Title"]!, attributes:attrs)
        
        attributedString.append(boldString)
        
        cell.articleID = self.articleData[indexPath.row]["ArticleID"]
        
        cell.labelTitle.attributedText = attributedString
        
        cell.labelDate.text = self.articleData[indexPath.row]["Date"]
        
        cell.labelCommentCount.text = self.articleData[indexPath.row]["CommentCount"]
        
        let rt = self.articleData[indexPath.row]["Rating"]
 
        cell.starRating.text = String(format: "%.1f", Double(rt!)!)
        cell.starRating.rating = Double(rt!)!
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! ArticleCell
        
        self.selectedArticleID = cell.articleID
        
        
        self.performSegue(withIdentifier: "showArticleSegue", sender: tableView)
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
            let sql_stmt = "CREATE TABLE IF NOT EXISTS TABLE_ARTICLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, ARTICLE_ID TEXT, CATEGORY_ID TEXT, SUBCATEGORY_ID TEXT, TITLE TEXT NOT NULL, DATE TEXT, RATING TEXT, DESCRIPTION TEXT, COMMENT_COUNT TEXT, STATUS TEXT, ARTICLE_LIKE TEXT, ARTICLE_UNLIKE TEXT, TOTALVIEWS TEXT, ARTICLE_LIKE_FLAG TEXT, ARTICLE_UPDATE_TIME TEXT)"
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
            let sql_stmt = "CREATE TABLE IF NOT EXISTS TABLE_ARTICLE_COMMENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, ARTICLE_ID TEXT, NAME TEXT NOT NULL, DATE TEXT, COMMENT TEXT)"
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

    
    func loadDropdownData(completionHandler: @escaping (_ results: String) -> ())
    {
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        
        let url = URL(string: constants.AppUrl+"article_categories")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "action":"list",
            "modified_date": String(describing: defaults.value(forKey: "articleCategoryModifiedDate")) == "nil" ? "" : String(describing: defaults.value(forKey: "articleCategoryModifiedDate")!)
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
                    
                    
                    self.defaults.set(String(describing: json["response"]["CurrentDateTime"]), forKey: "articleCategoryModifiedDate")
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    
                    if json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"].count > 0
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 5"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                        
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM DROPDOWNDATA WHERE TYPE = 6"
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"].count
                    {
                        
                        if (String(describing: json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["parent_id"]) == "0")
                        {
                            if (dbObj?.open())! {
                                
                                let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status, parentid) VALUES (5, '\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["category_id"]))', '\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["category_title"]))','\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["status"]))','\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["parent_id"]))')"
                                
                                let result = dbObj?.executeUpdate(insertSQL,
                                                                  withArgumentsIn: nil)
                                
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }
                            } else {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                            
                        }else
                        {
                            if (dbObj?.open())! {
                                
                                let insertSQL = "INSERT INTO DROPDOWNDATA (type, serverid, name, status, parentid) VALUES (6, '\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["category_id"]))', '\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["category_title"]))','\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["status"]))','\(String(describing:json["response"]["ARTICLE_CATEGORY_SUBCATEGORY"][i]["parent_id"]))')"
                                
                                let result = dbObj?.executeUpdate(insertSQL,
                                                                  withArgumentsIn: nil)
                                
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }
                            } else {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                            
                        }
                        
                        
                        
                    }
                    
                    if (dbObj?.open())! {
                        let querySQL = "SELECT serverid, name FROM DROPDOWNDATA WHERE TYPE = 5 AND status = '1'"
                        
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
    
    func downloadArticle(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.articleData = []
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URL(string: constants.AppUrl+"article")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "email": String(describing: defaults.value(forKey: "userMail")) == "nil" ? "" : String(describing: defaults.value(forKey: "userMail")!),
            "action": "list",
            "modified_date": String(describing: defaults.value(forKey: "articleModifiedDate")) == "nil" ? "" : String(describing: defaults.value(forKey: "articleModifiedDate")!),
            //"email": String(describing: defaults.value(forKey: "userMail")) == "nil" ? "" : String(describing: defaults.value(forKey: "userMail")!)
            ]
        
        var data : AnyObject
        
        let dict = jsonObject as NSDictionary
        do
        {
            
            data = try JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted) as AnyObject
            
            let strData = NSString(data: (data as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(strData)
            
            data = strData.data(using: String.Encoding.utf8)! as AnyObject
            
            
            let task = defaultSession.uploadTask(with: request, from: (data as! NSData) as Data, completionHandler:
                {(data,response,error) in
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                        
                        return
                    }
                    
                    let json = JSON(data: data!)
                    
                    print(json)
                    
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
    
                    var articleIDs = [String]()
                    
                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    if json["response"]["ARTICLE"].count > 0
                    {
                        
                        if (dbObj?.open())! {
                            let querySQL = "SELECT article_id FROM TABLE_ARTICLE"
                            
                            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                                           withArgumentsIn: nil)
                            
                            
                            while results?.next() == true {
                                
                                articleIDs.append((results?.string(forColumn: "article_id"))!)
                                
                            }
                            dbObj?.close()
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    
                    for i in 0..<json["response"]["ARTICLE"].count
                    {
                        
                        let newArticleID: String! = String(describing: json["response"]["ARTICLE"][i]["article_id"])
                        
                        if (dbObj?.open())!
                        {
                            if let existingFaq = articleIDs.index(of:newArticleID)
                            {
                                let like = Float(String(describing: json["response"]["ARTICLE"][i]["like"]))
                                
                                let unlike = Float(String(describing: json["response"]["ARTICLE"][i]["unlike"]))
                                
                                let sum: Float = like! + unlike!
                                
                                var rating: Float = 0.0
                                
                                if (sum != 0)
                                {
                                    rating = (like!/sum) * 5.0
                                }
                                
                                let updateSQL = "UPDATE TABLE_ARTICLE SET category_id = '\(String(describing: json["response"]["ARTICLE"][i]["category_id"]))', subcategory_id = '\(String(describing: json["response"]["ARTICLE"][i]["subcategory_id"]))', title = '\(String(describing: json["response"]["ARTICLE"][i]["article_title"]))', description = '\(String(describing: json["response"]["ARTICLE"][i]["article_description"]))', date = '\(String(describing: json["response"]["ARTICLE"][i]["modified_at"]))', rating = '\(rating)', comment_count = '\(String(describing: json["response"]["ARTICLE"][i]["comment"]))',  status = '1', totalviews = '\(String(describing: json["response"]["ARTICLE"][i]["totalviews"]))', article_like = '\(String(describing: json["response"]["ARTICLE"][i]["like"]))', article_unlike = '\(String(describing: json["response"]["ARTICLE"][i]["unlike"]))', article_like_flag = '\(String(describing: json["response"]["ARTICLE"][i]["check"]))' WHERE article_id = '\(newArticleID)' "
                                
                                let result = dbObj?.executeUpdate(updateSQL,
                                                                  withArgumentsIn: nil)
                                
                                if !result! {
                                    print("Error: \(dbObj?.lastErrorMessage())")
                                }
                                
                            }
                            else
                            {
                                
                                let like = Float(String(describing: json["response"]["ARTICLE"][i]["like"]))
                                
                                let unlike = Float(String(describing: json["response"]["ARTICLE"][i]["unlike"]))
                                
                                let sum: Float = like! + unlike!
                                
                                var rating: Float = 0.0
                                
                                if (sum != 0)
                                {
                                    rating = (like!/sum) * 5.0
                                }
                                
                                let insertSQL = "INSERT INTO TABLE_ARTICLE (article_id, category_id, subcategory_id, title, description, date, rating ,comment_count, status, totalviews, article_update_time, article_like, article_unlike, article_like_flag) VALUES ('\(String(describing: json["response"]["ARTICLE"][i]["article_id"]))','\(String(describing: json["response"]["ARTICLE"][i]["category_id"]))','\(String(describing: json["response"]["ARTICLE"][i]["subcategory_id"]))','\(String(describing: json["response"]["ARTICLE"][i]["article_title"]))','\(String(describing: json["response"]["ARTICLE"][i]["article_description"]))', '\(String(describing: json["response"]["ARTICLE"][i]["modified_at"]))', '\(String(rating))', '\(String(describing: json["response"]["ARTICLE"][i]["comment"]))', '1', '\(String(describing: json["response"]["ARTICLE"][i]["totalviews"]))','', '\(String(describing: json["response"]["ARTICLE"][i]["like"]))', '\(String(describing: json["response"]["ARTICLE"][i]["unlike"]))','\(String(describing: json["response"]["ARTICLE"][i]["check"]))')"
                                
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
                    
                    self.defaults.set(String(describing: json["response"]["CurrentDateTime"]), forKey: "articleModifiedDate")
                    
                    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if (segue.identifier == "showArticleSegue") {
            let viewController = segue.destination as! ArticleDetailController
            
            viewController.currentArticleID = self.selectedArticleID
        }
    }


}
