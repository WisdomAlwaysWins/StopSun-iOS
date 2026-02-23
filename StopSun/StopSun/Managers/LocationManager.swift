//
//  LocationManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation
import CoreLocation

/// 위치 관리자
///
/// CoreLocation을 통해 현재 위치를 조회하고
/// Significant Location Changes를 모니터링합니다.
///
/// ## 권한 흐름
/// `requestAlwaysAuthorization()` 호출 시 iOS가 자동으로 2단계 처리:
/// 1. "앱 사용 중 허용" 팝업 표시
/// 2. 이후 iOS가 적절한 시점에 "항상 허용" 팝업 표시
///
/// ## Info.plist 필수 키
/// - `NSLocationWhenInUseUsageDescription`
/// - `NSLocationAlwaysAndWhenInUseUsageDescription`
///
final class LocationManager: NSObject, LocationManagerProtocol {
    
    // MARK: - Properties
    
    private let clLocationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    /// getCurrentLocation() 호출 시 사용하는 continuation
    ///
    /// 한 번에 하나의 위치 요청만 처리합니다.
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Protocol Conformance
    
    var isAuthorized: Bool {
        switch clLocationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    var isDenied: Bool {
        clLocationManager.authorizationStatus == .denied
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        clLocationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        let status = clLocationManager.authorizationStatus
        
        // 이미 결정된 상태면 바로 리턴
        guard status == .notDetermined else { return }
        
        clLocationManager.requestAlwaysAuthorization()
        
        // 권한 다이얼로그 응답 대기
        while clLocationManager.authorizationStatus == .notDetermined {
            try? await Task.sleep(for: .milliseconds(200))
        }
    }
    
    // MARK: - Current Location
    
    func getCurrentLocation() async throws -> LocationInfo {
        guard isAuthorized else {
            throw AppError.location(.authorizationDenied)
        }
        
        let clLocation = try await requestSingleLocation()
        let cityName = await reverseGeocode(clLocation)
        
        return LocationInfo(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude,
            cityName: cityName
        )
    }
    
    // MARK: - Significant Location Changes
    
    func startMonitoringSignificantLocationChanges() {
        clLocationManager.startMonitoringSignificantLocationChanges()
        Log.info("Significant Location Changes 모니터링 시작")
    }
    
    func stopMonitoringSignificantLocationChanges() {
        clLocationManager.stopMonitoringSignificantLocationChanges()
        Log.info("Significant Location Changes 모니터링 중지")
    }
    
    // MARK: - Private Methods
    
    /// 단일 위치 요청
    ///
    /// `requestLocation()`은 위치를 한 번 받고 자동으로 중지됩니다.
    /// 동시에 여러 요청이 들어오면 기존 요청을 취소합니다.
    private func requestSingleLocation() async throws -> CLLocation {
        // 기존 요청이 있으면 취소
        if let existing = locationContinuation {
            existing.resume(throwing: CancellationError())
            locationContinuation = nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            clLocationManager.requestLocation()
        }
    }
    
    /// 역지오코딩으로 도시 이름 조회
    ///
    /// 실패해도 nil 반환 (도시 이름은 선택 정보)
    private func reverseGeocode(_ location: CLLocation) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality
        } catch {
            Log.warning("역지오코딩 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Significant Location Change에서 LocationInfo 생성 후 Notification 발송
    private func postLocationChangeNotification(from location: CLLocation) {
        Task {
            let cityName = await reverseGeocode(location)
            let locationInfo = LocationInfo(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                cityName: cityName
            )
            
            NotificationCenter.default.post(
                name: .locationDidChange,
                object: nil,
                userInfo: [NotificationUserInfoKey.location: locationInfo]
            )
            
            Log.info("위치 변경 감지: \(cityName ?? "알 수 없음") (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 단일 위치 요청 응답
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
            return
        }
        
        // Significant Location Changes 응답
        postLocationChangeNotification(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("위치 조회 실패: \(error.localizedDescription)")
        
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: AppError.location(.locationUnavailable))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Log.info("위치 권한 변경: \(status.debugDescription)")
    }
}

// MARK: - CLAuthorizationStatus + Debug

extension CLAuthorizationStatus {
    var debugDescription: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown(\(rawValue))"
        }
    }
}
