//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by PMJs on 3/4/2563 BE.
//  Copyright © 2563 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height/5
    }

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var lable: UILabel!
   
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
