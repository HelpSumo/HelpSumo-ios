//
//  ArticleDetailController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 07/01/17.
//
//

import UIKit
import FMDB
import Cosmos

class ArticleDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var currentArticleID : String = ""

    @IBOutlet weak var articleTitle: UILabel!
    
    @IBOutlet weak var articleRating: CosmosView!
    
    @IBOutlet weak var articleViewCount: UILabel!
    
    @IBOutlet weak var articleDescription: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var commentsTable: UITableView!
    
    @IBOutlet weak var commentText: UITextView!
    
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var unlikeCount: UILabel!
    
    @IBOutlet weak var btnLike: UIButton!
    
    @IBOutlet weak var btnUnlike: UIButton!
    
    @IBAction func onLikePressed(_ sender: UIButton) {
        self.likeDislike(flag:"1")
        {
            results in
            
        }
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())!
        {
        
            let updateSQL = "UPDATE TABLE_ARTICLE SET article_like_flag = '1' where article_id = '\(self.currentArticleID)'"
            
            let result = dbObj?.executeUpdate(updateSQL,
                                              withArgumentsIn: nil)
            
            if !result! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        
        btnLike.isEnabled = false
        btnLike.setImage(UIImage(named: "like.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .disabled)
        btnUnlike.isEnabled = true
        btnUnlike.setImage(UIImage(named: "unlike_blur.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .normal)
        
    }
    
    
    @IBAction func onUnlikePressed(_ sender: UIButton) {
        self.likeDislike(flag:"2")
        {
            results in
            
        }
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())!
        {
            
            let updateSQL = "UPDATE TABLE_ARTICLE SET article_like_flag = '2' where article_id = '\(self.currentArticleID)'"
            
            let result = dbObj?.executeUpdate(updateSQL,
                                              withArgumentsIn: nil)
            
            if !result! {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        
        btnUnlike.isEnabled = false
        btnUnlike.setImage(UIImage(named: "unlike.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .disabled)
        btnLike.isEnabled = true
        btnLike.setImage(UIImage(named: "like_blur.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .normal)
    }

    @IBAction func onAddComment(_ sender: UIButton) {
        
        if (commentText.text == "Comment here" || commentText.text.isEmpty)
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please enter the comment",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            
            return
            
        }else
        {
            self.addComment(){
                results in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
    }
    
    @IBOutlet weak var headerView: UIView!
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    let defaults = UserDefaults.standard
    
    let constants = Constants()
    
    var commentData: [[String:String]] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.isScrollEnabled = true
        self.scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + 120)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentText.text = "Comment here"
        commentText.textColor = UIColor.lightGray
        
        commentText.layer.borderColor = UIColor(red: CGFloat(204.0 / 255.0), green: CGFloat(204.0 / 255.0), blue: CGFloat(204.0 / 255.0), alpha: CGFloat(1.0)).cgColor
        commentText.layer.borderWidth = 1.0
        commentText.layer.cornerRadius = 5
        
        articleRating.settings.updateOnTouch = false
        articleRating.settings.fillMode = .precise
        
        print(self.currentArticleID)
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())! {
            let querySQL = "SELECT article_id, category_id, subcategory_id, title, description, date, rating ,comment_count, status, totalviews, article_like, article_unlike , article_like_flag FROM TABLE_ARTICLE where article_id = '\(self.currentArticleID)'"
            
            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                           withArgumentsIn: nil)
            
            
            while results?.next() == true {
                
                    self.articleTitle.text = (results?.string(forColumn: "title"))!
                    self.articleDescription.text = (results?.string(forColumn: "description"))!
                    self.articleViewCount.text = "Views(" + (results?.string(forColumn: "totalviews"))! + ")"
                
                    let rtng: Double = Double((results?.string(forColumn: "rating"))!)!
                    self.articleRating.rating = rtng
                    self.articleRating.text = String(format: "%.1f", rtng)
                
                    self.likeCount.text = (results?.string(forColumn: "article_like"))!
                    self.unlikeCount.text = (results?.string(forColumn: "article_unlike"))!
                
                    let articleFlag = (results?.string(forColumn: "article_like_flag"))!
                
                
                    let frameworkBundle = Bundle(for:  TicketHomeController.self)
                    let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
                
                    if (articleFlag == "1")
                    {
                        btnLike.isEnabled = false
                        btnLike.setImage(UIImage(named: "like.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .disabled)
                        btnUnlike.isEnabled = true
                        btnUnlike.setImage(UIImage(named: "unlike_blur.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .normal)
                        
                    }
                    else if (articleFlag == "2")
                    {
                        btnUnlike.isEnabled = false
                        btnUnlike.setImage(UIImage(named: "unlike.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .disabled)
                        btnLike.isEnabled = true
                        btnLike.setImage(UIImage(named: "like_blur.png", in: Bundle(url: bundleURL!), compatibleWith: nil), for: .normal)
                    }
                
                
                
            }
            dbObj?.close()
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        
        self.commentsTable.tableFooterView = UIView()
        
        self.commentsTable.register(UINib(nibName: "ArticleDetailCell", bundle: resourceBundle), forCellReuseIdentifier: "singleArticleDetailCell")
        
        self.commentsTable.estimatedRowHeight = 130.0
        
        if (HSConfig.isInternetAvailable())
        {
            self.downloadArticle(){
                results in
            
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
                if (dbObj?.open())! {
                    let querySQL = "SELECT name, date, comment FROM TABLE_ARTICLE_COMMENT where article_id = '\(self.currentArticleID)'"
                
                    let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                    while results?.next() == true {
                    
                    
                        let jsonObject: [String: String] = [
                            "Name" : (results?.string(forColumn:"name"))!,
                            "Date" : (results?.string(forColumn: "date"))!,
                            "Comment": (results?.string(forColumn: "comment"))!
                        ]
                    
                        self.commentData.append(jsonObject)
                    
                    }
                    dbObj?.close()
                } else {
                    print("Error: \(dbObj?.lastErrorMessage())")
                }
            
                DispatchQueue.main.async {
                    self.commentsTable.reloadData()
                }
            
            }
        }else
        {
            let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
            
            if (dbObj?.open())! {
                let querySQL = "SELECT name, date, comment FROM TABLE_ARTICLE_COMMENT where article_id = '\(self.currentArticleID)'"
                
                let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
                
                
                while results?.next() == true {
                    
                    
                    let jsonObject: [String: String] = [
                        "Name" : (results?.string(forColumn:"name"))!,
                        "Date" : (results?.string(forColumn: "date"))!,
                        "Comment": (results?.string(forColumn: "comment"))!
                    ]
                    
                    self.commentData.append(jsonObject)
                    
                }
                dbObj?.close()
            } else {
                print("Error: \(dbObj?.lastErrorMessage())")
            }
            
            DispatchQueue.main.async {
                self.commentsTable.reloadData()
            }

        }
        
        self.scrollView.isScrollEnabled = true
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = self.view.bounds.size
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.commentData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleArticleDetailCell", for: indexPath) as! ArticleDetailCell
        
        cell.labelName.text = self.commentData[indexPath.row]["Name"]
        cell.labelCommentedOn.text = self.commentData[indexPath.row]["Date"]
        cell.labelComment.text = self.commentData[indexPath.row]["Comment"]
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func downloadArticle(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var lastUpdateDateTime:String = ""
        
        let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
        
        if (dbObj?.open())! {
            let querySQL = "SELECT article_update_time FROM TABLE_ARTICLE WHERE article_id = '\(self.currentArticleID)'"
            
            let results:FMResultSet? = dbObj?.executeQuery(querySQL,
                                                           withArgumentsIn: nil)
            
            while results?.next() == true {
                
                lastUpdateDateTime = (results?.string(forColumn: "article_update_time"))!
                
            }
            dbObj?.close()
        } else {
            print("Error: \(dbObj?.lastErrorMessage())")
        }
        
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URL(string: constants.AppUrl+"article")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "article_id": self.currentArticleID,
            "action": "comment_list",
            "modified_date": lastUpdateDateTime
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

                    let dbObj = FMDatabase(path: self.defaults.value(forKey: "databasePath") as! String)
                    
                    
                    if(json["response"]["ARTICLE_COMMENT"].count > 0)
                    {
                        if (dbObj?.open())! {
                            
                            let deleteSQL = "DELETE FROM TABLE_ARTICLE_COMMENT WHERE ARTICLE_ID ='\(self.currentArticleID)'"
                            
                            print(deleteSQL)
                            
                            let result = dbObj?.executeUpdate(deleteSQL,
                                                              withArgumentsIn: nil)
                            
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    for i in 0..<json["response"]["ARTICLE_COMMENT"].count
                    {
                        
                        let name: String! = String(describing: json["response"]["ARTICLE_COMMENT"][i]["first_name"]) + " " + String(describing: json["response"]["ARTICLE_COMMENT"][i]["last_name"])
                        
                        if (dbObj?.open())!
                        {
                            let insertSQL = "INSERT INTO TABLE_ARTICLE_COMMENT (name, article_id, date, comment) VALUES ('\(name!)','\(self.currentArticleID)','\(String(describing: json["response"]["ARTICLE_COMMENT"][i]["date"]))','\(String(describing: json["response"]["ARTICLE_COMMENT"][i]["article_comments"]))')"
        
                            let result = dbObj?.executeUpdate(insertSQL,
                                                                  withArgumentsIn: nil)
                                
                            if !result! {
                                print("Error: \(dbObj?.lastErrorMessage())")
                            }
                            
                        } else {
                            print("Error: \(dbObj?.lastErrorMessage())")
                        }
                    }
                    
                    if (dbObj?.open())!
                    {
                        let updatedTime = String(describing: json["response"]["CurrentDateTime"])
  
                        do {
                            
                            try dbObj?.executeUpdate("UPDATE TABLE_ARTICLE SET article_update_time=? WHERE article_id=?", withArgumentsIn: [updatedTime, self.currentArticleID])

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
    
    func addComment(completionHandler: @escaping (_ results: String) -> ())
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URL(string: constants.AppUrl+"article")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "article_id": self.currentArticleID,
            "action": "comment_add",
            "email": self.defaults.value(forKey: "userMail") as! String,
            "article_comments": commentText.text
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
                    
                    
                    let alertController:UIAlertController? = UIAlertController(title: "",
                                                                               message: String(describing: json["SUCCESS"]),
                                                                               preferredStyle: .alert)
                    
                    let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                    handler:nil)
                    
                    alertController!.addAction(alertAction)
                    
                    OperationQueue.main.addOperation {
                        self.present(alertController!,animated: true, completion: nil)
                    }
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }

            

    }
    
    func likeDislike(flag: String, completionHandler: @escaping (_ results: String) -> ())
    {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URL(string: constants.AppUrl+"article")!
        var request = URLRequest(url: url)
        request.addValue("text/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonObject: [String: String] = [
            "apikey": HSConfig.getAPIKey(),
            "article_id": self.currentArticleID,
            "action": "article_feedback",
            "email": self.defaults.value(forKey: "userMail") as! String,
            "rating": flag
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
                        
                        
                        
                        let alertController:UIAlertController? = UIAlertController(title: "",
                                                                                   message: "Error check your internet connection",
                                                                                   preferredStyle: .alert)
                        
                        let alertAction = UIAlertAction(title: "Okay",style: .default,
                                                        handler:nil)
                        
                        alertController!.addAction(alertAction)
                        
                        self.present(alertController!,animated: true, completion: nil)
                        
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

                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    completionHandler(dataString as! String)
            }
            );
            task.resume()
            
            
            
        }catch{
            
        }
        
        
    }
    
}
