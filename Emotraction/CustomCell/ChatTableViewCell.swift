//
//  ChatTableViewCell.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/27.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var textMessage: UILabel!
    @IBOutlet weak var emotion: UILabel!
    @IBOutlet weak var chatView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatView.layer.cornerRadius = 10
        textMessage.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
