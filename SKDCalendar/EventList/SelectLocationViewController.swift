//
//  SelectLocationViewController.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 13.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import MapKit

protocol SelectLocationDelegate {
    func locationSelected(coordinate: CLLocationCoordinate2D)
}

class SelectLocationViewController: UIViewController {
    var annotation = MKPointAnnotation()
    var delegate: SelectLocationDelegate?
    @IBOutlet var mapView: MKMapView!
    
    @IBAction func tapToPin(sender: UITapGestureRecognizer) {
        let touchPoint = sender.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)    
    }
    
    @IBAction func done(sender: AnyObject) {
        if mapView.annotations.isEmpty {
            return
        }
        delegate?.locationSelected(annotation.coordinate)
        navigationController?.popViewControllerAnimated(true)
    }
}
