//
//  CommentController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 15/12/16.
//
//

import UIKit
import FMDB

class CommentController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var statusDropDown: UIButton!
    
    
    @IBAction func onStatusSelected(_ sender: UIButton) {
        if self.statsDropDown.isHidden {
            self.statsDropDown.show()
        } else {
            self.statsDropDown.hide()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func onSavePressed(_ sender: UIBarButtonItem) {
        
        if statusDropDown.currentTitle! == "Please select"
        {
            let alertController:UIAlertController? = UIAlertController(title: "",
                                                                       message: "Please select the ticket status",
                                                                       preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Okay",style: .default,
                                            handler:nil)
            
            alertController!.addAction(alertAction)
            
            OperationQueue.main.addOperation {
                self.present(alertController!,animated: true, completion: nil)
            }
            return
        }

        if (self.commentText.text.isEmpty)
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
        }
        
        
        self.addComment(statusID: self.selectedStatusID, comment: self.commentText.text)
    }
    
    @IBAction func onUploadImagePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var commentText: UITextView!
    
    let statsDropDown = DropDown()
    
    let TicketStatus:[String] = ["New", "Open", "Progress", "Fixed", "Closed", "Archive"]
    
    var selectedStatusID : String = ""
    
    var currentTicketID:String! = ""
    
    var isSuccessfull : String! = ""
    
    var constants = Constants()
    
    let defaults = UserDefaults.standard
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isToolbarHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.statsDropDown.anchorView = statusDropDown
        
        self.statsDropDown.selectionAction = { [unowned self] (index, item) in
            self.selectedStatusID = String(Int(index) + 1)
            self.statusDropDown.setTitle(item, for: .normal)
        }

        self.statsDropDown.dataSource = self.TicketStatus
        
        imagePicker.delegate = self
        
        commentText.layer.borderColor = UIColor(red: CGFloat(204.0 / 255.0), green: CGFloat(204.0 / 255.0), blue: CGFloat(204.0 / 255.0), alpha: CGFloat(1.0)).cgColor
        commentText.layer.borderWidth = 1.0
        commentText.layer.cornerRadius = 5

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addComment(statusID:String,comment:String)
    {
        let constants = Constants()
        let myUrl = NSURL(string: constants.AppUrl+"ticketlog_add");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        let param: [String:String] = [
            "apikey": HSConfig.getAPIKey(),
            "email": defaults.value(forKey: "userMail") as! String,
            "ticket_status": statusID,
            "reply_message": comment,
            "ticket_id": self.currentTicketID
        ]
        
        if (self.imageView.image != nil)
        {
            
            let boundary = generateBoundaryString()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let imageData = UIImageJPEGRepresentation(self.imageView.image!, 1)
            
            if(imageData==nil)  { return; }
        
            request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary)
            
        }else
        {
            let boundary = generateBoundaryString()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = createBodyWithParameters(parameters: param, boundary: boundary)
            
        }
        
        
        
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
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
 
            
            self.isSuccessfull = String(describing: json["SUCCESS"])
            
            if (self.isSuccessfull != "null")
            {
                self.navigationController?.popViewController(animated: true)
            }
            
            
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
        
        let filename = "file"
        
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body as Data
    }
    
    func createBodyWithParameters(parameters: [String: String]?, boundary: String) -> Data {
        var body = NSMutableData();
        
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        return body as Data
    }


}
