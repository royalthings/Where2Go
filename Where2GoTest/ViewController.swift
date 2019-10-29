//
//  ViewController.swift
//  Where2GoTest
//
//  Created by Дмитрий Ага on 10/21/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit
import MapKit
import WebKit

import YoutubePlayer_in_WKWebView

class ViewController: UIViewController {
   
   @IBOutlet weak var mapView: MKMapView!
   @IBOutlet weak var heightViewConstraints: NSLayoutConstraint!
   @IBOutlet weak var pullUpView: UIView!
   
   fileprivate let locationManager = CLLocationManager()
   fileprivate let autorizationStatus = CLLocationManager.authorizationStatus()
   fileprivate let regionRadius: Double = 500.0
   
   fileprivate var screenSize = UIScreen.main.bounds
   
   fileprivate var pullUpTitle: UILabel?
   fileprivate var pullUpDescription: UILabel?
   
   fileprivate var destLatitude: CLLocationDegrees?
   fileprivate var destLongitude: CLLocationDegrees?
   
   var pullUpWebView: WKYTPlayerView?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      locationManager.delegate = self
      pullUpView.backgroundColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
   }
   
   fileprivate func removePin() {
      for annotation in mapView.annotations {
         mapView.removeAnnotation(annotation)
      }
   }
   
   fileprivate func animateViewUp() {
      heightViewConstraints.constant = 300.0
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
   }
   
   fileprivate func addSwipe() {
      let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
      swipe.direction = .down
      pullUpView.addGestureRecognizer(swipe)
   }
   
   @objc func animateViewDown() {
      heightViewConstraints.constant = 0.0
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
   }

   @IBAction func goButtonAction(_ sender: Any) {
      removePin()
      animateViewUp()
      addSwipe()
      var latitude = CLLocationDegrees()
      var longitude = CLLocationDegrees()
      for element in Place.getRandomPlace() {
         let coordinateRegion = MKCoordinateRegion(center: element.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
         mapView.setRegion(coordinateRegion, animated: true)
         
         let place = Place(title: element.title, subtitle: element.subtitle, coordinate: element.coordinate, id: element.id)
         mapView.addAnnotation(place)
         
         guard let title = element.title else { return }
         guard let subtitle = element.subtitle else { return }
         guard let id = element.id else { return }
         
         latitude = element.coordinate.latitude
         longitude = element.coordinate.longitude
         
         removePullUpTitle()
         removePullUpDescription()
         removePullUpVideo()
         
         setPullUpTitle(text: title)
         setPullUpDescription(text: subtitle)
         
         addPullUpVideo(id: id)
         
      }
      destLatitude = latitude
      destLongitude = longitude
      mapView.overlays.forEach {
         if !($0 is MKUserLocation) {
            mapView.removeOverlay($0)
         }
      }
      
   }
   
   fileprivate func setPullUpTitle(text: String) {
      pullUpTitle = UILabel()
      pullUpTitle?.frame = CGRect(x: screenSize.width / 2 - 150, y: 10, width: 300, height: 50)
      pullUpTitle?.font = UIFont(name: "Avenir Next Bold", size: 15)
      pullUpTitle?.numberOfLines = 0
      pullUpTitle?.lineBreakMode = .byWordWrapping
      pullUpTitle?.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
      pullUpTitle?.textAlignment = .center
      pullUpTitle?.text = text
      pullUpView.addSubview(pullUpTitle!)
   }
   
   fileprivate func removePullUpTitle() {
      if pullUpTitle != nil {
         pullUpTitle?.removeFromSuperview()
      }
   }
   
   fileprivate func setPullUpDescription(text: String) {
      pullUpDescription = UILabel()
      pullUpDescription?.frame = CGRect(x: screenSize.width / 2 - 150, y: 40, width: 300, height: 50)
      pullUpDescription?.font = UIFont(name: "Avenir Next", size: 12)
      pullUpDescription?.numberOfLines = 0
      pullUpDescription?.lineBreakMode = .byWordWrapping
      pullUpDescription?.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
      pullUpDescription?.textAlignment = .center
      pullUpDescription?.text = text
      pullUpView.addSubview(pullUpDescription!)
   }
   
   fileprivate func removePullUpDescription() {
      if pullUpDescription != nil {
         pullUpDescription?.removeFromSuperview()
      }
   }
   
   fileprivate func addPullUpVideo(id: String) {
      
      pullUpWebView = WKYTPlayerView()
      pullUpWebView?.frame = CGRect(x: screenSize.width / 2 - 150, y: 90, width: 300, height: 150)
      pullUpWebView?.load(withVideoId: id)
      pullUpView.addSubview(pullUpWebView!)
      
   }
   
   fileprivate func removePullUpVideo() {
      if pullUpWebView != nil {
         pullUpWebView?.removeFromSuperview()
      }
   }

   @IBAction func centerMapButtonAction(_ sender: Any) {
      if autorizationStatus == .authorizedAlways || autorizationStatus == .authorizedWhenInUse {
         centerMapOnLocation()
      }
   }
}

