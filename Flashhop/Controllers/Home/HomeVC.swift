//
//  HomeVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/15.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SDWebImage

class HomeVC: UIViewController {

    let locationManager = CLLocationManager()
    var bFirstLocation = false    // for mapview center at first time
    var current_location: CLLocationCoordinate2D?
    public var bMoveCenter = false
    public var center_location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var events:[Event] = []
    var users:[FUser] = []
    
    @IBOutlet weak var btnPhoto: PhotoButton!
    @IBOutlet weak var btnViewEvent: UIButton!
    @IBOutlet weak var ivBgForNewEventAndFilter: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnPinMyLocation: UIButton!
    @IBOutlet weak var btnMyLocation: UIButton!
    
    @IBOutlet weak var vPin: UIView!
    @IBOutlet weak var constraintPinViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var predictions:[GMSAutocompletePrediction] = []    // for auto complete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //makeShadowView(photoImg)
        makeShadowView(btnViewEvent)
        makeShadowView(ivBgForNewEventAndFilter)
        makeShadowView(btnMyLocation)
        makeShadowView(btnPinMyLocation)
        
        askLocationPermission()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.animate(toZoom: 12)
        mapView.isMyLocationEnabled = true
//        let insets = UIEdgeInsets(top: 0, left: 0, bottom: -100, right: 0)
//        mapView.padding = insets
        
