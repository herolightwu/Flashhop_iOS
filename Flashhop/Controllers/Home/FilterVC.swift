//
//  FilterVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/30.
//

import UIKit
import RangeSeekSlider

class FilterVC: UIViewController {
    public var filter_changed:(()->Void)?

    @IBOutlet weak var vBg: UIView!
    @IBOutlet weak var btnViewAll: ColorCheckBox!
    @IBOutlet weak var btnPeopleOnly: ColorCheckBox!
    @IBOutlet weak var btnEventsOnly: ColorCheckBox!
    
    @IBOutlet weak var viewPeople: UIView!
    @IBOutlet weak var viewEvent: UIView!
    @IBOutlet weak var constraintPeopleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintEventViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var consViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sliderAge: RangeSeekSlider!
    @IBOutlet weak var btnMale: ColorCheckBox!
    @IBOutlet weak var btnFemale: ColorCheckBox!
    
    @IBOutlet weak var btnReset: RoundButton!
    @IBOutlet weak var btnSave: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Popup
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        // min, max age
        sliderAge.minValue = CGFloat(Event.MIN_AGE)
        sliderAge.maxValue = CGFloat(Event.MAX_AGE)
        sliderAge.maxLabelColor = UIColor.gray
        sliderAge.minLabelColor = UIColor.gray
        
        makeShadowView(btnReset)
        makeShadowView(btnSave)
        
        //let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClose))
        //self.view.addGestureRecognizer(gesture)
        
        // selected date
        if me.filter.event_date.count != 0 {
            let start = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            for date in me.filter.event_date {
                let day_offset = Calendar.current.dateComponents([.day], from: start, to: date).day!
                let btn = self.viewPeople.viewWithTag(100)?.viewWithTag(day_offset*10) as! ColorCheckBox
                btn.isChecked = true
            }
        }
        
        // category
        for interest in Interest.allCases {
            let button = viewPeople.viewWithTag(interest.rawValue+200) as! ColorCheckBox
            button.isChecked = me.filter.event_category[interest] ?? true
        }
        
        sliderAge.minValue = me.filter.min_age
        sliderAge.maxValue = me.filter.max_age
        
        if me.filter.gender == .male { btnMale.isChecked = true }
        if me.filter.gender == .female { btnFemale.isChecked = true }
        if me.filter.gender == .co { btnMale.isChecked = true; btnFemale.isChecked = true }
        
        refreshDateButtons()
        
        switch me.filter.option {
        case .both:
            onViewAll(btnViewAll)
        case .people:
            onPeopleOnly(btnPeopleOnly)
        case .event:
            onEventsOnly(btnEventsOnly)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @objc func onClose(sender : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onViewAll(_ sender: ColorCheckBox) {
        btnViewAll.isChecked = true
        btnPeopleOnly.isChecked = false
        btnEventsOnly.isChecked = false
        
        constraintPeopleViewHeight.constant = 230
        constraintEventViewHeight.constant = 100
        consViewHeight.constant = 500
        viewPeople.isHidden = false
        viewEvent.isHidden = false
        self.view.layoutSubviews()
    }
    @IBAction func onPeopleOnly(_ sender: ColorCheckBox) {
        btnViewAll.isChecked = false
        btnPeopleOnly.isChecked = true
        btnEventsOnly.isChecked = false
        
        constraintPeopleViewHeight.constant = 0
        constraintEventViewHeight.constant = 100
        consViewHeight.constant = 270
        viewPeople.isHidden = true
        viewEvent.isHidden = false
        self.view.layoutSubviews()
    }
    @IBAction func onEventsOnly(_ sender: ColorCheckBox) {
        btnViewAll.isChecked = false
        btnPeopleOnly.isChecked = false
        btnEventsOnly.isChecked = true        
        
        constraintPeopleViewHeight.constant = 230
        constraintEventViewHeight.constant = 0
        consViewHeight.constant = 400
        viewPeople.isHidden = false
        viewEvent.isHidden = true
        self.view.layoutSubviews()
    }
    @IBAction func onClickDate(_ sender: ColorCheckBox) {
        // only one available
        /*if sender.isChecked {
            for tag in stride(from: 0, to: 61, by: 10) {
                if sender.tag != tag {
                    let btn = self.viewPeople.viewWithTag(100)?.viewWithTag(tag) as! ColorCheckBox
                    btn.isChecked = false
                }
            }
        }else{
            sender.isChecked = true // can't uncheck
        }*/
        refreshDateButtons()
    }
    @IBAction func onClickMale(_ sender: ColorCheckBox) {
        //btnMale.isChecked = !btnMale.isChecked
    }
    @IBAction func onClickFemale(_ sender: ColorCheckBox) {
        //btnFemale.isChecked = !btnFemale.isChecked
    }
    func refreshDateButtons() {        
        for tag in stride(from: 0, to: 61, by: 10) {
            let btn = self.viewPeople.viewWithTag(100)?.viewWithTag(tag) as! ColorCheckBox
            let lbMon = self.viewPeople.viewWithTag(100)?.viewWithTag(tag+1) as? UILabel
            let lbDay = self.viewPeople.viewWithTag(100)?.viewWithTag(tag+2) as? UILabel
            let vLine = self.viewPeople.viewWithTag(100)?.viewWithTag(tag+3)
            let lbWeekday = self.viewPeople.viewWithTag(100)?.viewWithTag(tag+4) as? UILabel
            
            var color:UIColor
            if btn.isChecked { color = btn.unchecked_color }
            else { color = btn.checked_color }
            
            lbMon?.textColor = color
            lbDay?.textColor = color
            vLine?.backgroundColor = color
            lbWeekday?.textColor = color
            
            let day_offset = tag / 10
            let date = Calendar.current.date(byAdding: .day, value: day_offset, to: Date())!
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMM"
            lbMon?.text = formatter.string(from: date)
            
            formatter.dateFormat = "dd"
            lbDay?.text = formatter.string(from: date)
            
            formatter.dateFormat = "E"
            lbWeekday?.text = formatter.string(from: date)
        }
    }
    @IBAction func onReset(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        me.filter = Filter()
        filter_changed?()
    }
    @IBAction func onSave(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        // filter option
        if btnViewAll.isChecked { me.filter.option = .both }
        if btnPeopleOnly.isChecked { me.filter.option = .people }
        if btnEventsOnly.isChecked { me.filter.option = .event }
        
        // event date
        me.filter.event_date = []
        for tag in stride(from: 0, to: 61, by: 10) {
            let btn = self.viewPeople.viewWithTag(100)?.viewWithTag(tag) as! ColorCheckBox
            if btn.isChecked {
                let offset = tag / 10
                let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                me.filter.event_date.append(date)
            }
        }
        
        // event categories
        for i in Interest.allCases {
            let button = viewPeople.viewWithTag(i.rawValue+200) as! ColorCheckBox
            me.filter.event_category[i] = button.isChecked
        }
        
        // min, max age
        me.filter.min_age = sliderAge.minValue
        me.filter.max_age = sliderAge.maxValue
        
        // gender
        if btnMale.isChecked { me.filter.gender = .male }
        if btnFemale.isChecked { me.filter.gender = .female }
        if btnFemale.isChecked && btnMale.isChecked { me.filter.gender = .co }
        
        if me.filter.event_date.count == 0 {
            btnSave.shake()
            return
        }
        
        filter_changed?()
    }
}
