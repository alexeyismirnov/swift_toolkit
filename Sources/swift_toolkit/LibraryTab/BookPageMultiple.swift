//
//  BookPage2.swift
//  ponomar
//
//  Created by Alexey Smirnov on 6/29/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit

protocol BookPageDelegate {
    func hideBars() -> (CGRect, UIEdgeInsets)
    func showBars() -> (CGRect, UIEdgeInsets)
    func showComment(_ popup: UIViewController)
}

public class BookPageMultiple: UIViewController, BookPageDelegate {
    let prefs = AppGroup.prefs!

    var lang: String
    var collectionView: UICollectionView!
    var isScrolling: Bool!

    var model : BookModel
    var bookPos = [BookPosition]()
    var initialPos : IndexPath!
    var toolbarLabel: UILabel!

    var bookmark: String?
    
    var button_fontsize, button_add_bookmark, button_remove_bookmark : CustomBarButton!
    var button_close : CustomBarButton!
    
    var totalCells : Int!
    var buttonLeft, buttonRight : UIBarButtonItem!

    public init?(_ pos: BookPosition, lang: String = Translate.language) {
        guard let model = pos.model else { return nil }
        
        self.lang = lang
        self.model = model
        
        totalCells = 0
        
        var curPos : BookPosition!
                
        if let _ = model as? BibleModel {
            curPos = BookPosition(model: model, index: pos.index!, chapter: 0)
        } else {
            curPos = BookPosition(model: model, index: IndexPath(row: 0, section: 0))
        }
                
        repeat {
            bookPos.append(curPos)
            
            if (curPos == pos) {
                initialPos =  IndexPath(row: totalCells, section: 0)
            }
            
            totalCells += 1
            curPos = model.getNextSection(at: curPos)
            
        } while (curPos != nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.isHidden = true
        
        reloadTheme()
        createCollectionView()

        createNavigationButtons()
        updateNavigationButtons(pos: bookPos[initialPos.row])
        
        createToolbar()
        updateToolbar(pos: bookPos[initialPos.row], index: initialPos)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: initialPos, at: .left, animated: false)

        navigationController?.toolbar.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - 70.0),
                                                     size: CGSize(width: view.frame.width, height: 70.0))
        
        
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func createCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = view.frame.size
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        isScrolling = false

        view.addSubview(collectionView)
    }
        
    func createToolbar() {
        let toolkit = Bundle.module
        var items = [UIBarButtonItem]()

        toolbarLabel = UILabel(frame: .zero)
        toolbarLabel.textAlignment = .center
        toolbarLabel.numberOfLines = 2
        toolbarLabel.textColor = Theme.textColor
        
        toolbarLabel.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(22))

        toolbarLabel.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width-120, height: 60)
        
        let customBarButton = UIBarButtonItem(customView: toolbarLabel)
        
        buttonLeft = UIBarButtonItem(image: UIImage(named: "arrow-left", in: toolkit),
                                     style: .plain,
                                     target: self,
                                     action: #selector(self.showPrev))
        
        buttonRight = UIBarButtonItem(image: UIImage(named: "arrow-right", in: toolkit),
                                      style: .plain,
                                      target: self,
                                      action: #selector(self.showNext))
        
        items.append(buttonLeft)
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        items.append(customBarButton)
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        
        items.append(buttonRight)
        
        self.toolbarItems = items
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func updateToolbar(pos: BookPosition, index: IndexPath) {
        toolbarLabel.text = model.getTitle(at: pos)
        
        buttonLeft.isHidden = (index.row == 0)
        buttonRight.isHidden = (index.row == totalCells - 1)
    }
    
    func createNavigationButtons() {
        let toolkit = Bundle.module
        
        button_close = CustomBarButton(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        
        button_fontsize = CustomBarButton(image: UIImage(named: "fontsize", in: toolkit)!
            , target: self, btnHandler: #selector(showFontSizeDialog))
        
        button_add_bookmark = CustomBarButton(image: UIImage(named: "add_bookmark", in: toolkit)!
            , target: self, btnHandler: #selector(addBookmark))
        
        button_remove_bookmark = CustomBarButton(image: UIImage(named: "remove_bookmark", in: toolkit)!
            , target: self, btnHandler: #selector(removeBookmark))
    }
    
    func updateNavigationButtons(pos: BookPosition) {
        var right_nav_buttons = [CustomBarButton]()
        
        bookmark = model.getBookmark(at: pos)

        if let bookmark = bookmark {
            let bookmarks = prefs.stringArray(forKey: "bookmarks")!
            right_nav_buttons.append(bookmarks.contains(bookmark) ? button_remove_bookmark : button_add_bookmark)
        }
        
        right_nav_buttons.insert(button_fontsize, at: 0)
        
        navigationItem.rightBarButtonItems = right_nav_buttons
        navigationItem.leftBarButtonItems = [button_close]
    }
    
    @objc func close() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadTheme() {
        let toolkit = Bundle.module
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
    }
    
    @objc func showNext() {
        if (isScrolling) { return }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView.indexPathForItem(at: visiblePoint)!
        
        if (index.row < totalCells-1) {
            isScrolling = true
            collectionView.scrollToItem(at: IndexPath(item: index.row+1, section: 0), at: .left, animated: true)
        }
    }
    
    @objc func showPrev() {
        if (isScrolling) { return }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView.indexPathForItem(at: visiblePoint)!
        
        if (index.row > 0) {
            isScrolling = true
            collectionView.scrollToItem(at: IndexPath(item: index.row-1, section: 0), at: .left, animated: true)
        }
    }
    
    @objc func showFontSizeDialog() {
        showPopup(FontSizeViewController(), onClose: { _ in self.collectionView.reloadData() })
    }
    
    @objc func addBookmark() {
        guard let bookmark = bookmark else { return }
        
        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.append(bookmark)
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_remove_bookmark]
    }
    
    @objc func removeBookmark() {
        guard let bookmark = bookmark else { return }

        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.removeAll(where: { $0 == bookmark })
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_add_bookmark]
    }
    
    func hideBars() -> (CGRect, UIEdgeInsets) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        return (getFullScreenFrame(),
                UIEdgeInsets(top: navigationController?.navigationBar.frame.height ?? 0, left: 0, bottom: 0, right: 0))
    }
    
    func showBars() -> (CGRect, UIEdgeInsets) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        return (getFullScreenFrame(),
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }

    func showComment(_ popup: UIViewController) {
        showPopup(popup)
    }
}

extension  BookPageMultiple: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCells
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if model.contentType == .html {
            let cell: BookPageCellHTML = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = model.getContent(at: bookPos[indexPath.row]) as? String
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            cell.model = model
            
            return cell
            
        } else {
            let cell: BookPageCellText = collectionView.dequeueReusableCell(for: indexPath)
            
            cell.font = UIFont.lang(lang)
            cell.attributedText = model.getContent(at: bookPos[indexPath.row]) as? NSAttributedString
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            
            return cell
        }
            
    }
    
    func adjustView(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView.indexPathForItem(at: visiblePoint)!
        
        let newPos = bookPos[index.row]

        updateNavigationButtons(pos: newPos)
        updateToolbar(pos: newPos, index: index)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        adjustView(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustView(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            adjustView(scrollView)
        }
    }
    
}

