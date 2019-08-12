//
//  HoppersVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/28.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SDWebImage

class HoppersVC: UIViewController {

    public var event:Event!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnMyLocation: UIButton!
    @IBOutlet weak var btnGroupChat: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeShadowView(btnMyLocation)
        makeShadowView(btnGroupChat)
        mapView.animate(toZoom: 12)
        
        // map style
        do {
            if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        showUsers()
        onMyLocation(btnMyLocation)
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onGroupChat(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupChatVC") as! GroupChatVC
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onMyLocation(_ sender: UIButton) {
        let location = CLLocation(latitude: event.lat, longitude: event.lng)
        mapView.animate(toLocation: location.coordinate)
    }
    func showUsers() {
        for user in event.members_and_creator() {
            let view = user.viewForPhotoOnMap()
            
            let position = CLLocationCoordinate2D(latitude: user.lat, longitude: user.lng)
            let marker = GMSMarker(position: position)
            marker.userData = user
            marker.iconView = view
            marker.map = mapView
        }
    }
}