        // map style
        do {
            if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        // upload my location,
        var dur:TimeInterval = 1800
        if DEBUG_MODE { dur = 60 }
        _ = Timer.scheduledTimer(timeInterval: dur, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
        
        // hide pin view at first
        vPin.isHidden = true
        constraintPinViewHeight.constant = 0
        self.view.layoutSubviews()
        
        if me.photo_url != "" { btnPhoto.sd_setImage(with: URL(string: me.photo_url), for: .normal, completed: nil) }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUsersAndEvents()
        if bMoveCenter == true {
            mapView.animate(toLocation: center_location)
            bMoveCenter = false
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    func askLocationPermission() {
        // ask location permission
        let status = CLLocationManager.authorizationStatus()
        switch status {
        // 1
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied, .restricted:
            let alert = UIAlertController(title: "", message: "Enable locations in Flashhop to activate more functions", preferredStyle: .alert)
            let enableAction = UIAlertAction(title: "Enable", style: .default) { (action) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            let skipAction = UIAlertAction(title: "Skip", style: .default, handler: nil)
            alert.addAction(enableAction)
            alert.addAction(skipAction)
            
            present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            print("unknown location auth status")
        }
    }
    @IBAction func onProfile(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.user = me
        vc.status = .SHOW
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onEventList(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventListVC") as! EventListVC
        vc.events = self.events
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onNewEvent(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
        vc.status = .HOST
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onFilter(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.filter_changed = {
            self.loadUsersAndEvents()
        }
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    @IBAction func onPinMyLocation(_ sender: UIButton) {
        if vPin.isHidden {  // pin my location
            vPin.isHidden = false
            constraintPinViewHeight.constant = self.view.frame.height / 2
            
            /*vPin.clipsToBounds = false
            vPin.layer.shadowColor = UIColor.darkGray.cgColor
            vPin.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
            vPin.layer.shadowRadius = 8
            vPin.layer.shadowOpacity = 0.5
            vPin.layer.masksToBounds = true*/
            
            self.view.layoutSubviews()
            
            sender.setImage(UIImage(named: "drop_the_pin"), for: .normal)
        }else{  // drop the pin
            self.view.endEditing(true)
            vPin.isHidden = true
            constraintPinViewHeight.constant = 0
            self.view.layoutSubviews()
            
            sender.setImage(UIImage(named: "pin_my_location"), for: .normal)
        }
        //makeShadowView(sender)
    }
    @IBAction func onMyLocation(_ sender: Any) {
        if let location = self.current_location {
            mapView.animate(toLocation: location)
        }
    }
    func loadUsersAndEvents() {
        self.mapView.clear()
        
        APIManager.filterEvents(result: { (value) in
            let alldic = value["data"] as! [String:AnyObject]
            let usersDic = alldic["users"] as! [[String:AnyObject]]
            let eventDic = alldic["events"] as! [[String:AnyObject]]
            
            self.users = []
            for dic in usersDic {
                let user = FUser(dic:dic)
                var dur:Double = 3600; if DEBUG_MODE { dur = 3600*24 }
                if user.hide_my_location == false && Date().timeIntervalSince1970 < user.location_updated_at + dur {
                    self.users.append(user)
                }
            }
            
            self.events = []
            for dic in eventDic {
                let event = Event(dic: dic)
                self.events.append(event)
            }
            
            self.refresh()
        }) { (error) in
            print(error)
        }
    }
    func refresh() {
        self.mapView.clear()
        btnViewEvent.isHidden = me.filter.option != .event
        
        self.showUsers()
        self.showEvents()
        self.showPin()
    }
    func showUsers() {
        for user in users {
            let view = user.viewForPhotoOnMap()
            
            let position = CLLocationCoordinate2D(latitude: user.lat, longitude: user.lng)
            let marker = GMSMarker(position: position)
            marker.userData = user
            marker.iconView = view
            marker.map = mapView
        }
    }
    func showEvents() {
        let icon = UIImage(named: "marker_event")
        for event in events {
            let position = CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng)
            let marker = GMSMarker(position: position)
            //marker.title = "event"
            marker.icon = icon
            marker.userData = event
            marker.map = mapView
        }
    }
    func showPin() {
        let diff = (Date().timeIntervalSince1970 - me.location_updated_at)
        if me.lat != 0 && me.lng != 0 && diff < 3601 {
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: me.lat, longitude: me.lng))
            marker.icon = UIImage(named: "pin")
            marker.map = mapView
        }
    }
    @objc func updateLocation() {
        if let current_location = current_location {
            APIManager.updateUserLocation(lat: current_location.latitude, lng: current_location.longitude, result: { (value) in
            }) { (error) in
                print(error)
            }
        }
    }
    /*func can_be_friend(_ user:FUser)->Bool {
        for event in events {
            let a = event.is_creator(me) || event.is_member(me)
            let b = event.is_creator(user) || event.is_member(user)
            if a && b { return true }
        }
        return false
    }*/
    func onClickedUser(_ user: FUser) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.user = user
        vc.status = .INVITE
        for event in events { if event.is_creator(me) { vc.my_events.append(event)} }
        
        // from bottom to top
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        transition.type = .moveIn
        transition.subtype = .fromTop
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func onClickedEvent(_ event: Event) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = event
        
        // from bottom to top
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        transition.type = .moveIn
        transition.subtype = .fromTop
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            current_location = location
            if DEBUG_MODE {
                current_location?.latitude = Double.random(in: -89...89); current_location?.longitude = Double.random(in: -179...179)
                me.lat = current_location?.latitude ?? 0
                me.lng = current_location?.longitude ?? 0
            }
            
            if bFirstLocation == false {
                mapView.animate(toLocation: location)
                
                updateLocation()
                bFirstLocation = true
            }
        }
    }
}
extension HomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.icon != nil {
            if let event = marker.userData as? Event { // event clicked
                onClickedEvent(event)
            }
        }
        if marker.iconView != nil {
            if let user = marker.userData as? FUser { // user clicked
                onClickedUser(user)
            }
        }
        
        return false
    }
}
extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            let token = GMSAutocompleteSessionToken.init()
            let filter = GMSAutocompleteFilter()
            filter.type = .noFilter
            var bounds:GMSCoordinateBounds?
            if !DEBUG_MODE {
                let initialLocation = CLLocationCoordinate2D(latitude: me.lat+1, longitude: me.lng+1)
                let otherLocation = CLLocationCoordinate2D(latitude: me.lat-1, longitude: me.lng-1)
                bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
            }
            GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: searchText, bounds: bounds, boundsMode: .bias, filter: filter, sessionToken: token, callback: { (results, error) in
                if let error = error {
                    print("Autocomplete error: \(error)")
                    return
                }
                if let results = results {
                    self.predictions = results
                    self.tableView.reloadData()
                }
            })
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Current Location")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Current Location")
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "Address")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Address")
            }
            
            let lbTitle = cell.viewWithTag(10) as! UILabel
            let lbDetail = cell.viewWithTag(20) as! UILabel
            
            lbTitle.text = predictions[indexPath.row - 1].attributedPrimaryText.string
            lbDetail.text = predictions[indexPath.row - 1].attributedFullText.string
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // current location
            if let location = current_location {
                APIManager.getAddress(lat: location.latitude, lng: location.longitude) { (address) in
                    APIManager.pinLocation(address: address, lat: location.latitude, lng: location.longitude)
                    me.location_updated_at = Date().timeIntervalSince1970
                    self.refresh()
                    self.mapView.animate(toLocation: location)
                }
            }
        }else{
            let prediction = predictions[indexPath.row - 1]
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
            let token = GMSAutocompleteSessionToken.init()
            GMSPlacesClient.shared().fetchPlace(fromPlaceID: prediction.placeID, placeFields: fields, sessionToken: token, callback: { (place: GMSPlace?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    APIManager.pinLocation(address: prediction.attributedFullText.string, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
                    me.location_updated_at = Date().timeIntervalSince1970
                    self.refresh()
                    self.mapView.animate(toLocation: place.coordinate)
                }
            })
        }
    }
}
