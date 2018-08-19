//
//  FilterViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import NHRangeSlider


class FilterViewController: UIViewController ,UITextFieldDelegate, LCItemPickerDelegate{

    var selectedButton: UIButton?
    var theDatePicker: UIDatePicker?
    var pickerToolbar: UIToolbar?
    var pickValue: Any?
    var pickerViewDate: UIAlertController?
    var slidePrice: NHRangeSliderView?
    var slideDistance: NHRangeSliderView?

    @IBOutlet weak var txtDateFrom: UITextField!
    @IBOutlet weak var btnLease: UIButton!
    @IBOutlet weak var btnBuilding: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var sldPriceView: UIView!
    @IBOutlet weak var sldDistanceView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false

        self.configureUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUserFilter() {
        loadUserInfo()
        slidePrice?.minimumValue = 0
        slidePrice?.maximumValue = 1000
        slidePrice?.lowerValue = 0
        slidePrice?.upperValue = 1000
        slideDistance?.minimumValue = 0
        slideDistance?.maximumValue = 20
        slideDistance?.lowerValue = 0
        slideDistance?.upperValue = 20
        if ((user?.uf_dateFrom) != "") {
            txtDateFrom.text = user?.uf_dateFrom
        }
        //    if (user.uf_dateTo) {
        //        [_txtDateTo setText:user.uf_dateTo];
        //    }
        if ((user?.uf_priceStart) != "") {
            slidePrice?.lowerValue = Double((user?.uf_priceStart)!)!
            slidePrice?.minimumValue = Double((user?.uf_priceStart)!)!
        }
        if ((user?.uf_priceEnd) != "") {
            slidePrice?.upperValue = Double((user?.uf_priceEnd)!)!
            slidePrice?.maximumValue = Double((user?.uf_priceEnd)!)!
        }
        if ((user?.uf_distanceStart) != "") {
            slideDistance?.lowerValue = Double((user?.uf_distanceStart)!)!
            slideDistance?.minimumValue = Double((user?.uf_distanceStart)!)!
        }
        if ((user?.uf_distanceEnd) != "") {
            slideDistance?.upperValue = Double((user?.uf_distanceEnd)!)!
            slideDistance?.maximumValue = Double((user?.uf_distanceEnd)!)!
        }
        if ((user?.uf_building) != "") {
            btnBuilding.setTitle(user?.uf_building, for: .normal)
        }
        if ((user?.uf_lease) != "") {
            btnLease.setTitle(user?.uf_lease, for: .normal)
        }
        if ((user?.uf_sort) != "") {
            btnSort.setTitle(user?.uf_sort, for: .normal)
        }
    }

