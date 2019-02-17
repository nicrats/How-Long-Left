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


class tableController: UITableViewController {
    
    
    @IBOutlet weak var nextEventCell: UITableViewCell!
    @IBOutlet weak var cell2: UISwitch!
    let defaults = HLLDefaults.defaults
    @IBOutlet weak var calendarsRow: UITableViewCell!
    @IBOutlet weak var selectedCalendarsCountLabel: UILabel!
    @IBOutlet weak var darkBackgroundSwitch: UISwitch!
    @IBOutlet weak var addToSiriCell: UITableViewCell!
    @IBOutlet weak var siriPhraseLabel: UILabel!
    @IBOutlet weak var addToSiriLabel: UILabel!
    @IBOutlet weak var magdaleneModeSwitch: UISwitch!
    @IBOutlet weak var milestonesInfoLabel: UILabel!
    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        
        print("\(sender.tag) is \(sender.isOn)")
        
    }
    
  
    
    @IBAction func darkBackgroundsSwitchChanged(_ sender: UISwitch) {
            
            defaults.set(sender.isOn, forKey: "useDarkBackground")
        
    }
    
    @IBAction func magdaleneModeSwitchChanged(_ sender: UISwitch) {
        defaults.set(!sender.isOn, forKey: "magdaleneFeaturesManuallyDisabled")
        
        DispatchQueue.main.async {
            
            WatchSessionManager.sharedManager.updateContext(userInfo: ["MagdaleneManualSettingChanged" : !sender.isOn])
            
            SchoolAnalyser.shared.analyseCalendar()
            
        }
        
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return UIStatusBarStyle.default
        
    }
    
    
    override func viewDidLoad() {
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        //   self.tableView.backgroundColor = #colorLiteral(red: 1, green: 0.5615011254, blue: 0, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        darkBackgroundSwitch.setOn(defaults.bool(forKey: "useDarkBackground"), animated: false)
        
        magdaleneModeSwitch.setOn(!defaults.bool(forKey: "magdaleneFeaturesManuallyDisabled"), animated: false)
        
        
    }
    
    
    func reloadSiriCell() {
        
        if #available(iOS 12.0, *) {
            
            if let voiceShortcut = voiceShortcutStore.registeredShortcut {
                
                updateShortcutEnabled(phrase: voiceShortcut.invocationPhrase)
                
                
            } else {
                
                updateShortcutEnabled(phrase: nil)
                
            }
            
            
        } else {
            siriPhraseLabel.text = "Update iOS"
            siriPhraseLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
            
        }
        
        tableView.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
        if UIApplication.shared.backgroundRefreshStatus != .available {
            
           milestonesInfoLabel.text = "Unavaliable"
            
        } else if HLLDefaults.notifications.milestones.isEmpty == false {
            
            milestonesInfoLabel.text = "\(HLLDefaults.notifications.milestones.count) Enabled"
            
        } else {
            
            milestonesInfoLabel.text = "Off"
            
        }
        
        print("Appear")
        reloadSiriCell()
        
        if let storedIDS = defaults.stringArray(forKey: "setCalendars") {
            
            selectedCalendarsCountLabel.text = String(storedIDS.count)
            
            if storedIDS.count < 1 {
                
                selectedCalendarsCountLabel.textColor = UIColor.red
                
            } else {
                
                selectedCalendarsCountLabel.textColor = #colorLiteral(red: 0.5556007624, green: 0.5556976795, blue: 0.5753890276, alpha: 1)
                
            }
            
        } else {
            
            selectedCalendarsCountLabel.text = "Error"
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Include events from the selected calendars in How Long Left."
            
        }
        
        
        if section == 1 {
            
            return "Check How Long Left with Siri."
            
        }
        
        
        if section == 3 {
            
            if SchoolAnalyser.privSchoolMode == .Magdalene {
                
                return "Enable special features for students of Magdalene Catholic College."
                
            }
            
        }


        
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        
        if section == 3 {
            
            if SchoolAnalyser.privSchoolMode != .Magdalene {
                
                return count - 1
            } else {
                
                return count
                
            }
            
            
            
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 0 {
            
            if #available(iOS 12.0, *) {
                if let shortcut = INShortcut(intent: HowLongLeftIntent()) {
                    
                    shortcut.intent?.suggestedInvocationPhrase = "How Long Left"
                    
                    if let alreadyRegistedVoiceShortcut = voiceShortcutStore.registeredShortcut {
                        
                         alreadyRegistedVoiceShortcut.shortcut.intent?.suggestedInvocationPhrase = "How Long Left"
                        
                       let viewC = INUIEditVoiceShortcutViewController(voiceShortcut: alreadyRegistedVoiceShortcut)
                        viewC.modalPresentationStyle = .formSheet
                        viewC.delegate = self
                      //  self.present(viewC, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            
                            self.present(viewC, animated: true, completion: nil)
                            
                        })
                        
                        
                        
                    } else {
                        
                        
                        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                        viewController.modalPresentationStyle = .formSheet
                        viewController.delegate = self // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
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
    
}
    
    
  /* override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return String(Date().timeIntervalSince1970)
    } */
    
    @objc func close() {
        
        print("Yo navigation controller close plz")
        self.navigationController?.dismiss(animated: true)
        
        
    }
    
    func updateShortcutEnabled(phrase: String?) {
        
        if let uPhrase = phrase {
            
            DispatchQueue.main.async {
                
            self.addToSiriLabel.text = "Siri Phrase"
            self.siriPhraseLabel.text = "\"\(uPhrase)\""
            self.siriPhraseLabel.isHidden = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
            
            self.addToSiriLabel.text = "Add to Siri"
            self.siriPhraseLabel.isHidden = true
                
            }
            
        }
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
        
        
    }
    
    
    let waitToDismiss = 0.25
    
    
}

@available(iOS 12.0, *)
extension tableController: INUIAddVoiceShortcutViewControllerDelegate {
    
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
extension tableController: INUIEditVoiceShortcutViewControllerDelegate {
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
