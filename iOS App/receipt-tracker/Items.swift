//
//  Items.swift
//  receipt-tracker
//
//  Created by George Yuan on 03/02/2018.
//  Copyright © 2018 QHacks 2018. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Items : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var tb: UITableView!
    var items : [String : Any] = [:]
    var total : NSNumber = 0
    var type : String = ""
    var selected : Int = -1
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // This is your unwind Segue, and it must be a @IBAction
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        print(selected)
        let source = segue.source as? Edit // This is the source
        if selected == -1 {
            
            items[(source?.itemNameTextField.text)!] = source?.itemPriceTextField.text!
        } else if items.removeValue(forKey: (source?.itemName)!) != nil {
            items[(source?.itemNameTextField.text)!] = source?.itemPriceTextField.text!
        }
        
        print(items)
        var newTotal: Double = total.doubleValue + ((source?.itemPriceTextField.text! as? NSString)?.doubleValue)!
        /*for (_, value) in items {
            if let num = (value as? NSString)?.doubleValue {
                newTotal = newTotal + num
            }
        }*/
        /*self.total += NSNumber(value: ((source?.itemName) as? Double)!-((source?.itemPriceTextField.text! as? NSString)?.doubleValue)!-((source?.itemName) as? Double)!).*/
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        total = NSNumber(value: newTotal)
        totalPriceLabel.text = formatter.string(from: NSNumber(value: newTotal))
        self.tb.reloadData()
        selected = -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        totalPriceLabel.text = formatter.string(from: self.total)
        print("ITEMS IS2", items)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "Edit", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.keys.count + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        if (indexPath.row == Array(self.items.keys).count) {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! Add
            return cell;
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! Item
            cell.itemLabel?.text = Array(self.items.keys)[indexPath.row]
            cell.itemPrice?.text = Array(self.items.values)[indexPath.row] as? String
            return cell;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Edit" && selected < Array(self.items.keys).count) {
            let resultController = segue.destination as! Edit
            print("SELECTED", selected)
            print("DONE", Array(self.items.keys)[selected])
            resultController.itemName = Array(self.items.keys)[selected]
            resultController.itemPrice = (Array(self.items.values)[selected] as? String)!
        } else {
            selected = -1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let valRemoved : Double = ((items[Array(self.items.keys)[indexPath.row]] as? NSString)?.doubleValue)!
            print("val Removed", valRemoved)
            items.removeValue(forKey: Array(self.items.keys)[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            let newTotal: Double = total.doubleValue - valRemoved
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            total = NSNumber(value: newTotal)
            totalPriceLabel.text = formatter.string(from: NSNumber(value: newTotal))
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    @IBAction func saveReceiptClicked(_ sender: Any) {
        let urlString = "https://jli0423.lib.id/dataCheck@dev/confirm"
        
        /*if let theJSONData = try? JSONSerialization.data(
            withJSONObject: items,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            print("JSON string = \(theJSONText!)")
            let urlString = "https://jli0423.lib.id/dataCheck@dev/confirm/?"
        }*/
        
        let parameters : Parameters = [
            "items" : self.items
        ]
        print(parameters)
        
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON() { response in
            print(response.request)
                switch response.result {
                    case .success:
                        print(response)
                        //This is what you have been missing
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break
                    case .failure(let error):
                        
                        print(error)
                        break
            }
        }
    }
}
