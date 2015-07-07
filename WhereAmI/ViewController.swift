//
//  ViewController.swift
//  WhereAmI
//
//  Created by Nick Holt on 7/6/15.
//  Copyright (c) 2015 Nick Holt. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let manager: CLLocationManager
    let geocodePeriod: NSTimeInterval
    var previousUpdateTimestamp: NSDate
    
    @IBOutlet weak var geocodeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var hAccuracyLabel: UILabel!
    @IBOutlet weak var vAccuracyLabel: UILabel!
    
    required init(coder aDecoder: NSCoder)  {
        manager = CLLocationManager()
        geocodePeriod = 60 // seconds
        previousUpdateTimestamp = NSDate(timeIntervalSinceReferenceDate: -geocodePeriod)
        
        super.init(coder:aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        
        // Request in-use location services permission
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
    
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newestLocation = locations[0] as! CLLocation
        
        // Update view
        latitudeLabel.text = NSString(format:"%.5f°", newestLocation.coordinate.latitude) as String
        longitudeLabel.text = NSString(format:"%.5f°", newestLocation.coordinate.longitude) as String
        altitudeLabel.text = NSString(format:"%.2fm", newestLocation.altitude) as String
        speedLabel.text = NSString(format:"%.2fm/s", newestLocation.speed) as String
        hAccuracyLabel.text = NSString(format:"%.2fm", newestLocation.horizontalAccuracy) as String
        vAccuracyLabel.text = NSString(format:"%.2fm", newestLocation.verticalAccuracy) as String
        
        // Perform reverse geocode (if needed)
        let newTimestamp = newestLocation.timestamp
        if newTimestamp.timeIntervalSinceDate(previousUpdateTimestamp) >= geocodePeriod {
            CLGeocoder().reverseGeocodeLocation(newestLocation) {
                let placemark = $0.0[0] as! CLPlacemark
                let error = $0.1
                
                if error != nil {
                    println("Reverse geocoding failed with error: " + error.localizedDescription)
                } else {
                    self.geocodeLabel.text = placemark.name + ", " + placemark.locality
                }
            }
        }
        
        previousUpdateTimestamp = newTimestamp
    }

    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        headingLabel.text = newHeading.description
    }
}

