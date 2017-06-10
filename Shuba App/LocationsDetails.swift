//
//  locationsDetails.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 30/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//


import UIKit
import Firebase
import CoreLocation

class LocationsDetails: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    var markers:[MyMarker] = []
    
    var stop: Stop? {
        didSet {
            navigationItem.title = stop?.stopName
            fetchDrivers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "cellId")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return markers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! DetailsCell
        
        let driver = markers[indexPath.row].driver!
        let position = markers[indexPath.row].point!
        var duration = 0.0
        
        duration = markers[indexPath.row].time!
        
        if(duration > 0){
            duration = markers[indexPath.row].time!
            let duration_int = Double(duration.rounded())
            cell.subtitleTextView.text = String(duration_int) + " Minutes Away"
        }else{
            cell.subtitleTextView.text = " Bus is Stationary."
        }
        
        cell.textView.text  = driver.driverName
        cell.titleLabel.text = String(position.rounded()) + " Meters Away"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func fetchDrivers() {
        
        FIRDatabase.database().reference().child("buses").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let driver = Driver()
                driver.setValuesForKeys(dictionary)
                
                let driverCoordinates = CLLocation(latitude: driver.latitude as! CLLocationDegrees, longitude: driver.longitude as! CLLocationDegrees)
                let new = CLLocation(latitude: self.stop?.latitude as! CLLocationDegrees, longitude: self.stop?.longitude as! CLLocationDegrees )
                let distances: CLLocationDistance = driverCoordinates.distance(from: new)
                
                let myMarker : MyMarker = MyMarker()
                myMarker.key = snapshot.key
                myMarker.driver = driver
                
                if driver.speed == 0 {
                    myMarker.time = 0
                } else {
                    let result: Double = (((Double(distances.rounded())) / 1000) / ((Double(driver.speed!)) / 60))
                    myMarker.time = result
                }
                
                
                myMarker.point = distances
                self.markers.append(myMarker )
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("buses").observe(.childChanged, with: { (snapshot) in
            
            print("Child Changed")
            
            if let dictionary = snapshot.value as?[String: AnyObject] {
                let driver = Driver()
                driver.setValuesForKeys(dictionary)
                
                for i in 0 ..< self.markers.count {
                    
                    if(self.markers[i].key?.contains(snapshot.key))!{
                        
                        self.markers[i].driver?.setValuesForKeys(dictionary)
                        print(self.markers[i].driver!.driverName! + "\(self.markers[i].driver!.speed!)")
                        
                        let driverCoordinates = CLLocation(latitude: self.markers[i].driver!.latitude as! CLLocationDegrees, longitude: self.markers[i].driver!.longitude as! CLLocationDegrees)
                        let new = CLLocation(latitude: self.stop?.latitude as! CLLocationDegrees, longitude: self.stop?.longitude as! CLLocationDegrees )
                        let distances: CLLocationDistance = driverCoordinates.distance(from: new)
                        
                        
                        if driver.speed == 0 {
                            self.markers[i].time = 0
                        } else {
                            let result: Double = (((Double(distances.rounded())) / 1000) / ((Double(driver.speed!)) / 60))
                            self.markers[i].time = result
                        }
                        
                        self.markers[i].point = distances
                        
                    }
                }
            }
            
            DispatchQueue.main.async {
                print("refreshes")
                self.collectionView!.reloadData()
            }
        }, withCancel: nil)
        
    }
    
    
}












