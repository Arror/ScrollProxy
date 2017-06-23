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
    @IBOutlet weak var toTopButton: ToTopButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 44.0
        
        self.toTopButton.addTarget(self, action: #selector(ViewController.toTopButtonTapped(_:)), for: .touchUpInside)
        
        self.tableView.proxy.addResponder(self.toTopButton)
    }
    
    @objc private func toTopButtonTapped(_ sender: UIButton) {
        
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath)
        
        cell.textLabel?.text = "S: \(indexPath.section) - R: \(indexPath.row)"
        
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
}

extension UINavigationController {
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        
        return self.topViewController
    }
}

class ToTopButton: UIButton, OffsetChangedProtocol {
    
    func offsetChanged(of scrollView: UIScrollView) {
        
        self.isHidden = scrollView.contentOffset.y <= scrollView.bounds.height
    }
}
