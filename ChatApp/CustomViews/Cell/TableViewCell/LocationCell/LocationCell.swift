//
//  LocationCell.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell,MKMapViewDelegate {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var myMapView: MKMapView!
    
    let current_latitude = 23.022505 //Static Latitude and Longitude are set here
    let current_longitude = 72.5713621
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(customColor: 245, green: 245, blue: 245, alpha: 1)
        
        myMapView.mapType = MKMapType.standard //Setting type of map
         self.myMapView.delegate = self
        
        let newYorkLocation = CLLocationCoordinate2DMake(current_latitude, current_longitude)  //setting location
    
        // Drop a pin
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        dropPin.title = "Ahmedabad"
        myMapView.addAnnotation(dropPin) //setting pin to map
   
        var region : MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = current_latitude;
        region.center.longitude = current_longitude;
        myMapView.setRegion(region, animated: true) //Setting region
        
    }

    //MARK:- MapView Delegate
    //MARK:-
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "location") //setting pin image
        annotationView!.image = pinImage
        return annotationView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
