//
//  HealthKitManager.swift
//  trackStep
//
//  Created by Payal Kandlur on 22/07/20.
//  Copyright © 2020 Payal Kandlur. All rights reserved.
//

import HealthKit

class HealthKitManager {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        if #available(iOS 14.0, *) {
            guard
                //MARK: Clinical records
                let allergyRecord = HKObjectType.clinicalType(forIdentifier: .allergyRecord),
                let conditionRecord = HKObjectType.clinicalType(forIdentifier: .conditionRecord),
                let labResultRecord = HKObjectType.clinicalType(forIdentifier: .labResultRecord),
                let medicationRecord = HKObjectType.clinicalType(forIdentifier: .medicationRecord),
                let procedureRecord = HKObjectType.clinicalType(forIdentifier: .procedureRecord),
                let vitalSignRecord = HKObjectType.clinicalType(forIdentifier: .vitalSignRecord),
                
                //MARK: Activity data
//                let activityMoveMode = HKObjectType.characteristicType(forIdentifier: .activityMoveMode), //available only on iOS14
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
                let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
                let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
                let appleStandHour = HKObjectType.categoryType(forIdentifier: .appleStandHour),
                let appleStandTime = HKObjectType.quantityType(forIdentifier: .appleStandTime),
                
                //MARK: Body measurements
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass),
                let bodyFatPercentage = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
                let waistCircumference = HKObjectType.quantityType(forIdentifier: .waistCircumference),
                
                //MARK: Vital signs
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let lowHeartRateEvent = HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent),
                let highHeartRateEvent = HKObjectType.categoryType(forIdentifier: .highHeartRateEvent),
                let irregularHeartRhythmEvent = HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent),
                let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let heartRateVariabilitySDNN = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
                let walkingHeartRateAverage = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage),
                
                //Heartbeat series
                let heartbeatSeries = HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries),
                
                let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
                //            let bloodPressure = HKCorrelationType.correlationType(forIdentifier: .bloodPressure),
                let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
                let vo2Max = HKObjectType.quantityType(forIdentifier: .vo2Max),
                
                //MARK: Nutrients
                //            let food = HKCorrelationType.correlationType(forIdentifier: .food),
                let dietaryEnergyConsumed = HKCorrelationType.quantityType(forIdentifier: .dietaryCarbohydrates),
                let dietaryCarbohydrates = HKCorrelationType.quantityType(forIdentifier: .dietaryCarbohydrates),
                
                
                //            let symptom = HKObjectType.categoryType(forIdentifier: .abdominalCramps),
                //MARK: Lab test and results
                let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose),
                let insulinDelivery = HKObjectType.quantityType(forIdentifier: .insulinDelivery),
                let peripheralPerfusionIndex = HKObjectType.quantityType(forIdentifier: .peripheralPerfusionIndex),
                
                //MARK: Mindfullness and sleep
                let sleepAnalysis = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
            }
            
            
            //MARK: Workouts
            let workouts = HKObjectType.workoutType()
            let activityMoveMode = HKObjectType.activitySummaryType()
            
            //MARK: Eclectrocardiogram
            let electrocardiogramType = HKObjectType.electrocardiogramType()
            
            let healthKitTypesToWrite: Set<HKSampleType> = [height, bodyMass]
            
            let healthKitTypesToRead: Set<HKObjectType> = [allergyRecord, conditionRecord, height, bodyMass]
            
            HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,read: healthKitTypesToRead) { (success, error) in
                completion(success, error)
            }
        } else {
            // Fallback on earlier versions
            guard
                //MARK: Clinical records
                let allergyRecord = HKObjectType.clinicalType(forIdentifier: .allergyRecord),
                let conditionRecord = HKObjectType.clinicalType(forIdentifier: .conditionRecord),
                let labResultRecord = HKObjectType.clinicalType(forIdentifier: .labResultRecord),
                let medicationRecord = HKObjectType.clinicalType(forIdentifier: .medicationRecord),
                let procedureRecord = HKObjectType.clinicalType(forIdentifier: .procedureRecord),
                let vitalSignRecord = HKObjectType.clinicalType(forIdentifier: .vitalSignRecord),
                
                //MARK: Activity data
//                let activityMoveMode = HKObjectType.characteristicType(forIdentifier: .activityMoveMode), //available only on iOS14
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
                let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
                let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
                let appleStandHour = HKObjectType.categoryType(forIdentifier: .appleStandHour),
                let appleStandTime = HKObjectType.quantityType(forIdentifier: .appleStandTime),
                
                //MARK: Body measurements
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass),
                let bodyFatPercentage = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
                let waistCircumference = HKObjectType.quantityType(forIdentifier: .waistCircumference),
                
                //MARK: Vital signs
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let lowHeartRateEvent = HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent),
                let highHeartRateEvent = HKObjectType.categoryType(forIdentifier: .highHeartRateEvent),
                let irregularHeartRhythmEvent = HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent),
                let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let heartRateVariabilitySDNN = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
                let walkingHeartRateAverage = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage),
                
                //Heartbeat series
                //            let heartbeatSeries = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: HKDataTypeIdentifierHeartbeatSeries)),
                
                let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
                //            let bloodPressure = HKCorrelationType.correlationType(forIdentifier: .bloodPressure),
                
                let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                
                let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
                let vo2Max = HKObjectType.quantityType(forIdentifier: .vo2Max),
                
                //MARK: Nutrients
                //            let food = HKCorrelationType.correlationType(forIdentifier: .food),
                let dietaryEnergyConsumed = HKCorrelationType.quantityType(forIdentifier: .dietaryCarbohydrates),
                let dietaryCarbohydrates = HKCorrelationType.quantityType(forIdentifier: .dietaryCarbohydrates),
                
                
                //            let symptom = HKObjectType.categoryType(forIdentifier: .abdominalCramps),
                //MARK: Lab test and results
                let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose),
                let insulinDelivery = HKObjectType.quantityType(forIdentifier: .insulinDelivery),
                let peripheralPerfusionIndex = HKObjectType.quantityType(forIdentifier: .peripheralPerfusionIndex),
                
                //MARK: Mindfullness and sleep
                let sleepAnalysis = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
            }
            
            
            //MARK: Workouts
            let workouts = HKObjectType.workoutType()
            
            //MARK: Eclectrocardiogram
