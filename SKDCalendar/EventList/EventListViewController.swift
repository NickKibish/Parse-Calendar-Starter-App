//
//  EventListViewController.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class EventListTableViewCell: PFTableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var eventDescription: UILabel!
    @IBOutlet var participants: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var date: UILabel!
}

class EventListViewController: PFQueryTableViewController {
    override func queryForTable() -> PFQuery {
        let query = super.queryForTable()
        query.orderByAscending(EventFields.Date)
        query.includeKey(EventFields.Participants)
        return query
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkExistingUser()
    }
    
    func checkExistingUser() {
        // 1
        if PFUser.currentUser() == nil {
            let logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            logInViewController.fields = [.UsernameAndPassword, .PasswordForgotten, .LogInButton, .Facebook, .SignUpButton]
            if let signUpViewController = logInViewController.signUpController {
                signUpViewController.delegate = self
                signUpViewController.fields = [.UsernameAndPassword, .SignUpButton, .DismissButton]
            }
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
        // 1!
    }
}

extension EventListViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellID = "EventListTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? EventListTableViewCell
        if cell == nil {
            cell = EventListTableViewCell(style: .Default, reuseIdentifier: cellID)
        }
        
        if let event = Event.eventWithObject(object!) {
            cell?.name.text = event.name
            cell?.eventDescription.text = event.eventDescription
            
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "dd.MM.yyyy HH:mm"
            cell?.date.text = dateFormater.stringFromDate(event.date)
            
            var userNames = ""
            for user in event.participants {
                userNames += user.username! + ", "
            }
            cell?.participants.text = userNames
            
            event.eventAddress({ (address, error) -> Void in
                if error != nil {
                    return
                }
                cell?.address.text = address!
            })
            
        }
        return cell
    }
}

extension EventListViewController {
    @IBAction func logOut(sender: AnyObject) {
        // 4
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            self.checkExistingUser()
        }
        // 4! - NewEventViewController
    }
}

//2
extension EventListViewController : PFLogInViewControllerDelegate {
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EventListViewController : PFSignUpViewControllerDelegate {
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        user.loadFBData()
    }
}
//2! - PFUser Extention
