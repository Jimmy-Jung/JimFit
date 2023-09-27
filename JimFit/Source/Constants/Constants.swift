//
//  Constants.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/26.
//

import UIKit

enum K {
    enum Color {
        
        enum Primary {
            static let Orange = UIColor(named: "Orange")!
            static let Green = UIColor(named: "Green")!
            static let Blue = UIColor(named: "Blue")!
            static let Yellow = UIColor.systemYellow
            static let White = UIColor.white
            static let Label = UIColor.label
            static let Background = UIColor.systemBackground
        }

        enum Grayscale {
            static let Label = UIColor.secondaryLabel
            static let border_Thin = UIColor.systemGray
            static let border_Medium = UIColor.darkGray
            static let Tint = UIColor.systemGray3
            static let Selected = UIColor.systemGray5
            static let Background = UIColor.systemGray6
        }
        
    }
    
    enum Image {
        static let checkBoxSelected = UIImage(systemName: "checkmark.square.fill")?
            .renderingColor(.paletteColors([.white, .clear, K.Color.Primary.Orange]))
        
        static let checkBoxNormal = UIImage(systemName: "square")?
            .renderingColor(.monochrome)
            .font(.systemFont(ofSize: 17, weight: .bold))
    }
    
    enum Font {
        static let Header1: UIFont = .systemFont(ofSize: 20, weight: .heavy)
        static let Header2: UIFont = .systemFont(ofSize: 18, weight: .heavy)
        static let SubHeader: UIFont = .systemFont(ofSize: 16, weight: .bold)
        static let Body: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let CellHeader: UIFont = .systemFont(ofSize: 15, weight: .bold)
        static let CellBody: UIFont = .systemFont(ofSize: 14, weight: .bold)
    }
    enum Size {
        static let border_Thin: CGFloat = 1.0
        static let border_Medium: CGFloat = 1.5
        static let cellRadius :CGFloat = 16
    }
    
    
    
    
    enum API {
        
    }
}
