//
//  EditEventVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/30.
//

import UIKit
import iOSDropDown
import RangeSeekSlider
import CoreLocation
import SearchTextField
import GooglePlaces
import IQKeyboardManager

class EditEventVC: UIViewController {
    
    enum Status { case HOST, EDIT }
    public var status: Status = .HOST
    public var event = Event()
    public var bCustomImage = false

    @IBOutlet weak var lbVCTitle: UILabel!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var vTitleUnderline: UIView!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var vDateUnderline: UIView!
    @IBOutlet weak var tfTime: UITextField!
    @IBOutlet weak var vTimeUnderline: UIView!
    @IBOutlet weak var tfAddress: SearchTextField!
    @IBOutlet weak var vAddressUnderline: UIView!
    @IBOutlet weak var sliderPeople: RangeSeekSlider!
    @IBOutlet weak var lbPeople: UILabel!
    @IBOutlet weak var sliderAge: RangeSeekSlider!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var ddCategory: DropDown!
    @IBOutlet weak var ivCoverPhoto: UIImageView!
    @IBOutlet weak var btnChangeCoverPhoto: RoundButton!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var ddCurrency: DropDown!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var tvDesc: UITextView!
    @IBOutlet weak var btnGenderCo: ImageCheckBox!
    @IBOutlet weak var btnMaleOnly: ImageCheckBox!
    @IBOutlet weak var btnFemaleOnly: ImageCheckBox!
    @IBOutlet weak var btnPrivate: ImageCheckBox!
    @IBOutlet weak var btnAllowInvite: ImageCheckBox!
    @IBOutlet weak var chkPayLater: ImageCheckBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /////////////////////////////////////////////////////////////////////////////////////////
        address_auto_complete_init()
        chkPayLater.isHidden = true
        
