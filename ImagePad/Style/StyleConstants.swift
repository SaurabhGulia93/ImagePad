//
//  File.swift
//  ImagePad
//
//  Created by Saurabh on 15/11/18.
//  Copyright © 2018 SaurabhGulia. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    static var MustardColor: UIColor {
        return RGB(red: 255, green: 140, blue: 26)
    }
    
}

func RGB(red: Int, green: Int, blue: Int) -> UIColor {
    return UIColor(red: red, green: green, blue: blue)
}
