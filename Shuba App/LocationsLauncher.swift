//
//  LocationsLauncher.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 18/06/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class LocationsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var loctionManager = CLLocationManager()

    var stops = [Stop]()
    
    var near = [Double]()
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    func showLocations() {
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(7) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
            
        }
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LocationsCell
        
        let stopname = stops[indexPath.item]
        let stopPoint = stopname.stopName
       
        cell.nameLabel.text = stopPoint
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 
    }
    
    func fecthStops() {
        
        FIRDatabase.database().reference().child("stops").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let stop = Stop()
                stop.setValuesForKeys(dictionary)
                self.stops.append(stop)
                
                
                
                let stopCordinates = CLLocation(latitude: stop.latitude as! CLLocationDegrees, longitude: stop.longitude as! CLLocationDegrees)
                
                let userPosition = self.loctionManager.location
                
                
               let distances: CLLocationDistance = stopCordinates.distance(from: userPosition!)
               self.near.append(distances)
                print(self.near)
                
            }
            
        }, withCancel: nil)
    }
    var loginController: LoginController?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let stopname = stops[indexPath.item]
        let stopPoint = stopname.stopName
        let coordinate = CLLocation(latitude: stopname.latitude as! CLLocationDegrees, longitude: stopname.longitude as! CLLocationDegrees)
        let userPosition = self.loctionManager.location
    
        
        let distances: CLLocationDistance = coordinate.distance(from: userPosition!)
        print(stopPoint!)
        print(distances)
        if distances <= 100 {
            print("this is my life")
//            self.display()
        } else {
            print("i said it")
        }
    }

    func display() {
        self.loginController?.saveNotice(userMessage: "i am alive")
    }
    
    override init() {
        super.init()
        
        fecthStops()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(LocationsCell.self, forCellWithReuseIdentifier: cellId)
    }
}