        tfPrice.addTarget(self, action: #selector(onChangePrice), for: .editingChanged)
        
        sliderAge.minValue = CGFloat(Event.MIN_AGE)
        sliderAge.maxValue = CGFloat(Event.MAX_AGE)
        
        ddCategory.placeholder = "Category"
        ddCategory.optionArray = []
        for i in Interest.allCases { ddCategory.optionArray.append(i.str.capitalizingFirstLetter()) }
        ddCategory.didSelect { (text, index, id) in
            let i = Interest(rawValue: index) ?? .party
            self.onChangedCategory(i)
        }
        
        ddCurrency.optionArray = []
        for c in Currency.allCases { ddCurrency.optionArray.append(c.str) }

        tvDesc.layer.borderWidth = 1
        tvDesc.layer.cornerRadius = 2
        tvDesc.layer.borderColor = UIColor.gray.cgColor
        
        sliderPeople.delegate = self
        sliderAge.delegate = self
        
        //////////////////////////////////////////////////////////////////////////////////////////
        switch status {
        case .HOST:
            lbVCTitle.text = "Host an Event"
            //event.lat = me.lat
            //event.lng = me.lng
            //self.tfAddress.text = me.address
        case .EDIT:
            lbVCTitle.text = "Edit Event"
            tfAddress.text = event.address
            if event.price != 0 { tfPrice.text = "\(event.price)" }
        }
        tfTitle.text = event.title
        tfDate.text = event.date_str
        tfTime.text = event.start_end()
        sliderPeople.selectedMinValue = CGFloat(event.min_members)
        sliderPeople.selectedMaxValue = CGFloat(event.max_members)
        lbPeople.text = "\(event.min_members)-\(event.max_members)"
        sliderAge.selectedMinValue = CGFloat(event.min_age)
        sliderAge.selectedMaxValue = CGFloat(event.max_age)
        lbAge.text = "\(event.min_age)-\(event.max_age)"
        ddCategory.text = event.category.str.capitalizingFirstLetter()
        if event.cover_photo == "" { onChangedCategory(event.category) }
        else { ivCoverPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        ddCurrency.text = event.currency.str
        tvDesc.text = event.desc
        
        chkPayLater.isHidden = event.price == 0
        chkPayLater.isChecked = event.is_pay_later > 0
        btnAllowInvite.isChecked = event.allow_invite
        btnPrivate.isChecked = event.is_private
        
        checkDebit()
    }
    
    func checkDebit() {
        APIManager.getDebitCheck(user_id: me.id, callback: { cards in
            if cards.count > 0 {
                me.is_debit = 1
            } else {
                me.is_debit = 0
            }
        })
    }
    
    @objc func onChangePrice() {
        chkPayLater.isHidden = (tfPrice.text ?? "0").toDouble() == 0
    }
    
    var predictions:[GMSAutocompletePrediction] = []    // for auto complete
    func address_auto_complete_init() {
        tfAddress.theme.bgColor = .white
        tfAddress.theme.font = UIFont(name: "SourceSansPro-Regular", size: 14)!
        tfAddress.theme.fontColor = .dark
        tfAddress.theme.subtitleFontColor = .dark
        tfAddress.theme.cellHeight = 40
        tfAddress.userStoppedTypingHandler = {
            if let criteria = self.tfAddress.text {
                if criteria.count > 1 {
                    let token = GMSAutocompleteSessionToken.init()
                    let filter = GMSAutocompleteFilter()
                    filter.type = .noFilter
                    var bounds:GMSCoordinateBounds?
                    if !DEBUG_MODE {
                        let initialLocation = CLLocationCoordinate2D(latitude: me.lat+1, longitude: me.lng+1)
                        let otherLocation = CLLocationCoordinate2D(latitude: me.lat-1, longitude: me.lng-1)
                        bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
                    }
                    GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: criteria, bounds: bounds, boundsMode: .bias, filter: filter, sessionToken: token, callback: { (results, error) in
                        if let error = error {
                            print("Autocomplete error: \(error)")
                            return
                        }
                        if let results = results {
                            self.predictions = results
                            var items:[SearchTextFieldItem] = []
                            for p in self.predictions {
                                items.append(SearchTextFieldItem(title: p.attributedPrimaryText.string, subtitle: p.attributedFullText.string))
                            }
                            self.tfAddress.filterItems(items)
                        }
                    })
                }
            }
        }
        tfAddress.itemSelectionHandler = { results, index in
            self.tfAddress.text = results[index].subtitle
            self.event.address = results[index].subtitle ?? ""
            
            let prediction = self.predictions[index]
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
            let token = GMSAutocompleteSessionToken.init()
            GMSPlacesClient.shared().fetchPlace(fromPlaceID: prediction.placeID, placeFields: fields, sessionToken: token, callback: { (place: GMSPlace?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    self.event.lat = place.coordinate.latitude
                    self.event.lng = place.coordinate.longitude
                }
            })
        }
    }
    func onChangedCategory(_ i: Interest) {
        self.ivCoverPhoto.image = i.cover_image
        self.bCustomImage = false
    }
    @IBAction func onBack(_ sender: Any) {
        updateEvent()
        if validateEvent() && self.event.db_id == 0 && self.event.id == 0 {
            AlertVC.showMessage(parent: self.navigationController?.parent, text: "You haven't saved this event yet. You will lose all the content created if you go back.", action1_title: "Give Up", action2_title: "Save as Draft", action1: {
                self.navigationController?.popViewController(animated: true)
            }, action2:
            {
                self.event.saveAsDraft()
            });
        } else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        if sender == tfTitle {
            // no error
            tfTitle.textColor = .dark
            tfTitle.text = ""
            vTitleUnderline.backgroundColor = .lightGray
        }
        if sender == tfDate {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.date =  event.time()
            sender.inputView = picker
            picker.addTarget(self, action: #selector(onChangedDate(sender:)), for: .valueChanged)
            
            // no error
            tfDate.textColor = .dark
            tfDate.text = ""
            vDateUnderline.backgroundColor = .lightGray
        }
        if sender == tfTime {
            let picker = UIDatePicker()
            picker.datePickerMode = .time
            picker.date = event.time()
            sender.inputView = picker
            picker.addTarget(self, action: #selector(onChangedTime(sender:)), for: .valueChanged)
            
            // no error
            tfTime.textColor = .dark
            tfTime.text = ""
            vTimeUnderline.backgroundColor = .lightGray
        }
        if sender == tfAddress {
            IQKeyboardManager.shared().shouldResignOnTouchOutside = false
            
            // no error
            tfAddress.textColor = .dark
            tfAddress.text = ""
            vAddressUnderline.backgroundColor = .lightGray
        }
    }
    @IBAction func onEditingDidEnd(_ sender: UITextField) {
        if sender == tfTime && event.time_str != "" {
            AlertVC.chooseEventDuration(parent: self.navigationController?.parent) { (dur) in
                if dur != 0 {
                    self.view.endEditing(true)
                    self.event.set_duration(dur)
                    self.tfTime.text = self.event.start_end()
                }
            }
        }
        if sender == tfAddress {
            IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        }
    }
    @objc func onChangedDate(sender: UIDatePicker) {
        event.set_date(sender.date)
        tfDate.text = event.date_str
    }
    @objc func onChangedTime(sender: UIDatePicker) {
        event.set_time(sender.date)
        tfTime.text = event.time_str
    }
    @IBAction func onChangeCoverPhoto(_ sender: RoundButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChoosePhotosVC") as! ChoosePhotosVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.max_count = 1
        vc.callback = { result in
            if result.count == 1 {
                self.ivCoverPhoto.image = getImage(asset: result[0])
                self.bCustomImage = true
            }
        }
    }
    @IBAction func onChangedGender(_ sender: ImageCheckBox) {
        if sender == btnGenderCo { event.gender = .co }
        if sender == btnMaleOnly { event.gender = .male }
        if sender == btnFemaleOnly { event.gender = .female }
        
        switch event.gender {
        case .co:
            btnMaleOnly.isChecked = false
            btnFemaleOnly.isChecked = false
        case .male:
            btnGenderCo.isChecked = false
            btnFemaleOnly.isChecked = false
        case .female:
            btnGenderCo.isChecked = false
            btnMaleOnly.isChecked = false
        }
    }
    func updateEvent() {
        event.title = tfTitle.text ?? ""
        event.address = tfAddress.text ?? ""
        event.min_members = Int(sliderPeople.selectedMinValue)
        event.max_members = Int(sliderPeople.selectedMaxValue)
        event.min_age = Int(sliderAge.selectedMinValue)
        event.max_age = Int(sliderAge.selectedMaxValue)
        event.category = Interest(rawValue: ddCategory.selectedIndex ?? 0) ?? .party
        event.price = (tfPrice.text ?? "0").toDouble()
        event.currency = Currency(rawValue: ddCurrency.selectedIndex ?? 0) ?? .CAD
        event.desc = tvDesc.text
        event.is_private = btnPrivate.isChecked
        event.allow_invite = btnAllowInvite.isChecked
        event.is_pay_later = chkPayLater.isChecked ? 1 : 0
        ////////////////////////////////// error value /////////////////////////////////////
        if tfTitle.textColor!.isEqual(UIColor.error) {
            event.title = ""
        }
        if tvDesc.textColor!.isEqual(UIColor.error) {
            event.desc = ""
        }
    }
    func validateEvent() -> Bool {
        var flag = true
        
        /////////////////////////////////// error process ///////////////////////////
        if event.title == "" {
            tfTitle.textColor = .error
            tfTitle.text = "* Title"
            vTitleUnderline.backgroundColor = .error
            flag = false
        }
        if event.date_str == "" {
            tfDate.textColor = .error
            tfDate.text = "* Pick a date"
            vDateUnderline.backgroundColor = .error
            flag = false
        }
        if event.time_str == "" {
            tfTime.textColor = .error
            tfTime.text = "* Pick a time"
            vTimeUnderline.backgroundColor = .error
            flag = false
        }
        if event.address == "" {
            tfAddress.textColor = .error
            tfAddress.text = "* Pick a address"
            vAddressUnderline.backgroundColor = .error
            flag = false
        }
        if event.desc == "" {
            tvDesc.textColor = .error
            tvDesc.text = "* Description"
            tvDesc.layer.borderColor = UIColor.error.cgColor
            lbDesc.textColor = .error
            flag = false
        }
        return flag
    }
    @IBAction func onSave(_ sender: RoundButton) {
        updateEvent()
        if validateEvent() {
            if self.event.id == 0 {
                self.event.saveAsDraft()
            }
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            sender.shake()
        }
        
    }
    func showPaymentVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DebitVC") as! DebitVC
       vc.modalPresentationStyle = .overCurrentContext
       present(vc, animated: false, completion: nil)
    }
    @IBAction func onPublish(_ sender: RoundButton) {
        updateEvent()
        if event.price > 0 && me.is_debit == 0 {
            showPaymentVC()
            return
        }
        if !validateEvent() {
            sender.shake()
            return
        }
        
        switch status {
        case .HOST:
            if bCustomImage {
                APIManager.hostEvent(image: ivCoverPhoto.image!, event: event, result: { (value) in
                    let dic = value["data"] as! [String:AnyObject]
                    self.showEvent(event: Event(dic: dic))
                }) { (error) in
                    print(error)
                }
            }else{
                APIManager.hostEvent(event: event, result: { (value) in
                    let dic = value["data"] as! [String:AnyObject]
                    self.showEvent(event: Event(dic: dic))
                }) { (error) in
                    print(error)
                }
            }
        case .EDIT:
            if bCustomImage {
                APIManager.editEvent(image: ivCoverPhoto.image!, event: event, result: { (value) in
                    self.event.removeFromDraft()
                    self.navigationController?.popToRootViewController(animated: true)
                }) { (error) in
                    print(error)
                }
            }else{
                APIManager.editEvent(event: event, result: { (value) in
                    self.event.removeFromDraft()
                    self.navigationController?.popToRootViewController(animated: true)
                }) { (error) in
                    print(error)
                }
            }
        }
    }
    func showEvent(event: Event) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension EditEventVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 280
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        tvDesc.text = ""
        tvDesc.textColor = .dark
        tvDesc.layer.borderColor = UIColor.dark.cgColor
        lbDesc.textColor = .dark
    }
}

extension EditEventVC: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider == sliderPeople {
            lbPeople.text = "\(Int(minValue))-\(Int(maxValue))"
        }
        if slider == sliderAge {
            lbAge.text = "\(Int(minValue))-\(Int(maxValue))"
        }
    }
}
extension EditEventVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfAddress {
            self.view.endEditing(true)
        }
        return true
    }
}
