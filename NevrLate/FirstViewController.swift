//
//  FirstViewController.swift
//  NevrLate
//
//  Created by Shawn Berg on 9/9/17.
//  Copyright © 2017 Shawn Berg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import EventKit

let eventStore = EKEventStore()


class FirstViewController: UIViewController, MKMapViewDelegate
{
    // Declare and initialize variables
    var request = MKDirectionsRequest()
    var directions: MKDirections!
    let locationManager = CLLocationManager()
    var sourceItem = MKMapItem()
    var destinationItem = MKMapItem()
    var originText = ""
    var destinationText = ""
    var lat1 = CLLocationDegrees()
    var lon1 = CLLocationDegrees()
    var lat2 = CLLocationDegrees()
    var lon2 = CLLocationDegrees()
    var dateSelection = Date()
    var ETAtime = 0
    let leaveTime = EKEvent(eventStore: eventStore)
    
    
    @IBOutlet var ETA: UILabel! // Travel time label
    
    // Origin text field
    // When changed
    @IBAction func originFieldChanged(_ textField: UITextField){
        originText = textField.text!
        //getOriginCoord() // Set origin coords
        
        
        /* Debugging status messages */
        //print("\(lat1)")
        //print("\(lon1)")
        
    }
    
    // Destination text field
    // When changed
    @IBAction func destinationFieldChanged(_ textField: UITextField){
        destinationText = textField.text!
        //getDestinationCoord() // Set destination coords
        
        
        /* Debugging status messages */
        //print("\(lat2)")
        //print("\(lon2)")
    }
    
    // Function to set Origin Coords
    func getOriginCoord() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(originText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lat2 = (placemark?.location?.coordinate.latitude)!
            self.lon2 = (placemark?.location?.coordinate.longitude)!
            
            // Debug Message
            //print("3")
        }
    }
    
    // Function to set Destination Coords
    func getDestinationCoord() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(destinationText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lat1 = (placemark?.location?.coordinate.latitude)!
            self.lon1 = (placemark?.location?.coordinate.longitude)!
            
            // Debug Message
            //print("1")
        }
    }

    @IBAction func getDirections(_ sender: UIButton){
        /* Debug Messages */
        //print("\(lat1)")
        //print("\(lon1)")
        //print("\(lat2)")
        //print("\(lon2)")
        //print("Z")
        
        getOriginCoord()
        getDestinationCoord()
        
        // Convert Lat and Lon values to CLLocation2D Coord values
        let originCoord = CLLocationCoordinate2DMake(lat1, lon1)
        let destinationCoord = CLLocationCoordinate2DMake(lat2, lon2)
        
        // Declare and set origin and destination Map items.
        sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: originCoord, addressDictionary: nil))
        destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord, addressDictionary: nil))
        
        // User authorize location use
        //locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        // Show user location
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        
        
        // Create map annotations for Origin and Destination
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Origin"
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Destination"
        
        // Declare a MKDirectionsRequest
        let request = MKDirectionsRequest()
        request.source = sourceItem
        request.destination = destinationItem
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        
        // Use MKDirectionsRequest object to initialize MKDirections object
        let directions = MKDirections(request: request)
        let directions2 = MKDirections(request: request)
        
        // Debug Message
        //print ("D")
        
        // Set map annotations coordinates
        sourceAnnotation.coordinate = originCoord
        destinationAnnotation.coordinate = destinationCoord
        
        // Show map annotations
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true)
        
        
        // Calculate travel time
        directions.calculateETA{(etaResponse, error) -> Void in
            if let error = error {
                print("Error while requesting ETA: \(error.localizedDescription)")
                
            }else{
                print("\(Int((etaResponse?.expectedTravelTime)!/60)) min")
                //self.ETA.text = "\(Int((etaResponse?.expectedTravelTime)!/60)) min"
                self.ETAtime = Int((etaResponse?.expectedTravelTime)!)
            }
            // Debug Message
            //print ("E")
        }
        
        // Calculate directions
        directions2.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            // Declare route variable
            let route = response.routes[0]
            
            // Add route to map
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            // Show route on map
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }

    }
    
    //var testETA = TimeInterval()
    //var dateSelection = Date()
    
    //let leaveTime = EKEvent(eventStore: eventStore)
    
    //let relativeAlarm = EKAlarm(relativeOffset: TimeInterval())
    
    @IBAction func setDate(sender: UIDatePicker){
        dateSelection = sender.date
        
    }
    
    @IBAction func setAlarm(_ sender: UIButton){
        
        //var dateAlarm = EKAlarm(absoluteDate: dateSelection)
        
        
        leaveTime.startDate = dateSelection //arrival time as set by user
        leaveTime.addAlarm(EKAlarm(relativeOffset: -TimeInterval(ETAtime))) //alarm reminding user to leave
        
        // Debugging
         print("\(dateSelection)")
         print("\(leaveTime.startDate - TimeInterval(ETAtime))")
        
        
        
    }

    
    // Show map
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: MKMapViewDelegate

    // Show map with route line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.magenta
        renderer.lineWidth = 4.0
        
        return renderer
    }
}
