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
    
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments)
    }
}
