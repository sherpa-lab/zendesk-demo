//
//  ViewController.swift
//  metadata
//
//  Created by Arnaud Joly on 11/22/23.
//

import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var navBarInfo: UIBarButtonItem!
    @IBOutlet var demoAppView: UIView!
    @IBOutlet weak var tableView: UITableView!
    static let initializeCardCell = "InitializeCardCell"
    static let showConversationCardCell = "ShowConversationCardCell"
    static let fieldsCell = "FieldsCell"
    static let tagsCell = "TagsCell"
    var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styling()
        tableView.register(UINib(nibName: "InitializeSDKCardCell", bundle: nil), forCellReuseIdentifier: MainViewController.initializeCardCell)
        tableView.register(UINib(nibName: "FieldsCell", bundle: nil), forCellReuseIdentifier: MainViewController.fieldsCell)
        tableView.register(UINib(nibName: "TagsCell", bundle: nil), forCellReuseIdentifier: MainViewController.tagsCell)
        tableView.register(UINib(nibName: "ShowConversationCardCell", bundle: nil), forCellReuseIdentifier: MainViewController.showConversationCardCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
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
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
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
            return tagsCell(indexPath: indexPath)
        }
        if index == [0,2] {
            return fieldsCell(indexPath: indexPath)
        }
        if index == [0,3] {
            return presentCell(indexPath: indexPath)
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
            
#warning("Basic init code with a custom alert in case of failure, and a custom toast in case of success.")
            Zendesk.initialize(withChannelKey: channel_key,
                               messagingFactory: DefaultMessagingFactory()) { result in
                if case let .failure(error) = result {
                    self.makeAlert(title: "Error", message: error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.showToast(message: "Initialization Successful", seconds: 2)
                    }
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
            
#warning("Basic conversation presentation via the navigation controller.")
            guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else { return }
            self.navigationController?.show(viewController, sender: self)
        }
        return cell
    }
        func fieldsCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.fieldsCell, for: indexPath) as? FieldsCell else {
            return UITableViewCell()
        }
#warning("Add conversation field, with a custom alert in case of failure, and a custom toast in case of success.")
        cell.addHandler = { [weak self] in
            guard let self = self else { return }
#warning ("Provide the field id and value")
            Zendesk.instance?.messaging!.setConversationFields(["1234567890": "value of the field"])
            DispatchQueue.main.async {
                self.showToast(message: "Field Added", seconds: 2)
            }
        }
        cell.clearHandler = { [weak self] in
            guard let self = self else { return }
            Zendesk.instance?.messaging!.clearConversationFields()
            DispatchQueue.main.async {
                self.showToast(message: "Field cleared", seconds: 2)
            }
        }
        // Configure your cell
        return cell
    }

    func tagsCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.tagsCell, for: indexPath) as? TagsCell else {
            return UITableViewCell()
        }
#warning("Add tags, with a custom alert in case of failure, and a custom toast in case of success.")
        cell.loginHandler = { [weak self] in
            guard let self = self else { return }
#warning ("Provide the tags")
            Zendesk.instance?.messaging!.setConversationTags(["promo_code", "discount"])
            DispatchQueue.main.async {
                self.showToast(message: "Tags Added", seconds: 2)
            }
        }
        cell.logoutHandler = { [weak self] in
            guard let self = self else { return }
            Zendesk.instance?.messaging!.clearConversationTags()
            DispatchQueue.main.async {
                self.showToast(message: "Tags Cleared", seconds: 2)
            }
        }
        return cell
    }
    
}
