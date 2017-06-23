//
//  ViewController.swift
//  Sample
//
//  Created by Arror on 2017/6/23.
//  Copyright © 2017年 Arror. All rights reserved.
//

import UIKit
import ScrollProxy

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: TitleLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 44.0
        
        self.tableView.proxy.addResponder(self.titleLabel)
    }
    
    @objc private func toTopButtonTapped(_ sender: UIButton) {
        
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 20
    }
    
    let colors: [UIColor] = [.red, .blue, .green, .cyan]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath)
        
        cell.textLabel?.text = "S: \(indexPath.section) - R: \(indexPath.row)"
        
        cell.backgroundColor = self.colors[indexPath.row]
        
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
}

extension UINavigationController {
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        
        return self.topViewController
    }
}

class TitleLabel: UILabel, OffsetChangedProtocol {
    
    func offsetChanged(of scrollView: UIScrollView) {
        
        guard let tableView = scrollView as? UITableView else { return }
        
        let first = tableView.visibleCells.first
        
        self.text = first?.textLabel?.text
        
        self.backgroundColor = first?.backgroundColor
    }
}
