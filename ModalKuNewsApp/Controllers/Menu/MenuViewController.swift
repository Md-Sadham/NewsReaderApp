//
//  MenuViewController.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 17/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableMenu: UITableView!
    
    var arrCategoryName : [String] = ["Business","Entertainment","General","Health","Science","Sports","Technology"]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        tableMenu.tableFooterView = UIView(frame: .zero)
        tableMenu.reloadData()
    }
    
    // MARK: - Extra
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("menu touches")
    }
    
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            print("Swipe Left")
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.frame.origin.x = -GlobalConstants.ScreenSize.SCREEN_WIDTH
            }, completion:{
                (value: Bool) in
                self.callNotificationForMenuSelectedOrHidden(section: 1, selectedRow: 0, menuSwiped: true)
            })
        }
    }
    
    func callNotificationForMenuSelectedOrHidden(section: Int, selectedRow: Int, menuSwiped: Bool) {
        
        if menuSwiped {
            // Menu swipe. Need to remove child view
            var dataDict = Dictionary<String, Any>()
            dataDict["HideMenu"] = true // Just
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "MenuSelected"), object: nil, userInfo: dataDict)
            
            return
        }
        
        switch section {
        case 0:
            // remove child class. b4 that, send selected value to parent. Input: tab index, selected category
            var dataDict = Dictionary<String, Any>()
            dataDict["TabIndex"] = 0
            dataDict["SelectedCategory"] = arrCategoryName[selectedRow]
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "MenuSelected"), object: nil, userInfo: dataDict)
        case 1:
            var dataDict = Dictionary<String, Any>()
            dataDict["TabIndex"] = 1
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "MenuSelected"), object: nil, userInfo: dataDict)
        case 2:
            var dataDict = Dictionary<String, Any>()
            dataDict["TabIndex"] = 2
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "MenuSelected"), object: nil, userInfo: dataDict)
        default:
            return
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: Table view delegates
    public func numberOfSections(in tableView: UITableView) -> Int{
        return 3
    }// Default is 1 if not implemented
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        switch section {
        case 0:
            return arrCategoryName.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Top Headlines"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 45
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cellId: NSString = "tblCellID"
        let cell: MenuScreenCell = tableView.dequeueReusableCell(withIdentifier: cellId as String)! as! MenuScreenCell
        
        switch indexPath.section {
        case 0:
            cell.lblMenuOptionText.text = arrCategoryName[indexPath.row]
            cell.imgMenuOptionIcon.isHidden = false
            cell.imgMenuOptionIcon.image = UIImage.init(named: arrCategoryName[indexPath.row])
          
        case 1:
            cell.lblMenuOptionText.text = "Everything"
            cell.lblMenuOptionText.font = UIFont.boldSystemFont(ofSize: 16.0)
            cell.lblMenuOptionText.textColor = UIColor.black
            
            if #available(iOS 11.0, *) {
                cell.lblMenuOptionText.leadingAnchor.constraintEqualToSystemSpacingAfter(cell.imgMenuOptionIcon.leadingAnchor, multiplier: 0.0).isActive = true
            } else {
                // Fallback on earlier versions
                let changeLeading = NSLayoutConstraint(item: cell.lblMenuOptionText, attribute: .leading, relatedBy: .equal, toItem: cell.imgMenuOptionIcon, attribute: .leading, multiplier: 1.0, constant: 0)
                
                NSLayoutConstraint.activate([changeLeading])
            }
            
            cell.imgMenuOptionIcon.isHidden = true
            cell.backgroundColor = UIColor.init(red: 231.0/255.0, green: 231.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        case 2:
            cell.lblMenuOptionText.text = "BookMark"
            cell.lblMenuOptionText.font = UIFont.boldSystemFont(ofSize: 16.0)
            cell.lblMenuOptionText.textColor = UIColor.black
            
            if #available(iOS 11.0, *) {
                cell.lblMenuOptionText.leadingAnchor.constraintEqualToSystemSpacingAfter(cell.imgMenuOptionIcon.leadingAnchor, multiplier: 0.0).isActive = true
            } else {
                // Fallback on earlier versions
                let changeLeading = NSLayoutConstraint(item: cell.lblMenuOptionText, attribute: .leading, relatedBy: .equal, toItem: cell.imgMenuOptionIcon, attribute: .leading, multiplier: 1.0, constant: 0)
                
                NSLayoutConstraint.activate([changeLeading])
            }
            
            cell.imgMenuOptionIcon.isHidden = true
            cell.backgroundColor = UIColor.init(red: 231.0/255.0, green: 231.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callNotificationForMenuSelectedOrHidden(section: indexPath.section, selectedRow: indexPath.row, menuSwiped: false)
        
        tableView .deselectRow(at: indexPath, animated: true)
    }
}
