//
//  WeatherAPI.swift
//  StopSun
//
//  Created by J on 1/30/26.
//

import Foundation
import Moya

/// WeatherAPI 엔드포인트 정의
enum WeatherAPI {
    /// 현재 날씨만
    case current(lat: Double, lon: Double)
    
    /// 현재 날씨 + 시간별 예보
    case forecast(lat: Double, lon: Double, days: Int)
    
    /// 과거 날씨
    case history(lat: Double, lon: Double, date: String)
}

extension WeatherAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://api.weatherapi.com/v1")!
    }
    
    var path: String {
        switch self {
        case .current:
            return "/current.json"
        case .forecast:
            return "/forecast.json"
        case .history:
            return "/history.json"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
         switch self {
         case .current(let lat, let lon):
             return .requestParameters(
                 parameters: [
                     "key": WeatherAPIConfig.apiKey,
                     "q": "\(lat),\(lon)",
                     "aqi": "no"
                 ],
                 encoding: URLEncoding.queryString
             )
             
         case .forecast(let lat, let lon, let days):
             return .requestParameters(
                 parameters: [
                     "key": WeatherAPIConfig.apiKey,
                     "q": "\(lat),\(lon)",
                     "days": days,
                     "aqi": "no",
                     "alerts": "no"
                 ],
                 encoding: URLEncoding.queryString
             )
             
         case .history(let lat, let lon, let date):
             return .requestParameters(
                 parameters: [
                     "key": WeatherAPIConfig.apiKey,
                     "q": "\(lat),\(lon)",
                     "dt": date
                 ],
                 encoding: URLEncoding.queryString
             )
         }
     }
     
     var headers: [String: String]? {
         ["Content-Type": "application/json"]
     }
}

// MARK: - API Config

enum WeatherAPIConfig {
    static var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["WeatherAPIKey"] as? String,
              !key.isEmpty,
              !key.hasPrefix("$(") else {
            fatalError("❌ WeatherAPIKey가 설정되지 않았습니다.")
        }
        return key
    }
}
