//
//  DateFormatter+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

extension Date {
    
    enum Formatter: String {
        case headerDate = "header_date_formatter"
        case grabberDate = "grabber_date_formatter"
        case primaryKey = "yyyyMMdd"
    }
    
    /// 지정된 형식을 사용하여 날짜를 문자열 표현으로 변환합니다.
    ///
    /// - Parameter format: 날짜 문자열에 사용할 형식입니다.
    /// - Returns: 지정된 형식으로 변환된 날짜의 문자열 표현입니다.
    func convert(to format: Formatter) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue.localized
        return dateFormatter.string(from: self)
    }
    
    /// 날짜를 주어진 형식으로 변환하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - format: 변환할 형식을 나타내는 Formatter 열거형 값입니다.
    ///   - difference: 날짜에 더할 일수를 나타내는 정수 값입니다.
    /// - Returns: 변환된 날짜를 나타내는 문자열입니다.
    func convert(to format: Formatter, difference: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue.localized
        let date = Calendar.current.date(byAdding: .day, value: difference, to: self)
        return dateFormatter.string(from: date!)
    }
}
