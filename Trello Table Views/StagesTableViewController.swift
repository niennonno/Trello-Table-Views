//
//  StagesTableViewController.swift
//  Trello Table Views
//
//  Created by Aditya Vikram Godawat on 05/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO

class StagesTableViewController: UITableViewController {
    
    var pickerOptions = ["Remove","Jan", "Feb", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var isFilterApplied = false
    var filteredMonth = String()
    
    let socket = SocketIOClient(socketURL: URL(string: "ws://samrith.ithaka.travel")!, config: [.log(true), .forcePolling(true)])

    
    var filteredUsers = Array(repeating: Array(arrayLiteral: User()), count: 6)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "User Data"
        
        socket.connect()

        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        socket.onAny { (anEvent) in
            print("Them event", anEvent.event)
        }
        
        socket.on("update_status") { (data, ack) in
            self.parseData(kData: data)
        }
        
        let reOrder = UIBarButtonItem(title: "Reorder", style: .plain, target: self, action: #selector(reOrderData))
        self.navigationItem.rightBarButtonItem = reOrder
        
        let filter = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterIt))
        self.navigationItem.leftBarButtonItem = filter

    }
    
    
    func parseData(kData: [Any]) {
        print(kData)
        let kData = kData[0] as! NSDictionary
        let aUser = User()
        aUser.id = kData["_id"] as! String
        aUser.name = kData["name"] as! String
        aUser.status = kData["status"] as! String
        
        let aDate = kData["tripDate"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        aUser.tripDate = dateFormatter.date(from: aDate)!

        for i in 0..<6 {
            
            for j in 0..<_USERS[i].count-1 {
                if aUser.id == _USERS[i][j].id {
                    _USERS[i].remove(at: j)
                    break
                }
            }
        }
        
        if aUser.status == "onboarding" {
            _USERS[0].append(aUser)
        } else if aUser.status == "education" {
            _USERS[1].append(aUser)
        } else if aUser.status == "planned" {
            _USERS[2].append(aUser)
        } else if aUser.status == "hotels" {
            _USERS[3].append(aUser)
        } else if aUser.status == "activities" {
            _USERS[4].append(aUser)
        } else if aUser.status == "complete" {
            _USERS[5].append(aUser)
        } else {
            print("Error!")
        }
        
        if isFilterApplied {
            filterData(month: filteredMonth)
        } else {
            tableView.reloadData()
        }
    }
    
    
    func filterIt() {
        let filterMenu = UIAlertController(title: nil, message: "Filters", preferredStyle: .actionSheet)
        var i = 0
        for anOption in pickerOptions {
            
            let filterOption = UIAlertAction(title: anOption, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in

            print(anOption)
                self.filterData(month: anOption)
            })
        filterMenu.addAction(filterOption)
        i+=1
        }
        self.present(filterMenu, animated: true, completion: nil)

    }
    
    func filterData(month: String) {
        
        filteredUsers = Array(repeating: Array(arrayLiteral: User()), count: 6)
        
        filteredMonth = month
        
        if filteredMonth == "Remove" {
            isFilterApplied = false
        } else {
            isFilterApplied = true
            
            compareMonth(kMonth: filteredMonth)
        }
        tableView.reloadData()
    }
    
    
    func compareMonth(kMonth: String) {
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMMM"
        dayTimePeriodFormatter.timeZone = .current
        
        for i in 0..<6 {
            
            for aUser in _USERS[i] {
                if dayTimePeriodFormatter.string(from: aUser.tripDate) == kMonth {
                    filteredUsers[i].append(aUser)
                }
            }
            filteredUsers[i].remove(at: 0)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return _STAGES.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section <= 5 {
            
            
            if isFilterApplied {
              return filteredUsers[section].count
            } else {
                return _USERS[section].count
            }
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _STAGES[section]
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = UITableViewCell(style: .subtitle, reuseIdentifier: "")
        
        let aSection = indexPath.section
        let anIndex = indexPath.row
        
        var aUser = User()
        
        if isFilterApplied {
            
            aUser = filteredUsers[aSection][anIndex]
            
        } else {
            aUser = _USERS[aSection][anIndex]
        }
        
        if indexPath.row == 0 {
            
        }
        aCell.textLabel?.text = aUser.name
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM d, yyyy"
        dayTimePeriodFormatter.timeZone = .current
        
        aCell.detailTextLabel?.text = dayTimePeriodFormatter.string(from: aUser.tripDate)
        
        return aCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func reOrderData() {
//        if !isFilterApplied {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }
//        } else {
//            self.showAlert("Oops!", withMessage: "Remove Filter to move users")
//        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let aSourceSection = sourceIndexPath.section
        let aSourceIndex = sourceIndexPath.row
        var newStatus = String()
        var aUserToBeMoved = User()
        let aDestinationSection = destinationIndexPath.section
        
        if isFilterApplied {
            
            aUserToBeMoved = filteredUsers[aSourceSection][aSourceIndex]
            filteredUsers[aSourceSection].remove(at: aSourceIndex)
            compareIdAndRemove(kId: aUserToBeMoved.id)
            filteredUsers[aDestinationSection].append(aUserToBeMoved)

        } else {
            aUserToBeMoved = _USERS[aSourceSection][aSourceIndex]
            _USERS[aSourceSection].remove(at: aSourceIndex)
        }
        
        _USERS[aDestinationSection].append(aUserToBeMoved)
        
        newStatus = _STAGES[aDestinationSection]
        
        updateBackend(id: aUserToBeMoved.id, status: newStatus)
        
        tableView.reloadData()
        
    }
    
    
    func compareIdAndRemove(kId: String) {
        
        for i in 0..<6 {
            
            for j in 0..<_USERS[i].count-1 {
                if _USERS[i][j].id == kId {
                    _USERS[i].remove(at: j)
                }
            }
        }
    }

    
    
    func updateBackend(id: String, status: String) {
        
        let aParams = ["_id" : id , "status" : status]
        
        Alamofire.request(_IP+"traveler/status", method: .put, parameters: aParams, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (aResponse) in
                
                switch aResponse.result {
                case .success:
                    
                    print(aResponse.result.value!)
                    
                    if let aJSON = aResponse.result.value as? NSDictionary {
                        print(aJSON)
                    } else {
                        
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

}
