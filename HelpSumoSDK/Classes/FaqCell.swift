//
//  FaqCell.swift
//  Pods
//
//  Created by APP DEVELOPEMENT on 29/12/16.
//
//

import UIKit

class FaqCell: UITableViewCell {

    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var labelAnswer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
