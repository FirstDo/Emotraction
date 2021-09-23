//
//  BotTableViewCell.swift
//  Emotraction
//
//  Created by 김도연 on 2021/09/23.
//

import UIKit

class BotTableViewCell: UITableViewCell {

    @IBOutlet weak var botImage: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        botImage.image = UIImage(named: "bot") ?? nil
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
