//
//  ArticleCell.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 04/01/17.
//
//

import UIKit
import Cosmos

class ArticleCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var starRating: CosmosView!
    
    @IBOutlet weak var labelCommentCount: UILabel!
    
    var articleID:String! = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        starRating.settings.updateOnTouch = false
        starRating.settings.fillMode = .precise
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
