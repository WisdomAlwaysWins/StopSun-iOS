//
//  WeatherAPIResponse.swift
//  StopSun
//
//  Created by J on 1/30/26.
//

import Foundation

/// WeatherAPI 응답 모델
struct WeatherAPIResponse: Decodable {
    let location: WeatherAPILocation
    let current: WeatherAPICurrent?
    let forecast: WeatherAPIForecast?
}

struct WeatherAPILocation: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct WeatherAPICurrent: Decodable {
    let tempC: Double
    let uv: Double
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case uv
    }
}

struct WeatherAPIForecast: Decodable {
    let forecastday: [WeatherAPIForecastDay]
}

struct WeatherAPIForecastDay: Decodable {
    let date: String
    let hour: [WeatherAPIHour]
}

struct WeatherAPIHour: Decodable {
    let time: String
    let tempC: Double
    let uv: Double
    
    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case uv
    }
}
