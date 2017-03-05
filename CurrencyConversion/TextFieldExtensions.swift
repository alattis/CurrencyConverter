//
//  TextFieldExtensions.swift
//  CurrencyConversion
//
//  Created by andrew lattis on 3/5/17.
//  Copyright © 2017 andrew lattis. All rights reserved.
//

import UIKit

extension UITextField {
    override open func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            //only allow pasting if the value in the pasteboard looks like a number
            guard let value = UIPasteboard.general.string else { return nil }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            guard numberFormatter.number(from: value) != nil else { return nil }
        }
        return super.target(forAction: action, withSender: sender)
    }
}
