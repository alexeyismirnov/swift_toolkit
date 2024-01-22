//
//  ServiceDateSelector.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/16/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let dateSelectedNotification = Notification.Name("DATE_SELECTED")
}

public class ServiceDateSelector: UIViewController, ResizableTableViewCells, PopupContentViewController {
    public var tableView: UITableView!
    var model : ServiceModel
    var iterator: AnyIterator<Date>
    
    var dates = [Date]()
    var formatter = DateFormatter()
    
    public init?(_ model: ServiceModel) {
        self.model = model
        self.iterator = model.dateIterator(startDate: DateComponents(date: Date()).toDate())
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        formatter.locale = Translate.locale
        
        createTableView(style: .grouped, isPopup: true)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        dates.append(contentsOf: iterator.prefix(5))

    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let userInfo:[String: Date] = ["date": dates[indexPath.row]]
        NotificationCenter.default.post(name: .dateSelectedNotification, object: nil, userInfo: userInfo)
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("Service date")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descr = formatter.string(from: dates[indexPath.row]).capitalizingFirstLetter()
        let cell = getTextDetailsCell(title: descr, subtitle: "")
        cell.title.textAlignment = .center
        cell.title.textColor = .black
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath), minHeight: CGFloat(40))
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dates.count-1 {
            dates.append(contentsOf: iterator.prefix(5))
            tableView.reloadData()
        }
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 250, height: 200)
    }
}

