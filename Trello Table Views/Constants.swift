//
//  Constants.swift
//  Trello Table Views
//
//  Created by Aditya Vikram Godawat on 05/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit


var _BLACK_VIEW = UIView()
var _IP = "http://samrith.ithaka.travel/"

var _USERS = Array(repeating: Array(arrayLiteral: User()), count: 6)



var _STAGES = ["onboarding",
               "education",
               "planned",
               "hotels",
               "activities",
               "complete"]


class User {
    
    var id = String()
    var name = String()
    var status = String()
    var tripDate: Date!
    
}


// MARK: - Displaying Black Screen

func SHOW_BLACK_SCREEN() {
    
    _BLACK_VIEW = UIView(frame: UIScreen.main.bounds)
    _BLACK_VIEW.backgroundColor = UIColor.black
    _BLACK_VIEW.alpha = 0.75
    
    let aMainWindow = UIApplication.shared.delegate!.window
    aMainWindow!!.addSubview(_BLACK_VIEW)
    
    let aLoadingImage = UIActivityIndicatorView()
    aLoadingImage.color = .white
    aLoadingImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    aLoadingImage.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    
    _BLACK_VIEW.addSubview(aLoadingImage)
    aLoadingImage.startAnimating()
}


func PARSING_DATA(aDataArray : [NSDictionary]) {
    
    for aData in aDataArray {
        
        let aUser = User()
        
        aUser.id = aData["_id"] as! String
        aUser.name = aData["name"] as! String
        
        if aUser.name == "" {
            print("\n\n", aData)
        }
       
        let aDate = aData["tripDate"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        aUser.tripDate = dateFormatter.date(from: aDate)!
        aUser.status = aData["status"] as! String
        
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
    }
    
    _USERS[0].remove(at: 0)
    _USERS[1].remove(at: 0)
    _USERS[2].remove(at: 0)
    _USERS[3].remove(at: 0)
    _USERS[4].remove(at: 0)
    _USERS[5].remove(at: 0)

    
}


func REMOVE_BLACK_SCREEN() {
    _BLACK_VIEW.removeFromSuperview()
}