extension ViewController: MKMapViewDelegate {
//   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//      if annotation is MKUserLocation {
//         return nil
//      } else {
//         let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
//         annotationView.image = UIImage(named: "iconsPin50")
//         return annotationView
//      }
//   }
   
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation {
         return nil
      }
      let identifire = "annotationView"
      var view: MKAnnotationView
      if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifire) {
         dequeuedView.image = UIImage(named: "iconsPin50")
         dequeuedView.annotation = annotation
         view = dequeuedView
      } else {
         view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifire)
         view.image = UIImage(named: "iconsPin50")
         view.canShowCallout = true
         view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
      }
      return view
   }
   
   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      animateViewUp()
      let sourceCoordinates = self.locationManager.location?.coordinate
      let destCoordinates = CLLocationCoordinate2DMake(destLatitude!, destLongitude!)
      let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
      let destPlacemark = MKPlacemark(coordinate: destCoordinates)
      let sourceItem = MKMapItem(placemark: sourcePlacemark)
      let destItem = MKMapItem(placemark: destPlacemark)
      let directionRequest = MKDirections.Request()
      directionRequest.source = sourceItem
      directionRequest.destination = destItem
      directionRequest.transportType = .automobile
      
      let directions = MKDirections(request: directionRequest)
      directions.calculate(completionHandler: { (response, error) in
         if error != nil {
            print("Something went wrong")
         }
         guard let response = response else {
            return
         }
         self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
               self.mapView.removeOverlay($0)
            }
         }
         let route = response.routes[0]
         self.mapView.addOverlay(route.polyline, level: .aboveRoads)
         
         let rekt = route.polyline.boundingMapRect
         self.mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
      })
      
   }
   
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .blue
      renderer.lineWidth = 2.0
      return renderer
   }
   
   
   //MARK: - center map on location
   func centerMapOnLocation() {
      if let location = locationManager.location?.coordinate {
         let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
         mapView.setRegion(coordinateRegion, animated: true)
      }
   }
}

extension ViewController: CLLocationManagerDelegate {
   
   // Handle authorization for the location manager.
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
      case .authorizedWhenInUse:
         mapView.showsUserLocation = true
         centerMapOnLocation()
         locationManager.startUpdatingLocation()
         print("Location status is OK.")
      case .denied:
         print("User denied access to location.")
         //TODO: - Show alert
         break
      case .notDetermined:
         locationManager.requestWhenInUseAuthorization()
         print("Location status not determined.")
      case .restricted:
         print("Location access was restricted.")
         //TODO: - Show alert
         break
      case .authorizedAlways:
         break
      }
   }
   
   // Handle location manager errors.
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager.stopUpdatingLocation()
      print("Error: \(error)")
   }
}

