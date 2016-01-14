//
//  NewEventViewController.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import Parse

class NewEventViewController: UIViewController {
    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var eventDescriptionTextView: UITextView!
    @IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var choseDateBtn: UIButton!
    @IBOutlet var setDateBtn: UIButton!
    @IBOutlet var addParticipantsBtn: UIButton!
    @IBOutlet var addLocation: UIButton!
    
    var participants: [PFUser]?
    var eventLocation: PFGeoPoint?
    
    var eventDescription: String {
        get {
            return self.eventDescriptionTextView.text!
        }
    }
    
    var eventName: String {
        get {
            return self.eventNameTextField.text!
        }
    }
    
    var eventDate: NSDate {
        get {
            return eventDatePicker.date
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil {
            return
        }
        switch segue.identifier! {
        case "AddParticipantsViewControllerID":
            if let viewController = segue.destinationViewController as? AddParticipantsViewController {
                viewController.delegate = self
            }
            break
        case "SelectLocationViewControllerID":
            if let viewController = segue.destinationViewController as? SelectLocationViewController {
                viewController.delegate = self
            }
            break
        default:
            break
        }
    }
}

extension NewEventViewController {
    @IBAction func dateSelected(sender: UIDatePicker) {
        if sender.date.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            sender.setDate(NSDate(), animated: true)
            return
        }
    }
    
    @IBAction func setDate(sender: AnyObject) {
        choseDateBtn.hidden = false
        eventDatePicker.hidden = false
    }
    
    @IBAction func choseDate(sender: AnyObject) {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = "@" + dateFormater.stringFromDate(eventDatePicker.date)
        setDateBtn.setTitle(dateString, forState: .Normal)
        choseDateBtn.hidden = true
        eventDatePicker.hidden = true
    }
    
    @IBAction func done(sender: AnyObject) {
        let event = Event.event()
        event.name = eventName
        event.eventDescription = eventDescription
        event.date = eventDate
        event.location = eventLocation!
        event.participants = participants!
        event.saveInBackgroundWithBlock { (succeed, error) -> Void in
            if error != nil {
                self.showErrorMessage(error)
                return
            }
            
            let roleName = "event" + event.objectId! + "role"
            let role = PFRole(name: roleName, acl: PFACL(user: PFUser.currentUser()!))
            for user in self.participants! {
                role.users.addObject(user)
            }
            
            role.saveInBackgroundWithBlock({ (succeed, error) -> Void in
                if error != nil {
                    self.showErrorMessage(error)
                    return
                }
                let acl = PFACL()
                acl.setReadAccess(true, forRole: role)
                event.ACL = acl
                event.saveInBackground()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
            })
        }
    }
    
    func showErrorMessage(error:NSError?) {
        let alert = UIAlertController(title: "Shit!", message: error?.localizedDescription, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(alertAction)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
}

extension NewEventViewController: AddParticipantsDelegate {
    func userSelected(users: [PFUser]) {
        participants = users
        let btnTitle = "\(users.count) participants"
        addParticipantsBtn.setTitle(btnTitle, forState: .Normal)
    }
}

extension NewEventViewController: SelectLocationDelegate {
    func locationSelected(coordinate: CLLocationCoordinate2D) {
        eventLocation = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            
            let placemark = placemarks?.first
            if let locatedAtDict = placemark?.addressDictionary {
                let locatedAt = locatedAtDict["FormattedAddressLines"]?.componentsJoinedByString(", ")
                self.addLocation.setTitle(locatedAt, forState: .Normal)
            }
        }
    }
}