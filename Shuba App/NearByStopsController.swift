//
//  NearByStopsController.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 22/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class NearByStopsController: UITableViewController {
    
    let cellId = "cellId"
    
    var stops = [Stop]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Nearby-Stops"
        
        tableView.register(StopCell.self, forCellReuseIdentifier: cellId)
        
        loadStops()
    }
    
    func loadStops() {
        FIRDatabase.database().reference().child("stops").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let stop = Stop()
                stop.setValuesForKeys(dictionary)
                self.stops.append(stop)
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }

            
        }, withCancel: nil)
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let stop = stops[indexPath.row]
        
        cell.textLabel?.text = stop.stopName
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = self.stops[indexPath.row]
        self.showLocationsDetailsForStop(stop: stop)
    }
    
    func showLocationsDetailsForStop(stop:Stop) {
        let locationsDetails = LocationsDetails(collectionViewLayout: UICollectionViewFlowLayout())
        locationsDetails.stop = stop
        navigationController?.pushViewController(locationsDetails, animated: true)
        
    }
}

class StopCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: ((textLabel?.frame.origin.y)! - 2), width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
    }
    
    let busLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "shuba")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(busLogo)
        
        //io9 constraint anchors
        //need x,y, height and width anchors
        busLogo.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        busLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        busLogo.widthAnchor.constraint(equalToConstant: 40).isActive = true
        busLogo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
