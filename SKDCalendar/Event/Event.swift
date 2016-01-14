//
//  Event.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import Parse

struct EventFields {
    static var className = "Event"
    static var Name = "name"
    static var Description = "description"
    static var Location = "location"
    static var Date = "date"
    static var Participants = "participants"
}

class Event: PFObject {
    class func event() -> Event {
        return Event(className: EventFields.className)
    }
    
    class func eventWithObject(object:PFObject?) -> Event?
    {
        if object == nil {
            return nil
        }
        let event = Event.event()
        event.name = object![EventFields.Name] as! String
        event.eventDescription = object![EventFields.Description] as! String
        event.location = object![EventFields.Location] as! PFGeoPoint
        event.date = object![EventFields.Date] as! NSDate
        event.participants = object![EventFields.Participants] as! [PFUser]
        return event 
    }
    
    var name: String {
        get {
            return self[EventFields.Name] as! String
        }
        set(name) {
            self[EventFields.Name] = name
        }
    }
    
    var eventDescription: String {
        get {
            return self[EventFields.Description] as! String
        }
        set(description) {
            self[EventFields.Description] = description
        }
    }
    
    private var _location: PFGeoPoint?
    var location: PFGeoPoint {
        get {
            return self[EventFields.Location] as! PFGeoPoint
        }
        set(location) {
            _location = location
            self[EventFields.Location] = location
        }
    }
    
    var date: NSDate {
        get {
            return self[EventFields.Date] as! NSDate
        }
        set(date) {
            self[EventFields.Date] = date
        }
    }
    
    var participants: [PFUser] {
        get {
            return self[EventFields.Participants] as! [PFUser]
        }
        set (participants) {
            self[EventFields.Participants] = participants
        }
    }
    
    func eventAddress(complation: (String?, NSError?) -> Void) {
        let geoCoder = CLGeocoder()
        let lat = _location?.latitude
        let lon = _location?.longitude
        let location = CLLocation(latitude: lat!, longitude: lon!)
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    complation(nil, error)
                })
                return
            }
            
            let placemark = placemarks?.first
            if let locatedAtDict = placemark?.addressDictionary {
                let locatedAt = locatedAtDict["FormattedAddressLines"]?.componentsJoinedByString(", ")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    complation(locatedAt, nil)
                })
            }
        }
    }
}
