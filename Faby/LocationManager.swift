//
//  LocationManager.swift
//  Faby
//
//  Created by Adarsh Mishra on 23/04/25.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onLocationError: ((Error) -> Void)?
    var onPermissionDenied: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        let authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
        manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
        manager.requestLocation()
        case .denied, .restricted:
            onPermissionDenied?()
        @unknown default:
            print("Unknown authorization status")
            onPermissionDenied?()
        }
    }
    
    // Called when authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            onPermissionDenied?()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            onLocationUpdate?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
        
        // Check if it's a permission error
        if let clError = error as? CLError, clError.code == .denied {
            onPermissionDenied?()
        } else {
            onLocationError?(error)
        }
    }
}
