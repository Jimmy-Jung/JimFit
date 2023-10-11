//
//  UIVIew+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/11.
//

import UIKit

extension UIView {
   func roundCorners(corners: CACornerMask , radius: CGFloat) {
       self.layer.cornerRadius = radius
       self.layer.maskedCorners = corners
    }
}
