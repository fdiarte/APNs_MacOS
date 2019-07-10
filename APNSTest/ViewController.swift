//
//  ViewController.swift
//  APNSTest
//
//  Created by Francisco Diarte on 7/3/19.
//  Copyright © 2019 Francisco Diarte. All rights reserved.
//

import Cocoa

enum APNSEnviornment {
    case sandbox
    case production
}

enum AddItemContext {
    case bundleId
    case contact
}

class ViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var bundleIdPopUpButton: NSPopUpButton!
    @IBOutlet weak var contactPopUpButton: NSPopUpButton!
    @IBOutlet weak var enviornmentSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var payloadTextField: NSTextField!
    @IBOutlet weak var sendNotificationButton: NSButton!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var teamIdTextField: NSTextField!
    @IBOutlet weak var keyIdTextField: NSTextField!
    @IBOutlet weak var notificationSuccessLabel: NSTextField!
    
    
    // MARK: - Class Variables
    var privateKey: String?
    var fileName: String?
    var contacts: [Contact]?
    var apps: [App]?
    var apnsEnviornment: APNSEnviornment = .sandbox
    
    private let apnsController = APNSController()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        payloadTextField.delegate = self
        teamIdTextField.delegate = self
        keyIdTextField.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupView()
    }
    
    func setupView() {
        self.view.frame = NSRect(x: 0, y: 0, width: 500, height: 247)
        self.view.window?.styleMask.remove(.resizable)
        
        enviornmentSegmentedControl.selectedSegment = 0
        bundleIdPopUpButton.removeAllItems()
        contactPopUpButton.removeAllItems()
    }
    
    
    // MARK: - Popup Dialogs
    func presentSuccessLabel(deviceName: String) {
        self.notificationSuccessLabel.stringValue = "Notification successfully sent to \(deviceName)"
    }
    
    func presentAddItemsAlert(context: AddItemContext) {
        let alert = NSAlert()
        let messageText = context == .bundleId ? "Enter a new Bundle Id" : "Enter a new contact"
        let addItemsButtonTitle = context == .bundleId ? "Import Bundle Ids" : "Import Contacts"
        let textFieldPlaceholder = context == .bundleId ? "Bundle Id" : "Contact"
        
        alert.messageText = messageText
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: addItemsButtonTitle)
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        inputTextField.placeholderString = textFieldPlaceholder
        alert.accessoryView = inputTextField
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == .alertFirstButtonReturn {
                let itemAdded = inputTextField.stringValue
                context == .bundleId ? (self.bundleIdPopUpButton.addItem(withTitle: itemAdded)) : (self.contactPopUpButton.addItem(withTitle: itemAdded))
            }
            else if modalResponse == .alertThirdButtonReturn {
                context == .bundleId ? (self.presentAddItemsDialog(context: .bundleId)) : (self.presentAddItemsDialog(context: .contact))
            }
        })
    }
    
    func presentAddItemsDialog(context: AddItemContext) {
        let dialog = NSOpenPanel()
        dialog.title = context == .bundleId ? "Import your bundle Ids" : "Import your contacts"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["csv"]
        
        if dialog.runModal() == .OK {
            guard let result = dialog.url else { return }
            
            let path = result.path
            
            do {
                var file = try String(contentsOfFile: path, encoding: .utf8)
                file = cleanRows(file: file)
                let csvRows = csv(data: file)
                
                if context == .bundleId {
                    bundleIdPopUpButton.removeAllItems()
                    let apps = formatAppRows(csvRows: csvRows)
                    apps.forEach({bundleIdPopUpButton.addItem(withTitle: $0.appForDisplay)})
                }
                else {
                    contactPopUpButton.removeAllItems()
                    let contacts = formatContactRows(csvRows: csvRows)
                    contacts.forEach({contactPopUpButton.addItem(withTitle: $0.contactForDisplay)})
                }
                
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        else {
            print("User clicked on Cancel")
            return
        }
    }
    
    func presentErrorAlert(errorMessage: String) {
        let alert = NSAlert()
        alert.messageText = "APNs Error"
        alert.informativeText = errorMessage
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    
    // MARK: - CSV Format
    func cleanRows(file: String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let formattedRow = row.components(separatedBy: ",").filter({!$0.isEmpty})
            result.append(formattedRow)
        }
        return result.filter({!$0.isEmpty})
    }
    
    func isEmptyRow(csvRow: String?) -> Bool {
        guard let csvRow = csvRow else { return true }
        let formattedRow = csvRow.replacingOccurrences(of: ",", with: "")
        return formattedRow.isEmpty
    }
    
    func formatContactRows(csvRows: [[String]]) -> [Contact] {
        var contacts = [Contact]()
        
        for row in csvRows {
            guard let deviceName = row.first, let deviceToken = row.last else { continue }
            let contact = Contact(deviceName: deviceName, deviceToken: deviceToken)
            contacts.append(contact)
        }
        
        self.contacts = contacts
        return contacts
    }
    
    func formatAppRows(csvRows: [[String]]) -> [App] {
        var apps = [App]()
        
        for row in csvRows {
            guard let appName = row.first, let bundleId = row.last else { continue }
            let app = App(name: appName, bundleId: bundleId)
            apps.append(app)
        }
        
        self.apps = apps
        return apps
    }
    
    
    // MARK: - IBActions
    @IBAction func addBundleIdTapped(_ sender: NSButton) {
        presentAddItemsAlert(context: .bundleId)
    }
    
    @IBAction func addContactTapped(_ sender: NSButton) {
        presentAddItemsAlert(context: .contact)
    }
    
    @IBAction func selectFileTapped(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Select your private key"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["p8"]
        
        guard dialog.runModal() == .OK, let result = dialog.url else { return }
        let path = result.path
        let fileName = path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        fileNameLabel.stringValue = fileName
        
        do {
            let key = try String(contentsOfFile: path, encoding: .utf8)
            self.privateKey = key
            
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    @IBAction func sendNotificationTapped(_ sender: NSButton) {
        guard let key = privateKey else { return }
        
        let payload = payloadTextField.stringValue
        let teamId = teamIdTextField.stringValue.uppercased()
        let keyId = keyIdTextField.stringValue.uppercased()
        
        let contact = (contacts?[contactPopUpButton.indexOfSelectedItem].deviceToken ?? contactPopUpButton.titleOfSelectedItem) ?? ""
        let bundleId = (apps?[bundleIdPopUpButton.indexOfSelectedItem].bundleId ?? bundleIdPopUpButton.titleOfSelectedItem) ?? ""
        
        notificationSuccessLabel.stringValue = ""
        
        apnsController.sendNotification(contact: contact,
                                        bundleId: bundleId,
                                        payload: payload,
                                        privateKey: key,
                                        teamId: teamId,
                                        keyId: keyId,
                                        apnsEnviornment: apnsEnviornment,
                                        success: { [weak self] in
                                            guard let self = self else { return }
                                            
                                            self.presentSuccessLabel(deviceName: self.contacts?[self.contactPopUpButton.indexOfSelectedItem].deviceName ?? self.contactPopUpButton.titleOfSelectedItem ?? "")
        })
        { [weak self] error in
            guard let self = self else { return }
            
            self.notificationSuccessLabel.stringValue = ""
            
            guard error is APNSError else {
                self.presentErrorAlert(errorMessage: "Error Reason: \((error.localizedDescription))")
                return
            }
            
            self.presentErrorAlert(errorMessage: "Error Reason: \((error as! APNSError).reason)")
        }
        
        payloadTextField.stringValue = ""
    }
    
    @IBAction func clearButtonTapped(_ sender: NSButton) {
        bundleIdPopUpButton.removeAllItems()
        contactPopUpButton.removeAllItems()
        contacts?.removeAll()
        apps?.removeAll()
        privateKey = nil
        fileNameLabel.stringValue = ""
        teamIdTextField.stringValue = ""
        keyIdTextField.stringValue = ""
        payloadTextField.stringValue = ""
        notificationSuccessLabel.stringValue = ""
        enviornmentSegmentedControl.selectedSegment = 0
        apnsEnviornment = .sandbox
    }
    
    @IBAction func enviornmentValueChanged(_ sender: NSSegmentedControl) {
        apnsEnviornment = sender.indexOfSelectedItem == 0 ? .sandbox : .production
    }
}


// MARK: - TextFieldDelegate Methods
extension ViewController: NSTextFieldDelegate, NSTextViewDelegate {
    
    func textField(_ textField: NSTextField, textView: NSTextView, candidatesForSelectedRange selectedRange: NSRange) -> [Any]? {
        let teamId = teamIdTextField.stringValue
        let keyId = keyIdTextField.stringValue
        let payload = payloadTextField.stringValue
        
        sendNotificationButton.isEnabled =
            bundleIdPopUpButton.numberOfItems > 0 &&
            contactPopUpButton.numberOfItems > 0 &&
            !payload.isEmpty &&
            !teamId.isEmpty &&
            !keyId.isEmpty &&
            privateKey != nil
        
        return nil
    }
}
