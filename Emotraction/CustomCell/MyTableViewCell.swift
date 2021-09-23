//
//  MyTableViewCell.swift
//  Emotraction
//
//  Created by 김도연 on 2021/09/23.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatBackgroundView.layer.cornerRadius = chatBackgroundView.frame.height / 10
        chatBackgroundView.backgroundColor = .systemYellow
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