    func configureUI() {
        slidePrice = NHRangeSliderView(frame: CGRect(x: 0, y: 0, width: self.sldPriceView.frame.size.width, height: self.sldPriceView.frame.size.height) )
        slidePrice?.trackHighlightTintColor = Utilities.greenColor
        slidePrice?.stepValue = 1
        slidePrice?.gapBetweenThumbs = 1
        slidePrice?.thumbLabelStyle = .FOLLOW


        slidePrice?.titleLabel?.text = ""
        slidePrice?.titleLabel?.textColor = Utilities.txtMainColor
        slidePrice?.lowerLabel?.textColor = Utilities.txtSubColor
        slidePrice?.upperLabel?.textColor = Utilities.txtSubColor
        slidePrice?.lowerDisplayStringFormat = "$%.0f"
        slidePrice?.upperDisplayStringFormat = "$%.0f"
        slidePrice?.sizeToFit()
        self.sldPriceView.addSubview(slidePrice!)

        slideDistance = NHRangeSliderView(frame: CGRect(x: 0, y: 0, width: self.sldPriceView.frame.size.width, height: self.sldPriceView.frame.size.height) )
        slideDistance?.trackHighlightTintColor = Utilities.greenColor
        slideDistance?.stepValue = 1
        slideDistance?.gapBetweenThumbs = 1

        slideDistance?.thumbLabelStyle = .FOLLOW

        slideDistance?.titleLabel?.text = ""
        slideDistance?.lowerDisplayStringFormat = "%.0f miles"
        slideDistance?.upperDisplayStringFormat = "%.0f miles"
        slideDistance?.titleLabel?.textColor = Utilities.txtMainColor
        slideDistance?.lowerLabel?.textColor = Utilities.txtSubColor
        slideDistance?.upperLabel?.textColor = Utilities.txtSubColor

        slideDistance?.sizeToFit()
        self.sldDistanceView.addSubview(slideDistance!)


        self.loadUserFilter()
        pickerViewDate = UIAlertController(title: "Date Availabe", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        theDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 44, width: 0, height: 0))
        theDatePicker?.datePickerMode = .date
        theDatePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        pickerToolbar?.barStyle = .blackOpaque
        pickerToolbar?.sizeToFit()
        var barItems = [UIBarButtonItem]()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDoneClick))
        barItems.append(flexSpace)
        pickerToolbar?.setItems(barItems, animated: true)
        pickerViewDate?.view.addSubview(pickerToolbar!)
        pickerViewDate?.view.addSubview(theDatePicker!)
        pickerViewDate?.view.bounds = CGRect(x: 0, y: 0, width: 320, height: 264)
        txtDateFrom.inputView = pickerViewDate?.view


    }

    @objc func datePickerDoneClick() {
        _ = self.closeDatePicker()
    }

    func closeDatePicker() -> Bool {
        pickerViewDate?.dismiss(animated: true, completion: nil)
        txtDateFrom.resignFirstResponder()
        return true
    }


    @IBAction func actSort(_ sender: Any) {
        let pickerView = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight)), title: "Please pick a sort type", value: pickValue, items: ["Most Recent", "Oldest", "Any"], offset: CGPoint(x: 0, y: 0))

        pickerView?.delegate = self
        pickerView?.tag = 1003
        self.view.addSubview(pickerView!)
        pickerView?.show(in: self.view)
        selectedButton = sender as? UIButton
        self.disableButtons()
    }

    @IBAction func actBuilding(_ sender: Any) {
        let pickerCategory = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight - 44)), title: "Please Choose an Asset Type", value: pickValue, items: ["Office", "Retail", "Industrial", "Multifamily", "Medical", "Land", "Entertainment", "Specialty", "Hospitality", "Mixed Use", "Residential", "Investment", "Coworking", "Restaurant", "Pad Site", "Flex", "Student Housing", "Any"], offset: CGPoint(x: 0, y: 0))

        pickerCategory?.delegate = self
        pickerCategory?.tag = 1002
        self.view.addSubview(pickerCategory!)
        pickerCategory?.show(in: self.view)
        self.disableButtons()
    }

    @IBAction func actLease(_ sender: Any) {
        let pickerLease = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight)), title: "Please Choose One", value: pickValue, items: ["Lease", "Sale", "Sale & Lease", "Sublease", "Lease (monthly)", "Lease (annually)", "Lease (PSF/Mo)", "Lease (PSF/Ann)", "Any"], offset: CGPoint(x: 0, y: 0))

        pickerLease?.delegate = self
        pickerLease?.tag = 1001
        self.view.addSubview(pickerLease!)
        pickerLease?.show(in: self.view)
        selectedButton = sender as? UIButton
        self.disableButtons()
    }

    @IBAction func actApply(_ sender: Any) {

        user?.uf_priceStart = String(describing: slidePrice!.lowerValue)
        user?.uf_priceEnd = String(describing: slidePrice!.upperValue)
        user?.uf_distanceStart = String(describing: slideDistance!.lowerValue)
        user?.uf_distanceEnd = String(describing: slideDistance!.upperValue)

        /*
        user?.uf_priceStart = slidePrice?.lowerValue as! String
        user?.uf_priceEnd = slidePrice?.upperValue as! String
        user?.uf_distanceStart = slideDistance?.lowerValue as! String
        user?.uf_distanceEnd = slideDistance?.lowerValue as! String
        */

        saveUserInfo()
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


    func enableButtons() {
        btnBuilding.isEnabled = true
        btnLease.isEnabled = true
        btnSort.isEnabled = true
    }

    func disableButtons() {
        btnBuilding.isEnabled = false
        btnLease.isEnabled = false
        btnSort.isEnabled = false
    }

    @objc func dateChanged() {
        txtDateFrom.text = Utilities.str(fromDateShort: (theDatePicker?.date)!)
        user?.uf_dateFrom = txtDateFrom.text!
    }

    func dismissPickerControl(_ view: LCTableViewPickerControl?) {
        self.enableButtons()
        view?.dismiss()
    }

    // LCTableViewPickerDelegate

    func select(_ view: LCTableViewPickerControl!, didSelectWithItem item: Any!) {
        self.pickValue = item
        if (item as! String == "") {

        }
        else {
            //selectedButton?.setTitle(item as? String, for: .normal)
            if (view.tag == 1001) {
                user?.uf_lease = (item as? String)!
                btnLease.setTitle(item as? String, for: .normal)
            }
            else if (view.tag == 1002) {
                user?.uf_building = (item as? String)!
                btnBuilding.setTitle(item as? String, for: .normal)
            }
            else if (view.tag == 1003) {
                user?.uf_sort = (item as? String)!
                btnSort.setTitle(item as? String, for: .normal)
            }


        }

        self.dismissPickerControl(view)
    }

    func select(_ view: LCTableViewPickerControl!, didCancelWithItem item: Any!) {
        self.dismissPickerControl(view)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
