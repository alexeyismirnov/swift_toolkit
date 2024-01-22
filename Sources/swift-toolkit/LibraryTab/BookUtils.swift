//
//  BookUtils.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 7/20/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit

public class LabelViewController : UIViewController, PopupContentViewController {
    public var text : String!
    public var fontSize: Int!

    var con : [NSLayoutConstraint]!

    override public func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        
        label.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!
        label.backgroundColor = .clear
        label.textColor = .black
        label.isScrollEnabled = true
        label.isEditable = false
        label.showsVerticalScrollIndicator = true

        view.addSubview(label)
        
        con = [
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(con)
        
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            let screenSize = UIScreen.main.bounds
            
            if UIDevice.modelName.contains("Plus") {
                return CGSize(width: screenSize.width-50, height: 400)
            
            } else if UIDevice.modelName.contains("iPhone X") {
                return CGSize(width: screenSize.width-50, height: 450)
           
            } else {
                return CGSize(width: screenSize.width-50, height: 350)
            }
            
        } else {
            return CGSize(width: 500, height: 550)
        }
        
    }
}

public class FontSizeViewController : UIViewController, PopupContentViewController {
    let prefs = AppGroup.prefs!
    
    var text : String!
    var con : [NSLayoutConstraint]!
    
    override public func loadView() {
        let fontSize = prefs.integer(forKey: "fontSize")

        view = UIView()
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        let label = UILabel()
        label.text = Translate.s("Font size")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = .gray
        slider.minimumValue = 14
        slider.maximumValue = 32
        slider.setValue(Float(fontSize), animated: false)
        
        slider.addTarget(self, action: #selector(self.sliderVlaue(_:)), for: .valueChanged)
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(slider)
        view.addSubview(button)
        
        con = [
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 100.0),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),

        ]
        
        NSLayoutConstraint.activate(con)
    }
    
    @objc func sliderVlaue(_ sender: UISlider) {
        prefs.set(Int(sender.value), forKey: "fontSize")
        prefs.synchronize()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        UIViewController.popup.dismiss()
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 250, height: 170)
    }
}
