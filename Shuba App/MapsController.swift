//
//  MapsController.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 21/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

var GeoAngle = 0.0

var marker = GMSMarker()
var markerIndex = 0
var markers:[MyMarker] = []

class MapsController: UIViewController, GMSMapViewDelegate {
    
    var mapView: GMSMapView?
    
    var loctionManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        GMSServices.provideAPIKey("AIzaSyCk3RC3-gV5o9m0MjJNT7Z0gK8ZKGY0q94")
        fecthStops()
        fectchDriver()
        
        reloadMaps()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next Stop", style: .plain, target: self, action: (#selector(MapsController.next as (MapsController) -> () -> ())))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "locations", style: .plain, target: self, action: #selector(handleLocations))
        
        navigationItem.title = "Map View"
        
      //  let locValue: CLLocationCoordinate2D = loctionManager.location!.coordinate
       // print(locValue)
        
    }
    
    func reloadMaps(){
        
        let camera = GMSCameraPosition.camera(withLatitude: 5.537892, longitude: -0.329703, zoom: 16)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        mapView?.settings.scrollGestures = true
        mapView?.settings.zoomGestures = true
        mapView?.animate(toBearing: 0)
        view = mapView
        
        mapView?.settings.scrollGestures = true
        mapView?.settings.zoomGestures = true
        mapView?.mapType = kGMSTypeNormal; // kGMSTypeSatellite; // kGMSTypeNormal; // kGMSTypeHybrid;
        view = mapView
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.tiltGestures = true
        mapView?.settings.rotateGestures = true
        mapView?.padding = UIEdgeInsetsMake(70, 0, 50, 0)
        mapView?.settings.indoorPicker = true
        mapView?.delegate = self
        mapView?.settings.compassButton = true
        
       
        
    }
    
    let locationsLauncher = LocationsLauncher()
    
    func handleLocations() {
        
        locationsLauncher.showLocations()
    }
    
    var stops = [Stop]()
    
    func fecthStops() {
        
        FIRDatabase.database().reference().child("stops").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let stop = Stop()
                stop.setValuesForKeys(dictionary)
                self.stops.append(stop)
                
                let currentLocation = CLLocationCoordinate2DMake(stop.latitude as! CLLocationDegrees, stop.longitude as! CLLocationDegrees)
                let marker = GMSMarker(position: currentLocation)
                marker.isDraggable = true
                marker.title = stop.stopName
                marker.map = self.mapView
                
                
            }
            
        }, withCancel: nil)
    }
    
    func fectchDriver() {
        var markers:[MyMarker] = []
        
        FIRDatabase.database().reference().child("buses").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let driver = Driver()
                driver.setValuesForKeys(dictionary)
                
                let driverLocation = CLLocationCoordinate2DMake(driver.latitude as! CLLocationDegrees, driver.longitude as! CLLocationDegrees)
                let speed = Double(driver.speed!).rounded()
                let marker = GMSMarker(position: driverLocation)
                marker.title = driver.driverName
                marker.icon = UIImage(named: "driver")
                marker.snippet = String(speed) + " kmph"
                marker.map = self.mapView
                
                let myMarker : MyMarker = MyMarker()
                myMarker.key = snapshot.key
                myMarker.marker = marker
                myMarker.driver = driver
                
                markers.append(myMarker)
                
            }
            
        }, withCancel: nil)
        
        
        FIRDatabase.database().reference().child("buses").observe(.childChanged, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let driver = Driver()
                driver.setValuesForKeys(dictionary)
                
                let driverLocation = CLLocationCoordinate2DMake(driver.latitude as! CLLocationDegrees, driver.longitude as! CLLocationDegrees)
                
                let marker = GMSMarker(position: driverLocation)
                let speed = Double(driver.speed!).rounded()
                marker.title = driver.driverName
                marker.icon = UIImage(named: "driver")
                marker.snippet = String(speed) + " kmph"
                
                var index = 0
                for i in 0 ..< markers.count {
                    let item = markers[i]
                    if(item.key?.contains(snapshot.key))!{
                        _ = item.marker
                        self.mapView?.clear()
                        index = i
                    }
                }
                
                markers.remove(at: index)
                let myMarker : MyMarker = MyMarker()
                myMarker.key = snapshot.key
                myMarker.marker = marker
                myMarker.driver = driver
                
                markers.append(myMarker)
                
                
                for i in 0 ..< markers.count {
                    let item = markers[i]
                    let mark1 = item.marker
                    let driver = item.driver!
                    
                    let myMarker : MyMarker = MyMarker()
                    myMarker.key = snapshot.key
                    myMarker.marker = marker
                    myMarker.driver = driver
                    
                    
                    mark1?.title = driver.driverName
                    let speed2 = Double(driver.speed!).rounded()
                    mark1?.icon = UIImage(named: "driver")
                    mark1?.snippet = String(speed2) + " kmph"
                    mark1?.map = self.mapView
                }
                
                self.fecthStops()
                
            }
            
        }, withCancel: nil)
    
    }
    
    class shuttleDestinations: NSObject {
        var name: String
        var location: CLLocationCoordinate2D
        var zoom: Float
        
        init(name: String, location: CLLocationCoordinate2D, zoom: Float) {
        
            self.name = name
            self.location = location
            self.zoom = zoom
        }
    }
    
    func next() {
        let longitude = stops[markerIndex].longitude
        let latitude = stops[markerIndex].latitude
        
        let position = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
        let marker = GMSMarker(position: position)
        marker.title = stops[markerIndex].stopName
        marker.map = self.mapView
        
        mapView?.animate(toLocation: position)
        mapView?.selectedMarker = marker
        
        if(markerIndex == (markers.count - 1)){
            markerIndex = 0
        }else{
            markerIndex = markerIndex + 1
            
            CATransaction.begin()
            CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            mapView?.animate(toLocation: position)
            CATransaction.commit()
        }
    }
}

