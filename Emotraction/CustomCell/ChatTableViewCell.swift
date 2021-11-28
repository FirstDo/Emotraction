//
//  ChatTableViewCell.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/27.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var textMessage: UILabel!
    @IBOutlet weak var emotion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textMessage.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
