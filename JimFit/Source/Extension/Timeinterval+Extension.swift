//
//  Timeinterval+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

extension TimeInterval {
    func formattedTime() -> String {
        let date = Date(timeIntervalSinceReferenceDate: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
}
