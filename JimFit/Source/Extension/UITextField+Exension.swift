//
//  UITextField+Exension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/08.
//

import UIKit

extension UITextField {
    func addDoneButtonToKeyboard() -> Self {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputAccessoryView = toolbar
        return self
    }
    
    @objc func doneButtonTapped() {
        self.resignFirstResponder()
    }
}
