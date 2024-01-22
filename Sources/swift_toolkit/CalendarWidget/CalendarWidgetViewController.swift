//
//  MainViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/31/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import NotificationCenter

open class CalendarWidgetViewController : UINavigationController, NCWidgetProviding {
    static let tk = Bundle.module
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        Translate.language = AppGroup.prefs.object(forKey: "language") as! String
        FastingModel.fastingLevel = FastingLevel(rawValue: AppGroup.prefs.integer(forKey: "fastingLevel"))

        isNavigationBarHidden = true

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    public func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        var viewController : UIViewController!
        
        popViewController(animated: false)
        
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = maxSize
            viewController = UIViewController.named("Compact", bundle: CalendarWidgetViewController.tk)
            
        } else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            self.preferredContentSize = CGSize(width: 0.0, height: 350)
            viewController = UIViewController.named("Expanded", bundle: CalendarWidgetViewController.tk)
        }

        pushViewController(viewController, animated: false)
    }

    public func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    static func describe(saints: [Saint], font: UIFont!, dark: Bool) -> NSAttributedString {
        let myString = NSMutableAttributedString(string: "")
        
        if saints[0].type != .none  {
            let attachment = NSTextAttachment()
            attachment.image = saints[0].type.icon15x15
            attachment.bounds = CGRect(x: 0.0, y: font.descender/2, width: attachment.image!.size.width, height: attachment.image!.size.height)
            
            myString.append(NSAttributedString(attachment: attachment))
        }
        
        var textColor:UIColor = dark ? .white : .black
        if (saints[0].type == .great) { textColor = .red }

        myString.append(NSMutableAttributedString(string: saints[0].name,
                                                  attributes: [
                                                    .foregroundColor: textColor,
                                                    .font: font! ]))
        
        return myString
    }
    
}
