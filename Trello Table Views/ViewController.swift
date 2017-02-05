//
//  ViewController.swift
//  Trello Table Views
//
//  Created by Aditya Vikram Godawat on 05/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController, UIScrollViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAlamo()
        
    }
    
    
    func callAlamo() {
        
        Alamofire.request(_IP+"travelers", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (aResponse) in
                
                switch aResponse.result {
                case .success:
                    
                    print(aResponse.result.value!)
                    
                    if let aJSON = aResponse.result.value as? [NSDictionary] {
                        PARSING_DATA(aDataArray: aJSON)
                        self.moveOn()
                        
                    } else {
                        
                        REMOVE_BLACK_SCREEN()
                        self.showAlert("Error", withMessage: "Please check your network services and try again.")
                        
                    }
                    
                    break
                    
                case .failure(let kError):
                    
                    REMOVE_BLACK_SCREEN()
                    print("Error in Test API", kError.localizedDescription)
                    self.showAlert("Error", withMessage: "Something went wrong. Please try again in sometime.")
                }
        }
        
    }
    
    
    func showAlert(_ title:String, withMessage: String) -> Void {
        
        let anAlert = UIAlertController(title: title, message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        anAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(anAlert, animated: true, completion: nil)
        
    }
    
    
    func moveOn() {
        let aVC = StagesTableViewController()
        REMOVE_BLACK_SCREEN()
        self.navigationController?.pushViewController(aVC, animated: true)
    }
}
