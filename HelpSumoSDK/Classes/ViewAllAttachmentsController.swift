//
//  ViewAllAttachmentsController.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 26/12/16.
//
//

import UIKit

class ViewAllAttachmentsController: UIViewController {

    var allAttachmentURL : String = ""
    
    var attachmentURLArray : [String] = []
    
    var selectedAttachmentURL : String = ""
    
    @IBOutlet weak var attachment1: UIButton!
    
    @IBOutlet weak var attachment1Height: NSLayoutConstraint!
    
    @IBAction func onAttachment1Pressed(_ sender: UIButton) {
        self.selectedAttachmentURL = self.attachmentURLArray[0]
        self.performSegue(withIdentifier: "showAttachmentSegue", sender: sender)
    }
    
    @IBOutlet weak var attachment2: UIButton!
    
    @IBOutlet weak var attchment2Height: NSLayoutConstraint!
    
    
    @IBAction func onAttachment2Pressed(_ sender: UIButton) {
        self.selectedAttachmentURL = self.attachmentURLArray[1]
        self.performSegue(withIdentifier: "showAttachmentSegue", sender: sender)
    }
    
    @IBOutlet weak var attchment3: UIButton!
    
    @IBOutlet weak var attachment3Height: NSLayoutConstraint!
    
    @IBAction func onAttachment3Pressed(_ sender: UIButton) {
        self.selectedAttachmentURL = self.attachmentURLArray[2]
        self.performSegue(withIdentifier: "showAttachmentSegue", sender: sender)
    }
    
    @IBOutlet weak var attachment4: UIButton!
    
    @IBOutlet weak var attachment4Height: NSLayoutConstraint!
    
    @IBAction func onAttachment4Pressed(_ sender: UIButton) {
        self.selectedAttachmentURL = self.attachmentURLArray[3]
        self.performSegue(withIdentifier: "showAttachmentSegue", sender: sender)
    }
    
    @IBOutlet weak var attachment5: UIButton!
    
    @IBOutlet weak var attachment5Height: NSLayoutConstraint!
    
    
    @IBAction func onAttachment5Pressed(_ sender: UIButton) {
        self.selectedAttachmentURL = self.attachmentURLArray[4]
        self.performSegue(withIdentifier: "showAttachmentSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachment1.isHidden = true
        attachment2.isHidden = true
        attchment3.isHidden = true
        attachment4.isHidden = true
        attachment5.isHidden = true
        
        
        var attachmentsArray : [String] = self.allAttachmentURL.components(separatedBy: ",")
        
        for i in 0..<attachmentsArray.count
        {
            if !attachmentsArray[i].isEmpty
            {
                switch (i)
                {

                case 0:
                    self.attachmentURLArray.append(attachmentsArray[i])
                    var componentsArray = attachmentsArray[i].components(separatedBy: "/")
                    
                    let fileName = componentsArray[componentsArray.count - 1]

                    attachment1.setTitle(fileName, for: .normal)
                    attachment1.isHidden = false
                    attachment1Height.priority = 250
                case 1:
                    self.attachmentURLArray.append(attachmentsArray[i])
                    var componentsArray = attachmentsArray[i].components(separatedBy: "/")
                    
                    let fileName = componentsArray[componentsArray.count - 1]
                    
                    attachment2.setTitle(fileName, for: .normal)
                    attachment2.isHidden = false
                    attchment2Height.priority = 250
                    
                case 2:
                    self.attachmentURLArray.append(attachmentsArray[i])
                    var componentsArray = attachmentsArray[i].components(separatedBy: "/")
                    
                    let fileName = componentsArray[componentsArray.count - 1]
                    
                    attchment3.setTitle(fileName, for: .normal)
                    attchment3.isHidden = false
                    attachment3Height.priority = 250
                case 3:
                    self.attachmentURLArray.append(attachmentsArray[i])
                    var componentsArray = attachmentsArray[i].components(separatedBy: "/")
                    
                    let fileName = componentsArray[componentsArray.count - 1]
                    
                    attachment4.setTitle(fileName, for: .normal)
                    attachment4.isHidden = false
                    attachment4Height.priority = 250
                case 4:
                    self.attachmentURLArray.append(attachmentsArray[i])
                    var componentsArray = attachmentsArray[i].components(separatedBy: "/")
                    
                    let fileName = componentsArray[componentsArray.count - 1]
                    
                    attachment5.setTitle(fileName, for: .normal)
                    attachment5.isHidden = false
                    attachment5Height.priority = 250
                    
                default:
                    print("test")
                    
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showAttachmentSegue") {
            let viewController = segue.destination as! ViewAttachmentController
            viewController.attachmentURL = self.selectedAttachmentURL
        }
    }
    
}
