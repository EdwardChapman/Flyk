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
//    static var view:TextEditor?
    
    var textField: UITextField?
    var textFieldTransform: CGAffineTransform?
    var textFieldSuperview: UIView?
    var textFieldFrame: CGRect?
    var textFieldCenter : CGPoint?
    
    var colorPickerBottomAnchor: NSLayoutConstraint?
    
    lazy var colorPickerView: TextColorPicker = {
        let colorPickerView = TextColorPicker()
        self.addSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerBottomAnchor = colorPickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        colorPickerBottomAnchor!.isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        colorPickerView.heightAnchor.constraint(equalToConstant: 59).isActive = true
        return colorPickerView
    }()
    
//    let backgroundColorButton = UIView()
//    let textColorButton = UIView()
    
    var keyboardHeight: CGFloat? {
        didSet{
            colorPickerBottomAnchor?.constant = -(keyboardHeight ?? 300)
//            backgroundColorButton.frame.origin = CGPoint(
//                x: 100,
//                y: self.frame.height - (keyboardHeight ?? 300) - backgroundColorButton.frame.height - 10
//            )
        }
    }
    
    
    
    override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set(shouldHide) {
            super.isHidden = shouldHide
            if shouldHide {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                }, completion: { finished in
                    self.alpha = 0
                })
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                }, completion: { finished in
                    self.alpha = 1
                })
            }
        }
    }
    
    init(){
        super.init(frame: CGRect())
        self.isHidden = true
        self.alpha = 0
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDismissTap(tapGesture:))))
        

    }
    
    @objc func handleDismissTap(tapGesture: UITapGestureRecognizer) {
        finishEditing()
    }
    
    func beginEditing(textField: UITextField){
        finishEditing()
        addKeyboardObserver()
        self.isHidden = false
        self.textField = textField
        textField.delegate = self
        self.textFieldTransform = textField.transform
        self.textFieldSuperview = textField.superview
        self.textFieldFrame = textField.frame
        self.textFieldCenter = textField.center
        self.colorPickerView.backgroundColorButton.backgroundColor = textField.backgroundColor
        self.colorPickerView.textColorButton.backgroundColor = textField.textColor
//        self.textColorButton.backgroundColor = textField.textColor
        //        self.backgroundColorButton.backgroundColor = textField.backgroundColor
        
        textField.keyboardAppearance = .dark
        
        
        textField.removeFromSuperview()
        self.addSubview(textField)
        
        textField.transform = CGAffineTransform.identity
        textField.center.x = self.center.x
        textField.center.y = 300
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
    }
    
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardRectValue.height
            self.keyboardHeight = keyboardHeight
        }
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    func removeKeyboardObserver(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    func finishEditing(){
        guard
            let textField = self.textField,
            let textFieldTransform = self.textFieldTransform,
            let textFieldSuperview = self.textFieldSuperview,
            let textFieldFrame = self.textFieldFrame,
            let textFieldCenter = self.textFieldCenter else{
            print("guard failure at finishEditing()")
            return
        }
        colorPickerView.activePicker = nil
        textField.removeFromSuperview()
        textField.delegate = nil
        self.isHidden = true
        
        if textField.text?.count != 0 {
            UIView.animate(withDuration: 0.2, animations: {
                textField.transform = textFieldTransform
                textField.center = textFieldCenter
                textFieldSuperview.addSubview(textField)
                textField.isUserInteractionEnabled = false
            }, completion: { finished in
                
            })
        }
        
        self.textField = nil
        self.textFieldFrame = nil
        self.textFieldSuperview = nil
        self.textFieldTransform = nil
        self.textFieldCenter = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // TextFieldDelegate Methods Below
    ////////////////////////////////////////////////////////////////////////////////////////////////
    

    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        textField.isUserInteractionEnabled = true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason){
//        textField.isUserInteractionEnabled = false
        finishEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        textField.text = updatedString
        var newSize = textField.attributedText!.size()
        
        if updatedString?.count == 0 {
            newSize.width = 2
            newSize.height = textField.frame.height
        }
        textField.frame.size = newSize
        textField.center.x = self.center.x
//        textField.frame = CGRect(origin: textField.frame.origin, size: newSize)
        return false
    }
    
    
}