//            let electrocardiogramType = HKObjectType.electrocardiogramType()
            
            let healthKitTypesToWrite: Set<HKSampleType> = []
            
            let healthKitTypesToRead: Set<HKObjectType> = [allergyRecord, conditionRecord, labResultRecord, medicationRecord, procedureRecord, vitalSignRecord, biologicalSex, dateOfBirth, distanceWalkingRunning, basalEnergyBurned, activeEnergyBurned, appleExerciseTime, appleStandHour, appleStandTime, height, bodyMass, bodyMassIndex, leanBodyMass, bodyFatPercentage, waistCircumference, heartRate, lowHeartRateEvent, highHeartRateEvent, irregularHeartRhythmEvent, restingHeartRate, heartRateVariabilitySDNN, walkingHeartRateAverage, oxygenSaturation, bloodPressureSystolic, bloodPressureDiastolic, respiratoryRate, vo2Max, bloodGlucose, insulinDelivery, peripheralPerfusionIndex,sleepAnalysis, workouts, dietaryCarbohydrates, dietaryEnergyConsumed]
            
            HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,read: healthKitTypesToRead) { (success, error) in
                completion(success, error)
            }
        }
        
        }
    
    func getHeight(for sampleType: HKSampleType,
                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let distantPastHeight = Date.distantPast
        let currentDate = Date()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart:distantPastHeight, end: currentDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
     
        let heightQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error ) -> Void in
            DispatchQueue.main.async {
                guard let samples = samples, let lastHeight = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(lastHeight, nil)
            }
            
        }
        HKHealthStore().execute(heightQuery)
    }
    func getStep(for sampleType: HKSampleType,
                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let distantPastStep = Date.distantPast
        let currentDate = Date()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart:distantPastStep, end: currentDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let stepQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error ) -> Void in
            DispatchQueue.main.async {
                guard let samples = samples, let lastStepCount = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(lastStepCount, nil)
            }
            
        }
        HKHealthStore().execute(stepQuery)
    }
    func getHeartRate(for sampleType: HKSampleType,
                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let distantPastHeartRate = Date.distantPast
        let currentDate = Date()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart:distantPastHeartRate, end: currentDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let heartRateQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error ) -> Void in
            DispatchQueue.main.async {
                guard let samples = samples, let lastHeartRateCount = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(lastHeartRateCount, nil)
            }
            
        }
        HKHealthStore().execute(heartRateQuery)
    }
    
    func getNutrients(for sampleType: HKQuantityType,
                      completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        let distantPastHeartRate = Date.distantPast
        let currentDate = Date()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart:distantPastHeartRate, end: currentDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let heartRateQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error ) -> Void in
            DispatchQueue.main.async {
                guard let samples = samples, let lastHeartRateCount = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(lastHeartRateCount, nil)
            }
            
        }
        HKHealthStore().execute(heartRateQuery)
    }

    func saveDistance(distanceRecorded: Double, date: Date ) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print ("error")
            return
        }
        
        let distanceQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: distanceRecorded)
        
        let distance = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: date, end: date)
     
        
        HKHealthStore().save(distance) { (success, error) in
            
            if let error = error {
                print("Error Saving distance: \(error.localizedDescription)")
            } else {
                print("Successfully saved distance")
            }
        }
    }
    
    func saveStep(stepsRecorded: Double, date: Date ) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print ("error")
            return
        }
        
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: stepsRecorded)
        
        let step = HKQuantitySample(type: stepType, quantity: stepQuantity, start: date, end: date)
        
        
        HKHealthStore().save(step) { (success, error) in
            
            if let error = error {
                print("Error Saving steps: \(error.localizedDescription)")
            } else {
                print("Successfully saved steps")
            }
        }
    }
    
    func saveHeartRate(heartRateRecorded: Double, date: Date ) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print ("error")
            return
        }
        
        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: heartRateRecorded)
        
        let heartRate = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)
        
        
        HKHealthStore().save(heartRate) { (success, error) in
            
            if let error = error {
                print("Error Saving heart rate: \(error.localizedDescription)")
            } else {
                print("Successfully saved heart rate")
            }
        }
    }
    
}
