//
//  CalendarView.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/17/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let dateChangedNotification = Notification.Name("DATE_CHANGED")
}

class MonthViewCell: UICollectionViewCell {
    var collectionView: UICollectionView!
    
    var delegate : CalendarDelegate! {
        didSet {
            collectionView.dataSource = delegate
            collectionView.delegate = delegate
        }
    }
    
    var currentDate: Date! {
        didSet {
            delegate.currentDate = currentDate
            collectionView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        let initialFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: initialFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear

        let recognizer = UITapGestureRecognizer(target: self, action:#selector(doneWithDate(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        contentView.addSubview(collectionView)
    }
    
    @objc func doneWithDate(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        
        if  let path = collectionView.indexPathForItem(at: loc),
            let cell = collectionView.cellForItem(at: path) as? DayViewCell,
            let curDate = cell.currentDate {
                let userInfo:[String: Date] = ["date": curDate]
                NotificationCenter.default.post(name: .dateChangedNotification, object: nil, userInfo: userInfo)
        }
    }
    
}

extension MonthViewCell: ReusableView {}
