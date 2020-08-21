//
//  MultiLineTextWrapTest.swift
//  Flyk
//
//  Created by Edward Chapman on 8/19/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class customTextLayer : CATextLayer {
    override func draw(in ctx: CGContext) {
        
    }
}

class CustomLayoutManager : NSLayoutManager {
    
    override func drawUnderline(forGlyphRange glyphRange: NSRange,
                                underlineType underlineVal: NSUnderlineStyle,
                                baselineOffset: CGFloat,
                                lineFragmentRect lineRect: CGRect,
                                lineFragmentGlyphRange lineGlyphRange: NSRange,
                                containerOrigin: CGPoint
        ) {
        
        let firstPosition  = location(forGlyphAt: glyphRange.location).x
        
        let lastPosition: CGFloat
        
        if NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange) {
            lastPosition = location(forGlyphAt: NSMaxRange(glyphRange)).x
        } else {
            lastPosition = lineFragmentUsedRect(
                forGlyphAt: NSMaxRange(glyphRange) - 1,
                effectiveRange: nil).size.width
        }
        
        var lineRect = lineRect
        let height = lineRect.size.height * 3.5 / 4.0 // replace your under line height
        lineRect.origin.x += firstPosition
        lineRect.size.width = lastPosition - firstPosition
        lineRect.size.height = height
        
        lineRect.origin.x += containerOrigin.x
        lineRect.origin.y += containerOrigin.y
        
        lineRect = lineRect.integral.insetBy(dx: 0.5, dy: 0.5)
        
        //        let path = UIBezierPath(rect: lineRect)
        let path = UIBezierPath(roundedRect: lineRect, cornerRadius: 4)
        // set your cornerRadius
        path.fill()
    }
    
    
    func thisIsTryingToUseAbove(){
        let layout = CustomLayoutManager()
        let storage = NSTextStorage()
        storage.addLayoutManager(layout)
        let initialSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: initialSize)
        container.widthTracksTextView = true
        layout.addTextContainer(container)
        let testTextView = UITextView(frame: .zero, textContainer: container)
        
//        self.view.addSubview(testTextView)
        testTextView.text = "This is a test\nThis is a new line"
        testTextView.frame = CGRect(origin: CGPoint(x: 100, y: 200), size: CGSize(width: 200, height: 200))
        
        
        
        //        let labelTest = UILabel()
        //        labelTest.numberOfLines = 5
        //        labelTest.text = "This is a test\nThis is a new line"
        //        labelTest.textColor = .white
        //        self.view.addSubview(labelTest)
        //        labelTest.frame.origin = CGPoint(x: 100, y: 200)
        //
        //        labelTest.frame.size = labelTest.intrinsicContentSize
        ////        labelTest.backgroundColor = .red
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        
        //        let richText = try NSMutableAttributedString(
        //            data: assetDetails!.cardDescription.data(using: String.Encoding.utf8)!,
        //            options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType],
        //            documentAttributes: nil)
        //        richText.addAttributes([ NSParagraphStyleAttributeName: style ],
        //                               range: NSMakeRange(0, richText.length))
        //        // In Swift 4, use `.paragraphStyle` instead of `NSParagraphStyleAttributeName`.
        //        assetDescription.attributedText = richText
        //        richText.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, richText.length))
        
        //        addAttributes(
        //            [
        //                .foregroundColor: UIColor.white,
        //                .underlineStyle: NSUnderlineStyle.single.rawValue,
        //                .underlineColor: UIColor(red: 51 / 255.0, green: 154 / 255.0, blue: 1.0, alpha: 1.0)
        //            ],
        //            range: range
        //        )
        
        let attrs = [
            //            NSAttributedString.Key.backgroundColor : UIColor.red,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            , NSAttributedString.Key.underlineColor: UIColor.red
            //            .paragraphStyle : style
            ,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)
            ] as [NSAttributedString.Key : Any]
        
        testTextView.attributedText = NSAttributedString(string: "This is a test\nhi", attributes: attrs)
        //        labelTest.attributedText?
        //        labelTest.attributedText.addAttribute(NSBackgroundColorAttributeName, value: .red, range: NSMakeRange(0, tillLocation))
        //        labelTest.frame.size = CGSize(width: 90, height: 90)
//        let ca = CATextLayer()
        
        
        
        
        
        
    }
}
