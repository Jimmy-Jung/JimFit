//
//  ViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/25.
//

import UIKit
import JimmyKit
import SnapKit

class ViewController: UIViewController {
    let calendar = UIView()
        .backgroundColor(.systemYellow)
    
    let floatingView = UIView()
        .backgroundColor(.blue)
        .cornerRadius(30)
    
    let handler = UIView()
        .backgroundColor(.gray)
    
    var viewHeight: Constraint!
    var calendartHeight: Constraint!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(calendar)
        view.addSubview(floatingView)
        floatingView.addSubview(handler)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        handler.addGestureRecognizer(panGesture)
        
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(500)
        }
        
        floatingView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            viewHeight = make.top.equalTo(calendar.snp.bottom).constraint
//            viewHeight = make.height.equalTo(view.frame.height/2).constraint
        }
        
        handler.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let superview = floatingView.superview else { return }
        let translation = gesture.translation(in: superview)
        
        let newOriginY = floatingView.frame.origin.y + translation.y
        
//        floatingView.frame.origin.y = newOriginY
        self.viewHeight.update(offset: translation.y)
        if gesture.state == .ended {
            let yPosition = gesture.location(in: superview).y
            let viewHeight = view.frame.height
            if yPosition > viewHeight * 0.65 {
                UIView.animate(withDuration: 0.3) {
//                    self.viewHeight.update(offset: self.view.frame.height * 0.5)
                    self.calendar.snp.updateConstraints { make in
                        make.height.equalTo(500)
                    }
                    self.floatingView.snp.remakeConstraints { make in
                        make.bottom.horizontalEdges.equalToSuperview()
                        make.top.equalTo(self.calendar.snp.bottom)
                    }
                    self.floatingView.frame.origin.y = self.view.safeAreaLayoutGuide.layoutFrame.minY + 500
                    self.view.layoutIfNeeded()
                }
                
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.calendar.snp.updateConstraints { make in
                        make.height.equalTo(150)
                    }
                    self.floatingView.snp.remakeConstraints { make in
                        make.bottom.horizontalEdges.equalToSuperview()
                        make.top.equalTo(self.calendar.snp.bottom)
                    }
//                    self.calendartHeight.update(inset: 200)
//                    self.viewHeight.update(offset: self.view.frame.height * 0.7)
                    self.floatingView.frame.origin.y = self.view.safeAreaLayoutGuide.layoutFrame.minY + 150
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        gesture.setTranslation(.zero, in: superview)
    }
    
//    func swipeGesture() {
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
//        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
//        handler.addGestureRecognizer(swipeUp)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
//        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
//        handler.addGestureRecognizer(swipeDown)
//    }
    
    //    @objc func swipe(_ gesture: UIGestureRecognizer) {
    //        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
    //            return
    //        }
    //        switch swipeGesture.direction {
    //        case .up :
    //            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
    //                self.viewHeight.update(offset: self.view.frame.height*2/3)
    //                self.view.layoutIfNeeded()
    //            }
    //
    //        case .down:
    //            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
    //                self.viewHeight.update(offset: self.view.frame.height/2)
    //                self.view.layoutIfNeeded()
    //            }
    //
    //        default: break
    //        }
    //    }

}

