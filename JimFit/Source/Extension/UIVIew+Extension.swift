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
    
    /// 여러 이미지를 darken blend 모드로 합성하여 하나의 이미지로 반환합니다.
    ///
    /// - Parameters:
    ///   - images: 합성할 이미지 배열
    ///   - alpha: 각 이미지의 투명도 배열 (기본값: 1.0)
    /// - Returns: 합성된 이미지
    func blendImagesWithDarken(images: [UIImage], alpha: [CGFloat]) -> UIImage? {
        guard let firstImage = images.first else { return nil }
        
        let imageSize = firstImage.size
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let result = renderer.image { ctx in
            // 배경을 흰색으로 채워서 투명한 색상이 더 밝게 보이도록 합니다.
            UIColor.clear.set()
            ctx.fill(rect)
            
            for (index, image) in images.enumerated() {
                let currentAlpha = alpha.indices.contains(index) ? alpha[index] : 1.0
                image.draw(in: rect, blendMode: .darken, alpha: currentAlpha)
            }
        }
        return result
    }
}
