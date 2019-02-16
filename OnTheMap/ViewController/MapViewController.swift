//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ahmed Alsamani on 01/01/2019.
//  Copyright © 2019 Ahmed Alsamani. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var StudentLocations : [StudentLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getStudentsLocations()
    }
    
    func getStudentsLocations(){
        StudentLocations.removeAll()
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        activityIndicator.startAnimating()
        
        API.shared.getStudentsLocations { (locations) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                guard (locations != nil) else {
                    Alert1Action (VC:self,title: "Error loading locations!", message: "")
                    return
                }
                
                let locations2 =  locations! as StudentLocationResult
                self.StudentLocations =  locations2.results!
                var annotations = [MKPointAnnotation] ()
                
                //Loop through the array of structs and get locations data from it so they can be displayed on the map
                for locationStruct in self.StudentLocations {
                    
                    let long = CLLocationDegrees (locationStruct.longitude ?? 0)
                    let lat = CLLocationDegrees (locationStruct.latitude ?? 0)
                    
                    let coords = CLLocationCoordinate2D (latitude: lat, longitude: long)
                    let mediaURL = locationStruct.mediaURL ?? " "
                    let first = locationStruct.firstName ?? " "
                    let last = locationStruct.lastName ?? " "
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coords
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append (annotation)
                }
                self.mapView.addAnnotations (annotations)
            }
        }
    }
    
 
    

    @IBAction func addLocation(_ sender: Any) {
        AddLocation(self)
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        getStudentsLocations()
    }
    
    @IBAction func logout(_ sender: Any) {
        Logout(self)
    }
    
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let view = view as? MKPinAnnotationView {
            view.pinTintColor = UIColor.green
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

