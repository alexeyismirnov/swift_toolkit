//
//  FastingLegendTableView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public class FastingLegendTableView: UITableViewController, PopupContentViewController {
    let fastingTypes : [FastingModel] = (FastingModel.fastingLevel == .monastic) ? FastingModel.monasticTypes : FastingModel.laymenTypes
    let toolkit = Bundle.module

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(close))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fastingTypes.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCell = tableView.dequeueReusableCell()
        let fasting = fastingTypes[indexPath.row]
        
        cell.title.text = fasting.descr
        cell.title.textColor = .black
        cell.icon.backgroundColor = fasting.color
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 300, height: 350)
    }

}
