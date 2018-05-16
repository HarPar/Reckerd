//
//  Edit.swift
//  receipt-tracker
//
//  Created by George Yuan on 03/02/2018.
//  Copyright © 2018 QHacks 2018. All rights reserved.
//

import Foundation
import UIKit

class Edit : UITableViewController, UITextFieldDelegate {
    
    var itemName : String = ""
    var itemPrice : String =  ""
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    @IBOutlet weak var navigation: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemNameTextField.delegate = self
        itemPriceTextField.delegate = self
        
        itemNameTextField.text = itemName
        itemPriceTextField.text = itemPrice
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Did begin editing")
        if (itemNameTextField.text?.count == 0 || itemPriceTextField.text?.count == 0) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("Ended editing with sizes",itemNameTextField.text?.count, itemPriceTextField.text?.count)
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        //self.itemName = itemNameTextField.text!
        //self.itemPrice = itemPriceTextField.text!
    }

}
