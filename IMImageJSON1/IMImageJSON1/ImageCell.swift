//
//  ImageCell.swift
//  IMImageJSON1
//
//  Created by J K on 2019/1/29.
//  Copyright © 2019 KimsStudio. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    var imageViews: UIImageView!   //封面图
    var label: UILabel!   //封面标题
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screen = UIScreen.main.bounds
        
        label = UILabel(frame: CGRect(x: 10, y: 15, width: 140, height: 230))
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        self.addSubview(label)
        
        imageViews = UIImageView(frame: CGRect(x: 0, y: 0, width: 230, height: 230))
        imageViews.center = CGPoint(x: screen.width - 140, y: 130)
        imageViews.contentMode = UIView.ContentMode.scaleAspectFit
        imageViews.layer.masksToBounds = true
        self.addSubview(imageViews)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
