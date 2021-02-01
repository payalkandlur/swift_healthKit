//
//  TimerViewController.swift
//  trackStep
//
//  Created by Payal Kandlur on 22/07/20.
//  Copyright © 2020 Payal Kandlur. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit


@available(iOS 14.0, *)
class TimerViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var update: UIButton!
    @IBOutlet weak var beatsPerMinute: UILabel!
    @IBOutlet weak var currentStepCount: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var heartrateLabel: UILabel!
    @IBOutlet weak var authorize: UIButton!
    
    var zeroTime = TimeInterval()
    var timer : Timer = Timer()
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    var steps = 0.0
    var heartRate = 72.0
    var height: Double = 0.0
    var flag: Bool = false
    let healthkitManager = HealthKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setHeight()
        self.setStep()
        self.setHeartRate()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Need to Enable Location")
        }
        
        authorize.layer.cornerRadius = 5
        startButton.layer.cornerRadius = 5
        stopButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius = 5
    }
    @IBAction func updateValues(_ sender: Any) {
        self.setHeight()
        self.setStep()
        self.setHeartRate()
    }
    @IBAction func authorizeApp(_ sender: Any) {
        if (flag == false) {
            
        let alert = UIAlertController.init(title: "Track Step wants to access Health App", message: "Allow Access?", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (_) in
            }))
            
            alert.addAction(UIAlertAction.init(title: "HealthApp", style: .default, handler: { (_) in
                self.getHealthKitPermission()
            }))
    
            present(alert, animated: true)
        }
        if (flag == true){
            let alert = UIAlertController.init(title: "Authorized", message: "App already authorized", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (_) in
            }))
            present(alert, animated: true)
        }
//        getHealthKitPermission()
    }
    
    func getHealthKitPermission() {
        
        HealthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                self.flag = true
                self.setHeight()
                self.setStep()
                self.setHeartRate()
            } else {
                if error != nil {
                    print(error)
                }
                print("Permission denied.")
            }
        }
    }
    
    @IBAction func startTimer(sender: AnyObject) {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        zeroTime = NSDate.timeIntervalSinceReferenceDate
        
        distanceTraveled = 0.0
        startLocation = nil
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopTimer(sender: AnyObject) {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    @IBAction func shareButton(_ sender: Any) {
        self.healthkitManager.saveDistance(distanceRecorded: distanceTraveled, date: Date())
        self.healthkitManager.saveStep(stepsRecorded: steps, date: Date())
        self.healthkitManager.saveHeartRate(heartRateRecorded: heartRate, date: Date())

    }
    
    @objc func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        var timePassed: TimeInterval = currentTime - zeroTime
        let minutes = UInt8(timePassed / 60.0)
        timePassed -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(timePassed)
        timePassed -= TimeInterval(seconds)
        let millisecsX10 = UInt8(timePassed * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMSX10 = String(format: "%02d", millisecsX10)
        
        if strMSX10 == "05" {
            steps += 1
//            heartRate += 2
        }
//        stepsLabel.text = "\(steps)"
//        heartrateLabel.text = "\(heartRate)"
        self.currentStepCount.text = "\(steps)"
        self.beatsPerMinute.text = "\(heartRate)"
        timerLabel.text = "\(strMinutes):\(strSeconds):\(strMSX10)"
        
        if timerLabel.text == "60:00:00" {
            timer.invalidate()
            locationManager.stopUpdatingLocation()
        }
    }
    


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first as CLLocation?
        } else {
            let lastDistance = lastLocation.distance(from: (locations.last as CLLocation?)!)
            distanceTraveled += lastDistance * 0.000621371
            
            let trimmedDistance = String(format: "%.2f", distanceTraveled)

            milesLabel.text = "\(trimmedDistance) Miles"
            
        }
        lastLocation = locations.last as CLLocation?
    }
    
    func setHeight() {
        
        guard let heightSample = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        self.healthkitManager.getHeight(for: heightSample) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                   print("Error: \(error.localizedDescription)")
                }
                
                return
            }
            
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.height = heightInMeters
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            self.heightLabel.text = heightFormatter.string(fromMeters: self.height)
        }

    }
    func setStep() {
        
        guard let stepSample = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            print("Step Sample Type is no longer available in HealthKit")
            return
        }
        
        self.healthkitManager.getStep(for: stepSample) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                return
            }
            
            let stepCount = sample.quantity.doubleValue(for: HKUnit.count())
            self.stepsLabel.text = String(stepCount)
        }
        
    }
    func setHeartRate() {
        
        guard let heartRateSample = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            print("Heart Rate Sample Type is no longer available in HealthKit")
            return
        }
        guard let nutirentSample = HKCorrelationType.quantityType(forIdentifier: .dietaryCarbohydrates) else {
            print("Heart Rate Sample Type is no longer available in HealthKit")
            return
        }
        self.healthkitManager.getNutrients(for: nutirentSample) { (sample, error) in
            guard let sample = sample else {
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                return
            }
            print(sample.quantity)
        }
        
        self.healthkitManager.getHeartRate(for: heartRateSample) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                return
            }
            
            let heartRateCount = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            self.heartrateLabel.text = String(heartRateCount)
        }
        
    }
}
