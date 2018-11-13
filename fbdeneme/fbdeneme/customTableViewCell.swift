//
//  customTableViewCell.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/12/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell {
    
    @IBOutlet weak var background: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        background.backgroundColor = UIColorFromHex(rgbValue: getMyBGColor( index: 0 ), alpha: 0.75)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func getMyBGColor(index: Int)->UInt32 {
        return UInt32(0xFFB372 - (0x10FBEC * index))
    }

}
