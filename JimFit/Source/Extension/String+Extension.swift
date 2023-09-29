//
//  String+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
