//
//  SettingsMainTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 24/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import Intents
import IntentsUI
import UserNotifications

class SettingsMainTableViewController: UITableViewController, ThemeChangedDelegate {
    
    static let themeTransitionTime = 0.0
    
    static var justPurchasedComplication = false
    var themeableCells = [ThemeableCell]()
    
    let defaults = HLLDefaults.defaults
    var tableSections = [Int:SettingsSection]()
    let schoolAnalyser = SchoolAnalyser()
    var genedSections: Int {
        
        get {
            
            return tableSections.count
            
            
        }
        
    }
    
    override func viewDidLoad() {
        
        extendedLayoutIncludesOpaqueBars = true
        updateTheme()

      //  self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        //   self.tableView.backgroundColor = #colorLiteral(red: 1, green: 0.5615011254, blue: 0, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
        
        DispatchQueue.main.async {
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
            
        }
        
        
        
        
    //    darkBackgroundSwitch.setOn(defaults.bool(forKey: "useDarkBackground"), animated: false)

    }

    
    @objc func updateTheme() {
        
        self.tableView.backgroundColor = AppTheme.current.groupedTableViewBackgroundColor
        self.tableView.separatorColor = AppTheme.current.tableCellSeperatorColor
        self.navigationController?.navigationBar.barStyle = AppTheme.current.barStyle
        self.tabBarController?.tabBar.backgroundColor = nil
        self.tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        self.navigationController?.navigationBar.isTranslucent = AppTheme.current.translucentBars
        self.tabBarController?.tabBar.isTranslucent = AppTheme.current.translucentBars
    }
    
    
    @objc func appMovedToForeground() {
        
        tableView.reloadData()
        
    }
    
    func generateTableData() {

        tableSections.removeAll()
        
        tableSections[tableSections.count] = SettingsSection.General
        
        tableSections[tableSections.count] = SettingsSection.Siri
        
        if WatchSessionManager.sharedManager.watchSupported() == true {
        //tableSections[tableSections.count] = SettingsSection.Complication
        }
        
        if SchoolAnalyser.schoolModeIgnoringUserPreferences == .Magdalene {
        tableSections[tableSections.count] = SettingsSection.Magdalene
        }
        
        themeableCells.removeAll()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        
        if SettingsMainTableViewController.justPurchasedComplication == true {
            
            SettingsMainTableViewController.justPurchasedComplication = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                self.showComplicationPurchasedAlert(purchasedNow: true)
                
            })
            
            
            
            
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        let sectionType = tableSections[section]!
        
        if sectionType == SettingsSection.Siri {
            
            return "Check How Long Left with Siri."
            
        }
        
        if sectionType == SettingsSection.Magdalene {
                
            return "Enable special features for students of Magdalene Catholic College."
            
        }

        if sectionType == .Complication {
            
            return "Enable to count down current and upcoming events on your watch face."
            
        }

        
        return nil
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        generateTableData()
        
        return tableSections.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionType = tableSections[section]!
        
        switch sectionType {
            
        case .General:
            return 3
        case .Siri:
            return 1
        case .Complication:
            return 1
        case .Magdalene:
            return 1
        }
        
       // return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionType = tableSections[indexPath.section]!
        let row = indexPath.row
        
