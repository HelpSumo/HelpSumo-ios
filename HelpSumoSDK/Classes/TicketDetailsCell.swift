//
//  TicketDetailsCell.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 14/12/16.
//
//

import UIKit

class TicketDetailsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelStatus: UILabel!
    
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var labelDescription: UILabel!
    
    @IBOutlet weak var attachmentButton: UIButton!
    
    @IBAction func onAttachmentPressed(_ sender: UIButton) {
        
        
        
    }
    
    @IBOutlet weak var labelAttachment: UILabel!
    
    @IBOutlet weak var labelAttachmentHeight: NSLayoutConstraint!
    
    var attachmentURL : String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    
        labelDescription.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
