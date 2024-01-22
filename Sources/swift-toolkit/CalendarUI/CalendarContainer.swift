//
//  CalendarContainer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/20/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

public class CalendarNavigation: UINavigationController, PopupContentViewController {
    public var leftButton: UIBarButtonItem?
    public var rightButton: UIBarButtonItem?
    public var initialDate: Date!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.backgroundColor = UIColor(hex: "#FFEBCD")
        navigationBar.barTintColor = UIColor(hex: "#FFEBCD")
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let calendar = topViewController as! CalendarContainer
        calendar.initialDate = initialDate
        
        if let leftButton = leftButton {
            let spacer_l = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            spacer_l.width = 10
            
            calendar.navigationItem.leftBarButtonItems = [spacer_l, leftButton]
        }
        
        if let rightButton = rightButton {
            let spacer_r = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            spacer_r.width = 10
            
            calendar.navigationItem.rightBarButtonItems = [spacer_r, rightButton]
        }
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            return CGSize(width: 300, height: 350)

        } else {
            return CGSize(width: 500, height: 530)
        }
    }
}

public class CalendarContainer: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dates = [Date]()
    var initialDate: Date!
        
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#FFEBCD")
        collectionView.backgroundColor = UIColor.clear
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            resizeCalendar(300, 300)
            
        } else {
            collectionView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            resizeCalendar(500, 500)
        }
        
        view.setNeedsLayout()
        
        setTitle(fromDate: initialDate)
        dates = [initialDate-1.months, initialDate, initialDate+1.months]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            layout.itemSize = CGSize(width: 300, height: 300)
        } else {
            layout.itemSize = CGSize(width: 500, height: 500)
        }
        
        CalendarContainer.generateLabels(view)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
    }
    
    func setTitle(fromDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Translate.locale

        title = formatter.string(from: date).capitalizingFirstLetter()
    }
    
    func resizeCalendar(_ width: Int, _ height: Int) {
        collectionView.constraints.forEach { con in
            if con.identifier == "calendar-width" {
                con.constant = CGFloat(width)
                
            } else if con.identifier == "calendar-height" {
                con.constant = CGFloat(height)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MonthViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        cell.delegate = CalendarDelegate(selectedDate: initialDate)
        cell.currentDate = dates[indexPath.row]
        
        return cell
    }

    func adjustView(_ scrollView: UIScrollView) {
        let contentOffsetWhenFullyScrolledRight = collectionView.frame.size.width * CGFloat(dates.count - 1)
        var current = dates[1]
        
        if scrollView.contentOffset.x == 0 {
            current = dates[0]
        } else if scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight {
            current = dates[2]
        }
        
        setTitle(fromDate: current)
        
        collectionView.performBatchUpdates({
            self.dates[0] = current-1.months
            self.dates[1] = current
            self.dates[2] = current+1.months
            
        }, completion: { _ in
            UIView.setAnimationsEnabled(false)
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
            UIView.setAnimationsEnabled(true)
        })
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustView(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            adjustView(scrollView)
        }
    }
    
    public static func generateLabels(_ view: UIView, standalone : Bool = false, textColor : UIColor? = nil, fontSize : CGFloat? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Translate.locale
        
        var cal = Calendar.current
        cal.locale = Translate.locale
        
        var dayLabel = [String]()
        
        if standalone {
            dayLabel = formatter.veryShortStandaloneWeekdaySymbols!
            
        } else {
            dayLabel = formatter.veryShortWeekdaySymbols!
        }
        
        for index in cal.firstWeekday...7 {
            if let label = view.viewWithTag(index-cal.firstWeekday+1) as? UILabel {
                label.text = dayLabel[index-1]
            }
        }
        
        if cal.firstWeekday > 1 {
            for index in 1...cal.firstWeekday-1 {
                if let label = view.viewWithTag(8-cal.firstWeekday+index) as? UILabel {
                    label.text = dayLabel[index-1]
                }
            }
        }
        
        if let color = textColor {
            for index in 1...7 {
                if let label = view.viewWithTag(index) as? UILabel {
                    label.textColor =  color
                }
            }
        }

        if let size = fontSize {
            for index in 1...7 {
                if let label = view.viewWithTag(index) as? UILabel {
                    label.font = UIFont.systemFont(ofSize: size)
                }
            }
        }

    }

}
