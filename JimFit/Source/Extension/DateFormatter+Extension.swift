//
//  DateFormatter+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

//extension DateFormatter {
//    
//    enum Formatter: String {
//        case headerDate = "header_date_formatter"
//        case grabberDate = "grabber_date_formatter"
//        case primaryKey = "yyyyMMdd"
//    }
//    
//    static func format(with: Formatter, from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = with.rawValue.localized
//        return dateFormatter.string(from: date)
//    }
//}

extension Date {
    
    enum Formatter: String {
        case headerDate = "header_date_formatter"
        case grabberDate = "grabber_date_formatter"
        case primaryKey = "yyyyMMdd"
    }
    
    func convert(to format: Formatter) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue.localized
        return dateFormatter.string(from: self)
    }
}
