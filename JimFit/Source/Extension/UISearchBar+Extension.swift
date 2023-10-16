//
//  UISearchBar+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/16.
//

import UIKit

extension UISearchBar {
    func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        self.resignFirstResponder()
    }
}
