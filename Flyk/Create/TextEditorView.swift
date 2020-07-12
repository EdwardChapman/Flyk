//
//  TextEditorView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/11/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//
import UIKit
import Foundation

class TextEditor : UIView, UITextFieldDelegate{
    let view = TextEditor()
    
    var textField: UITextField?
    var textFieldTransform: CGAffineTransform?
    var textFieldSuperview: UIView?
    var textFieldFrame: CGRect?
    
    private init(){
        super.init(frame: CGRect())
        self.isHidden = true
        self.backgroundColor = .black
        self.alpha = 0.2
    }
    
    func beginEditing(textField: UITextField){
        self.textField = textField
        self.textFieldTransform = textField.transform
        self.textFieldSuperview = textField.superview
        self.textFieldFrame = textField.frame
        textField.layer.removeAllAnimations()
        textField.removeFromSuperview()
        self.view.addSubview(textField)
        
        textField.transform = CGAffineTransform.identity
        textField.center.x = self.view.center.x
        textField.center.y = 300
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
    }
    
    
    func finishEditing(){
        guard
            let textField = self.textField,
            let textFieldTransform = self.textFieldTransform,
            let textFieldSuperview = self.textFieldSuperview,
            let textFieldFrame = self.textFieldFrame else{
            print("guard failure at finishEditing()")
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            textField.removeFromSuperview()
            textField.transform = textFieldTransform
            textField.frame = textFieldFrame
            textFieldSuperview.addSubview(textField)
        })
        
        self.textField = nil
        self.textFieldFrame = nil
        self.textFieldSuperview = nil
        self.textFieldTransform = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
