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


class FirstViewController: UIViewController, MKMapViewDelegate
{
    // Declare and initialize variables
    var request = MKDirectionsRequest()
    var directions: MKDirections!
    var locationManager: CLLocationManager!
    var sourceItem = MKMapItem()
    var destinationItem = MKMapItem()
    var originText = ""
    var destinationText = ""
    var lat1 = CLLocationDegrees()
    var lon1 = CLLocationDegrees()
    var lat2 = CLLocationDegrees()
    var lon2 = CLLocationDegrees()
    
    
    @IBOutlet var ETA: UILabel! // Travel time label
    
    // Origin text field
    // When changed
    @IBAction func originFieldChanged(_ textField: UITextField){
        originText = textField.text!
        getOriginCoordLat() // Set origin coord for latitude
        getOriginCoordLon() // Set origin coord for longitude
        
        /* Debugging status messages */
        //print("\(lat1)")
        //print("\(lon1)")
        
    }
    
    // Destination text field
    // When changed
    @IBAction func destinationFieldChanged(_ textField: UITextField){
        destinationText = textField.text!
        getDestinationCoordLat() // Set destination coord for lat
        getDestinationCoordLon() // Set destination coord for lon
        
        /* Debugging status messages */
        //print("\(lat2)")
        //print("\(lon2)")
    }
    
    // Function to set Destination Lat Coord
    func getDestinationCoordLat() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(destinationText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lat1 = (placemark?.location?.coordinate.latitude)!
            
            // Debug Message
            //print("1")
            }
    }
    
    // Function to set Destination Lon Coord
    func getDestinationCoordLon() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(destinationText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lon1 = (placemark?.location?.coordinate.longitude)!
            
            // Debug Message
            //print("2")
        }
    }
    
    // Function to set Origin Lat Coord
    func getOriginCoordLat() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(originText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lat2 = (placemark?.location?.coordinate.latitude)!
            
            // Debug Message
            //print("3")
        }
    }
    
    // Function to set Origin Lon Coord
    func getOriginCoordLon() {
        
        let geocoder = CLGeocoder() // Declare geocoder
        
        // Convert destination text to geolocation
        geocoder.geocodeAddressString(originText) {
            placemarks, error in
            let placemark = placemarks?.first
            
            // Set Destination latitude
            self.lon2 = (placemark?.location?.coordinate.longitude)!
            
            // Debug Message
            //print("4")
        }
    }

    
    @IBAction func getDirections(_ sender: UIButton){
        /* Debug Messages */
        //print("\(lat1)")
        //print("W")
        //print("\(lon1)")
        //print("X")
        //print("\(lat2)")
        //print("Y")
        //print("\(lon2)")
        //print("Z")
        
        // Conver Lat and Lon values to CLLocation2D Coord values
        let originCoord = CLLocationCoordinate2DMake(lat1, lon1)
        let destinationCoord = CLLocationCoordinate2DMake(lat2, lon2)
        
        // Declare and set origin and destination Map items.
        sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: originCoord, addressDictionary: nil))
        destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord, addressDictionary: nil))
        
        // User authorize location use
        locationManager = CLLocationManager()
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
                self.ETA.text = "\(Int((etaResponse?.expectedTravelTime)!/60)) min"
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
