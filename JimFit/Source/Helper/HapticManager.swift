//
//  HapticManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/16.
//

import UIKit

/// 햅틱 매니저
final class HapticsManager {
    /// 싱글톤
    static let shared = HapticsManager()
    
    private init() {}
    
    // MARK: - Public
    
    /// 선택시 얇은 진동 피드백
    func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    /// 알림 진동 피드백
    func vibrateForNotification(style: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(style)
    }
    /// 사용자와 상호작용할때 사용 (버튼 탭 등)
    func vibrateForInteraction(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
