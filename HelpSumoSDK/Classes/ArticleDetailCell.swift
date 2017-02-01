//
//  ArticleDetailCell.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 09/01/17.
//
//

import UIKit

class ArticleDetailCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelCommentedOn: UILabel!
    
    @IBOutlet weak var labelComment: UILabel!
    
    @IBOutlet weak var labelCommentHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
