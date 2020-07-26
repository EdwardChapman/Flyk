//
//  TextColorPicker.swift
//  Flyk
//
//  Created by Edward Chapman on 7/24/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class ColorDisplayButton: UIView {
    override var backgroundColor: UIColor? {
        get{return super.backgroundColor}
        set(newColor){
            super.backgroundColor = newColor
            if newColor == nil {return}
            if let components = newColor!.cgColor.components {
                let sum = components.reduce(0, +)
                if components.count > 0 && sum/CGFloat(components.count) > 0.85 {
                    self.layer.borderColor = UIColor.black.cgColor
                }else{
                    self.layer.borderColor = UIColor.white.cgColor
                }
            }
        }
    }
}


class TextColorPicker: UIView {
    
    let backgroundColorButton: UIView = ColorDisplayButton()
    let textColorButton: UIView = ColorDisplayButton()
    
    let centerSpacing: CGFloat = 50
    let topSpacing: CGFloat = 12
    
    var activePicker: UIView? {
        didSet{
            if(activePicker == nil){
                for swatch in colorSwatches {
                    swatch.isHidden = true
                }
                backgroundColorButton.isHidden = false
                textColorButton.isHidden = false
            }else{
                backgroundColorButton.isHidden = true
                textColorButton.isHidden = true
                for swatch in colorSwatches {
                    swatch.isHidden = false
                }
            }
        }
    }
    
    lazy var colorSwatches: [UIView] = {
        var swatches: [UIView] = []
        let swatchUIColors = [
            UIColor.white,
            UIColor.black,
            UIColor.flykBlue,
            UIColor(red: 1, green: 105/255, blue: 180/255, alpha: 1),
            UIColor.red,
            UIColor.green,
            UIColor.purple,
            UIColor.yellow
        ]
        for swatchColor in swatchUIColors {
            let swatchView = UIView()
            swatchView.backgroundColor = swatchColor
            let index = CGFloat(swatchUIColors.firstIndex(of: swatchColor)!)
            swatchView.frame.size = CGSize(width: self.frame.height - topSpacing*2, height: self.frame.height - topSpacing*2)
            swatchView.center.x = index * (self.frame.width / CGFloat(swatchUIColors.count)+1) + swatchView.frame.width/2
            swatchView.center.y = self.frame.height/2
            swatchView.layer.cornerRadius = swatchView.frame.width/2
            swatchView.layer.borderWidth = 1
            swatchView.layer.borderColor = UIColor.white.cgColor
            

            self.addSubview(swatchView)
            swatches.append(swatchView)
            swatchView.isHidden = true
            swatchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleColorSwatchTap(tapGesture:))))
            if let components = swatchColor.cgColor.components {
                let sum = components.reduce(0, +)
                if components.count > 0 && sum/CGFloat(components.count) > 0.85 {
                    swatchView.layer.borderColor = UIColor.black.cgColor
                }else{
                    swatchView.layer.borderColor = UIColor.white.cgColor
                }
            }
        }
        
        return swatches
    }()
    
    @objc func handleColorSwatchTap(tapGesture: UITapGestureRecognizer){
        if let activePicker = self.activePicker {
            activePicker.backgroundColor = tapGesture.view?.backgroundColor
            activePicker.layer.borderColor = tapGesture.view?.layer.borderColor
            self.activePicker = nil
            if let textEditorView = self.superview as? TextEditor {
                if activePicker == backgroundColorButton {
                    textEditorView.textField?.backgroundColor = activePicker.backgroundColor
                } else if activePicker == textColorButton {
                    textEditorView.textField?.textColor = activePicker.backgroundColor
                }
            }
        }
    }
    
    
    init(){
        super.init(frame: .zero)
        
        
//        backgroundColorButton.frame.origin = CGPoint(x: 100, y: 800)
        backgroundColorButton.layer.borderWidth = 1
        backgroundColorButton.layer.borderColor = UIColor.white.cgColor
//        backgroundColorButton.frame.size = CGSize(width: 30, height: 30)
        backgroundColorButton.backgroundColor = .black
        backgroundColorButton.layer.cornerRadius = 4
        self.addSubview(backgroundColorButton)
        
        backgroundColorButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -topSpacing).isActive = true
        backgroundColorButton.topAnchor.constraint(equalTo: self.topAnchor, constant: topSpacing).isActive = true
        backgroundColorButton.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -centerSpacing).isActive = true
        backgroundColorButton.widthAnchor.constraint(equalTo: backgroundColorButton.heightAnchor).isActive = true
//        backgroundColorButton.heightAnchor.constraint(equalTo: backgroundColorButton.widthAnchor).isActive = true
        
        
        
//        textColorButton.frame.origin = CGPoint(x: 100, y: 800)
        textColorButton.layer.borderWidth = 1
        textColorButton.layer.borderColor = UIColor.white.cgColor
//        textColorButton.frame.size = CGSize(width: 30, height: 30)
        textColorButton.backgroundColor = .black
        textColorButton.layer.cornerRadius = 4
        self.addSubview(textColorButton)
        
        textColorButton.translatesAutoresizingMaskIntoConstraints = false
        textColorButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -topSpacing).isActive = true
        textColorButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: centerSpacing).isActive = true
        textColorButton.topAnchor.constraint(equalTo: self.topAnchor, constant: topSpacing).isActive = true
        textColorButton.widthAnchor.constraint(equalTo: textColorButton.heightAnchor).isActive = true
//        textColorButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        textColorButton.heightAnchor.constraint(equalTo: textColorButton.widthAnchor).isActive = true
        
        textColorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleColorPickerTap(tapGesture:))))
        backgroundColorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleColorPickerTap(tapGesture:))))
    }
    
    @objc func handleColorPickerTap(tapGesture: UITapGestureRecognizer){
        activePicker = tapGesture.view
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
