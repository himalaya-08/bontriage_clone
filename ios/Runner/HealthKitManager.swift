    //
    //  HealthKitManager.swift
    //  Runner
    //
    //  Created by HimalayaBaddhan on 06/11/23.
    //
    import HealthKit

    class HealthKitManager {
        let healthStore = HKHealthStore()
        
          let BLOOD_OXYGEN = "BLOOD_OXYGEN"
          let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
          let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
          let BODY_TEMPERATURE = "BODY_TEMPERATURE"
          let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
          let HEART_RATE = "HEART_RATE"
          let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
          let RESTING_HEART_RATE = "RESTING_HEART_RATE"
          let WALKING_HEART_RATE = "WALKING_HEART_RATE"
          let EXERCISE_TIME = "EXERCISE_TIME"
          let HEADACHE_UNSPECIFIED = "HEADACHE_UNSPECIFIED"
          let HEADACHE_NOT_PRESENT = "HEADACHE_NOT_PRESENT"
          let HEADACHE_MILD = "HEADACHE_MILD"
          let HEADACHE_MODERATE = "HEADACHE_MODERATE"
          let HEADACHE_SEVERE = "HEADACHE_SEVERE"
        
        var dataTypesDict: [String: HKSampleType] = [:]
        
        func initializeTypes() {

                // Set up iOS 13 specific types (ordinary health data types)
                if #available(iOS 13.0, *) {
                  dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
                  dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(
                    forIdentifier: .bloodPressureDiastolic)!
                  dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(
                    forIdentifier: .bloodPressureSystolic)!
                  dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
                  dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(
                    forIdentifier: .electrodermalActivity)!
                  dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
                  dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(
                    forIdentifier: .heartRateVariabilitySDNN)!
                  dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(
                    forIdentifier: .restingHeartRate)!
                  dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(
                    forIdentifier: .walkingHeartRateAverage)!
                  dataTypesDict[EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
                }

                if #available(iOS 13.6, *) {
                  dataTypesDict[HEADACHE_UNSPECIFIED] = HKSampleType.categoryType(forIdentifier: .headache)!
                  dataTypesDict[HEADACHE_NOT_PRESENT] = HKSampleType.categoryType(forIdentifier: .headache)!
                  dataTypesDict[HEADACHE_MILD] = HKSampleType.categoryType(forIdentifier: .headache)!
                  dataTypesDict[HEADACHE_MODERATE] = HKSampleType.categoryType(forIdentifier: .headache)!
                  dataTypesDict[HEADACHE_SEVERE] = HKSampleType.categoryType(forIdentifier: .headache)!
                }
        }
        
        
        func checkHealthKitPermission(name: String) -> String {
            //let data = dataTypesDict[name]!
            let data = HKSampleType.quantityType(forIdentifier: .heartRate)!
            let authorizationStatus = healthStore.authorizationStatus(for: data)
            
            switch authorizationStatus {
                    case .notDetermined:
                        return "NOT_DETERMINED"
                    case .sharingAuthorized:
                        return "SHARING_AUTHORIZED"
                    case .sharingDenied:
                        return "SHARING_DENIED"
                    @unknown default:
                        return "UNKNOWN"
            }
        }

        func requestHealthKitPermission(completion: @escaping (Bool, Error?) -> Void) {
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            let healthKitTypesToRead: Set<HKSampleType> = [stepCountType]
            
            let authorizationStatus = healthStore.authorizationStatus(for: stepCountType)
        
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }

    }
