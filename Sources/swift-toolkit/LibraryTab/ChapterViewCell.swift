//
//  ChapterViewCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/8/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let chapterSelectedNotification = Notification.Name("CHAPTER_SELECTED")
}

public class ChapterViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    public var collectionView: UICollectionView!
    public var numChapters: Int!
    public var index : IndexPath!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        clipsToBounds = true
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: 50, height: 50)
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        contentView.addSubview(collectionView)
        contentView.fullScreen(view: collectionView)
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(chapterSelected(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
    }
    
    
    @objc func chapterSelected(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        
        if  let path = collectionView.indexPathForItem(at: loc) {
            let userInfo = ["index": index!, "chapter": path.row] as [String : Any]
            NotificationCenter.default.post(name: .chapterSelectedNotification, object: nil, userInfo: userInfo as [AnyHashable : Any])
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numChapters
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LabelViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.title.text = "\(indexPath.row+1)"
        
        return cell
    }
}

extension ChapterViewCell: ReusableView {}