        switch sectionType {
        
        case .General:
            
            if row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! MainCalendarsRow
                themeableCells.append(cell)
                cell.setupCell()
                return cell
                
            } else if row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! MainNotificationsCell
                themeableCells.append(cell)
                cell.setupCell()
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! MainThemeCell
                themeableCells.append(cell)
                cell.setupCell(d: self)
                return cell
                
                
            }
            
            
        
        case .Siri:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SiriCell", for: indexPath) as! MainSiriCell
            cell.setupCell()
            themeableCells.append(cell)
            return cell
            
        case .Complication:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComplicationCell", for: indexPath) as! MainComplicationCell
            themeableCells.append(cell)
            cell.setupCell()
            return cell
            
        case .Magdalene:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MagdaleneCell", for: indexPath) as! MainMagdaleneCell
            themeableCells.append(cell)
            cell.setupCell()
            return cell
        }
        
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = tableSections[indexPath.section]!
        
        if section == .General {
            
            
            if indexPath.row == 0 {
                
                if EventDataSource.accessToCalendar == .Granted {
                
                performSegue(withIdentifier: "CalendarsSegue", sender: nil)
                    
                } else {
                    
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                            })
                        }
                    }

                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                }
                
                
            }
            
            if indexPath.row == 1 {
                
                performSegue(withIdentifier: "MilestonesSegue", sender: nil)
                
            }
            
            
            
        }
        
        if section == SettingsSection.Siri, indexPath.row == 0 {
            
            if #available(iOS 12.0, *) {
                if let shortcut = INShortcut(intent: HowLongLeftIntent()) {
                    
                    shortcut.intent?.suggestedInvocationPhrase = "How Long Left"
                    
                    if let alreadyRegistedVoiceShortcut = voiceShortcutStore.registeredShortcut {
                        
                         alreadyRegistedVoiceShortcut.shortcut.intent?.suggestedInvocationPhrase = "How Long Left"
                        
                       let viewC = INUIEditVoiceShortcutViewController(voiceShortcut: alreadyRegistedVoiceShortcut)
                        viewC.modalPresentationStyle = .formSheet
                        viewC.delegate = self
                        viewC.view.tintColor = UIColor.HLLOrange
                      //  self.present(viewC, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            
                            self.present(viewC, animated: true, completion: nil)
                            
                        })
                        
                        
                        
                    } else {
                        
                        
                        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                        viewController.modalPresentationStyle = .formSheet
                        viewController.delegate = self
                        viewController.view.tintColor = UIColor.HLLOrange
                        viewController.view.backgroundColor = UIColor.black
        
                        
                        
                        // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
                     //   self.present(viewController, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            
                            self.present(viewController, animated: true, completion: nil)
                            
                        })
                        
                    }
                    
                    
                }
                
                
                
            } else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    
                    tableView.reloadData()
                    
                })
                
            }
            
            
        }
        
        if section == SettingsSection.Complication {
            
            if IAPHandler.shared.hasPurchasedComplication() == false {
            
            let vc = AppFunctions.shared.getPurchaseComplicationViewController()
            
          present(vc, animated: true, completion: nil)
            
            } else {
                
            showComplicationPurchasedAlert(purchasedNow: false)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    
}
    
    func showComplicationPurchasedAlert(purchasedNow: Bool) {
        
        var titleText = "You've purchased the Apple Watch Complication"
        
        if purchasedNow {
            
            titleText = "Purchase Successful!"
            
        }
        
        
        let alertController = UIAlertController(title: titleText, message: "You may need to launch How Long Left on your watch to trigger changes.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action1)
        alertController.view.tintColor = UIColor.HLLOrange
        DispatchQueue.main.async {
        self.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    
    func themeChanged() {
        
        DispatchQueue.main.async {
            
            
            for cell in self.themeableCells {
                
                cell.updateTheme(animated: false)
                
                
                
            }
            
        }
        
        updateTheme()
        
        NotificationCenter.default.post(name: Notification.Name("ThemeChanged"), object: nil)
        
    }
    

    let waitToDismiss = 0.25
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return UIStatusBarStyle.default
        
    }
    
    
    
}

@available(iOS 12.0, *)
extension SettingsMainTableViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        VoiceShortcutStatusChecker.shared.check()
        VoiceShortcutStatusChecker.shared.check()
        DispatchQueue.main.asyncAfter(deadline: .now() + waitToDismiss, execute: {
            controller.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        VoiceShortcutStatusChecker.shared.check()
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
}

@available(iOS 12.0, *)
extension SettingsMainTableViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        VoiceShortcutStatusChecker.shared.check()
        DispatchQueue.main.asyncAfter(deadline:.now() + waitToDismiss, execute: {
            controller.dismiss(animated: true, completion: nil)
        })
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        VoiceShortcutStatusChecker.shared.check()
        DispatchQueue.main.asyncAfter(deadline: .now() + waitToDismiss
            , execute: {
            controller.dismiss(animated: true, completion: nil)
        })
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
}


@available(iOS 12.0, *)
class voiceShortcutStore {
    static var registeredShortcut: INVoiceShortcut?
}

class MainCalendarsRow: UITableViewCell, ThemeableCell {
    
    
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    func setupCell() {
        
        
       themeChanged()
        
        if EventDataSource.accessToCalendar == .Granted {
        
        if let storedIDS = HLLDefaults.defaults.stringArray(forKey: "setCalendars") {
            
            countLabel.text = String(storedIDS.count)
            
            if storedIDS.count < 1 {
                
                countLabel.textColor = UIColor.red
                
            } else {
                
                countLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
                
            }
            
        } else {
            
            countLabel.text = "Error"
            
        }
        } else {
            
            countLabel.text = "No Access"
            countLabel.textColor = UIColor.red
            
        }
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        
    }
    
    func updateTheme(animated: Bool) {
        
            self.themeChanged()
        
    }
    
}

class MainNotificationsCell: UITableViewCell, ThemeableCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    func setupCell() {
        
       themeChanged()
        
        if UIApplication.shared.backgroundRefreshStatus != .available {
            
            statusLabel.text = "Unavaliable"
            
        } else if HLLDefaults.notifications.milestones.isEmpty == false || HLLDefaults.notifications.Percentagemilestones.isEmpty == false {
            
            let center = UNUserNotificationCenter.current()
            // Request permission to display alerts and play sounds.
            
            center.requestAuthorization(options: [.alert, .sound, .badge])
            { (granted, error) in
                
                DispatchQueue.main.async {
                
                if granted == false {
                    
                    self.statusLabel.text = "No Permission"
                    self.statusLabel.textColor = UIColor.red
                    
                    
                } else {
                    
                    self.statusLabel.text = "\(HLLDefaults.notifications.milestones.count+HLLDefaults.notifications.Percentagemilestones.count) Enabled"
                    self.statusLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
                    
                }
                    
                }
            }
            
        } else {
            
            statusLabel.text = "Off"
            statusLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
            
        }
        
        
        
        
    }
    
    func updateTheme(animated: Bool) {
        
        self.themeChanged()
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        
        
    }
    
}

class MainThemeCell: UITableViewCell, ThemeableCell {
    
    
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: ThemeChangedDelegate?
    
    func setupCell(d: ThemeChangedDelegate) {
        
        delegate = d
        
        themeChanged()
       
        themeSwitch.setOn(HLLDefaults.defaults.bool(forKey: "useDarkTheme"), animated: false)
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        
    }
    
    func updateTheme(animated: Bool) {
        
        self.themeChanged()
        
    }

    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        
        HLLDefaults.defaults.set(sender.isOn, forKey: "useDarkTheme")
        delegate?.themeChanged()
        
        
        
      
        
    }
    
    
    
    
}

