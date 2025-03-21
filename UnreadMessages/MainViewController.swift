//
//  MainViewController.swift
//
//  Copyright © 2023 Zendesk. All rights reserved.
//

import UIKit
import ZendeskSDK
import ZendeskSDKMessaging
import UserNotifications

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var navBarInfo: UIBarButtonItem!
    @IBOutlet var demoAppView: UIView!
    @IBOutlet weak var tableView: UITableView!
    static let initializeCardCell = "InitializeCardCell"
    static let showConversationCardCell = "ShowConversationCardCell"
    static let unreadMessageCardCell = "ShowUnreadCountCell"
    var unreadCount: Int = 0
    var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styling()
        tableView.register(UINib(nibName: "InitializeSDKCardCell", bundle: nil), forCellReuseIdentifier: MainViewController.initializeCardCell)
        tableView.register(UINib(nibName: "ShowConversationCardCell", bundle: nil), forCellReuseIdentifier: MainViewController.showConversationCardCell)
        tableView.register(UINib(nibName: "ShowUnreadCountCell", bundle: nil), forCellReuseIdentifier: MainViewController.unreadMessageCardCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
            if let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            
            gradientLayer.removeFromSuperlayer()
            backgroundView.backgroundColor = UIColor(named: "backgroundColor")
            
        }
        
        if traitCollection.userInterfaceStyle == .light {
            insertGradientLayer(gradientLayer, backgroundView: backgroundView)
        }
    }
    
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        makeAlert(title: "About this app", message: "This demo app is to help developers get up and running with the Zendesk SDK by providing a quick working example of the software, and providing some useful quick action buttons explore the end user experience.")
    }
    
    
    func styling() {
        let infoButtonColor = UIColor(named: "navTitleColor")
        navBarInfo.tintColor = infoButtonColor
        
        if traitCollection.userInterfaceStyle == .light {
            insertGradientLayer(gradientLayer, backgroundView: backgroundView)
        } else {
            backgroundView.backgroundColor = UIColor(named: "backgroundColor")
        }
    }
    
    func addCountObserver() {
        Zendesk.instance?.addEventObserver(self) { event in
            switch event {
            case .unreadMessageCountChanged(let count):
                print("Unread count:")
                print(count)
                self.unreadCount = count
                UIApplication.shared.applicationIconBadgeNumber = count
            case .authenticationFailed(let error as NSError):
                print(error.localizedDescription)
            @unknown default:
                break
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = [indexPath.row, indexPath.section]
        
        if index == [0,0] {
            return initCell(indexPath: indexPath)
        }
        if index == [0,1] {
            return presentCell(indexPath: indexPath)
        }
        if index == [0,2] {
            return unreadCell(indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.isOpaque = false
        view.frame.size.height = 16
        
        return view
    }
    
}

extension MainViewController {
    func initCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.initializeCardCell, for: indexPath) as? InitializeSDKCardCell else {
            // If table view fails to dequeue the cell we want (InitializeSDKCardCell) then show a dumb table view cell
            return UITableViewCell()
        }
#warning("provide channel key")
        let channel_key = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2dldGFzaGVycGEuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFKM0VQN1JUMVYyQjUwUzg3S1AwVlBBQ1MuanNvbiJ9"
        
        cell.clickHandler = {[weak self] in
            guard let self = self else { return }
            Zendesk.initialize(withChannelKey: channel_key,
                               messagingFactory: DefaultMessagingFactory()) { result in
                if case let .failure(error) = result {
                    self.makeAlert(title: "Error", message: error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.showToast(message: "Initialization Successful", seconds: 2)
                    }
                    self.addCountObserver()
                }
            }
        }
        return cell
    }
    func presentCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.showConversationCardCell, for: indexPath) as? ShowConversationCardCell else {
            // If table view fails to dequeue the cell we want (InitializeSDKCardCell) then show a dumb table view cell
            return UITableViewCell()
        }
        cell.clickHandler = {[weak self] in
            guard let self = self else { return }
            guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else { return }
            self.navigationController?.show(viewController, sender: self)
        }
        return cell
    }
    
    func unreadCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.unreadMessageCardCell, for: indexPath) as? ShowUnreadCountCell else {
            // If table view fails to dequeue the cell we want (InitializeSDKCardCell) then show a dumb table view cell
            return UITableViewCell()
        }
        cell.clickHandler = {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showToast(message: "Unread message count: \(self.unreadCount)", seconds: 2)
            }
        }
        return cell
    }
}
