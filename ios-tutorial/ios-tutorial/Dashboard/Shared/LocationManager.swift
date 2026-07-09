//
//  LocationManager.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-09.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

@MainActor
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if UserDefaults.standard.bool(forKey: "locationEnabled") &&
            (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            manager.startUpdatingLocation()
        }
    }
    
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
            completion?(true)
        } else if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            completion?(true)
        } else {
            // Denied or restricted
            completion?(false)
        }
    }
    
    func startTracking() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            requestPermission()
        }
    }
    
    func stopTracking() {
        manager.stopUpdatingLocation()
        currentLocation = nil
    }
    
    /// Returns current coordinates if location tracking is enabled in Settings and coordinates are available.
    func getLatLng() -> (latitude: Double, longitude: Double)? {
        guard UserDefaults.standard.bool(forKey: "locationEnabled"),
              let coord = currentLocation else {
            return nil
        }
        return (coord.latitude, coord.longitude)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location.coordinate
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                if UserDefaults.standard.bool(forKey: "locationEnabled") {
                    manager.startUpdatingLocation()
                }
            } else if status == .denied || status == .restricted {
                UserDefaults.standard.set(false, forKey: "locationEnabled")
                manager.stopUpdatingLocation()
                self.currentLocation = nil
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed with error: \(error.localizedDescription)")
    }
}