class MainSiriCell: UITableViewCell, ThemeableCell {
    
    @IBOutlet weak var addToSiriLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setupCell() {
        
        themeChanged()
        
        if #available(iOS 12.0, *) {
            
            if let voiceShortcut = voiceShortcutStore.registeredShortcut {
                
                updateShortcutEnabled(phrase: voiceShortcut.invocationPhrase)
                
                
            } else {
                
                updateShortcutEnabled(phrase: nil)
                
            }
            
            
        } else {
            statusLabel.text = "Update iOS"
            statusLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
            
        }
        
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        addToSiriLabel.textColor = AppTheme.current.textColor
        
    }
    
    func updateTheme(animated: Bool) {
        
        self.themeChanged()
        
    }

    
    func updateShortcutEnabled(phrase: String?) {
        
        if let uPhrase = phrase {
            
            
            self.addToSiriLabel.text = "Siri Phrase"
            self.statusLabel.text = "\"\(uPhrase)\""
            self.statusLabel.isHidden = false
            
            
            
        } else {
            
            
            self.addToSiriLabel.text = "Add to Siri"
            self.statusLabel.isHidden = true
            
            
            
        }
        
        
        
        
    }
    
}

class MainComplicationCell: UITableViewCell, ThemeableCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var complicationFakeSwitch: UISwitch!
    
    
    func setupCell() {
        
       themeChanged()
        
        complicationFakeSwitch.setOn(IAPHandler.shared.hasPurchasedComplication(), animated: false)
        
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        
    }
    
    func updateTheme(animated: Bool) {
        
        self.themeChanged()
        
    }

    
    @IBAction func complicationSwitchChanged(_ sender: UISwitch) {
        IAPHandler.shared.setPurchasedStatus(sender.isOn)
        
        DefaultsSync.shared.syncDefaultsToWatch()
        
    }
    
    
    
}

class MainMagdaleneCell: UITableViewCell, ThemeableCell {
    
    let schoolAnalyser = SchoolAnalyser()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    
    func setupCell() {
        
        themeChanged()
        enabledSwitch.setOn(!HLLDefaults.defaults.bool(forKey: "magdaleneFeaturesManuallyDisabled"), animated: false)
        
        
    }
    
    @objc func themeChanged() {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .darkGray
        self.selectedBackgroundView = bgColorView
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        
    }
    
    func updateTheme(animated: Bool) {
        
        self.themeChanged()
        
    }

    
    
    @IBAction func magdaleneSwitchChanged(_ sender: UISwitch) {
        
        
        HLLDefaults.magdalene.manuallyDisabled = !sender.isOn
        DefaultsSync.shared.syncDefaultsToWatch()
        schoolAnalyser.analyseCalendar()
        
    }
    
    
}

enum SettingsSection: String {
    
    case General = "General"
    case Siri = "Siri"
    case Complication = "Complication"
    case Magdalene = "Magdalene"
    
}

protocol ThemeChangedDelegate {
    func themeChanged()
}

protocol ThemeableCell {
    func updateTheme(animated: Bool)
}
