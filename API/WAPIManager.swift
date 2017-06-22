//
//  WAPIManager.swift
//  YetAnotherWeatherApp
//
//  Created by Filippo Tosetto on 11/04/2015.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON


public enum TemperatureFormat: String {
    case Celsius = "metric"
    case Fahrenheit = "imperial"
    case Kelvin = ""
}

public enum Language : String {
    case English = "en",
    Russian = "ru",
    Italian = "it",
    Spanish = "es",
    Ukrainian = "uk",
    German = "de",
    Portuguese = "pt",
    Romanian = "ro",
    Polish = "pl",
    Finnish = "fi",
    Dutch = "nl",
    French = "fr",
    Bulgarian = "bg",
    Swedish = "sv",
    ChineseTraditional = "zh_tw",
    ChineseSimplified = "zh_cn",
    Turkish = "tr",
    Croatian = "hr",
    Catalan = "ca"
}

public enum WeatherResult {
    case success(JSON)
    case error(String)
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }
}


open class WAPIManager {
    
    fileprivate var params = [String : AnyObject]()
    open var temperatureFormat: TemperatureFormat = .Kelvin {
        didSet {
            params["units"] = temperatureFormat.rawValue as AnyObject
        }
    }
    
    open var language: Language = .English {
        didSet {
            params["lang"] = language.rawValue as AnyObject
        }
    }
    
    public init(apiKey: String) {
        params["APPID"] = apiKey as AnyObject
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat) {
        self.init(apiKey: apiKey)
        self.temperatureFormat = temperatureFormat
        self.params["units"] = temperatureFormat.rawValue as AnyObject
        
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat, lang: Language) {
        self.init(apiKey: apiKey, temperatureFormat: temperatureFormat)
        
        self.language = lang
        self.temperatureFormat = temperatureFormat
        
        params["units"] = temperatureFormat.rawValue as AnyObject
        params["lang"] = lang.rawValue as AnyObject
    }
}

// MARK: Private functions
extension WAPIManager {
    fileprivate func apiCall(_ method: Router, response: @escaping (WeatherResult) -> Void) {
        Alamofire.request(method).responseJSON { (_, _, data) in
            guard let js: AnyObject = data.value, data.isSuccess else {
                response(WeatherResult.Error(data.error.debugDescription))
                return
            }
            response(WeatherResult.Success(JSON(js)))
        }
    }
}

enum Router: URLRequestConvertible {
    static let baseURLString = "http://api.openweathermap.org/data/"
    static let apiVersion = "2.5"
    
    case weather([String: AnyObject])
    case foreCast([String: AnyObject])
    case dailyForecast([String: AnyObject])
    case hirstoricData([String: AnyObject])
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .weather:
            return "/weather"
        case .foreCast:
            return "/forecast"
        case .dailyForecast:
            return "/forecast/daily"
        case .hirstoricData:
            return "/history/city"
        }
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: Router.baseURLString + Router.apiVersion)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        func encode(_ params: [String: AnyObject]) -> NSMutableURLRequest {
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        }
        
        switch self {
        case .weather(let parameters):
            return encode(parameters)
        case .foreCast(let parameters):
            return encode(parameters)
        case .dailyForecast(let parameters):
            return encode(parameters)
        case .hirstoricData(let parameters):
            return encode(parameters)
        }
    }
}


//MARK: - Get Current Weather
extension WAPIManager {
    
    fileprivate func currentWeather(_ params: [String:AnyObject], data: @escaping (WeatherResult) -> Void) {
        apiCall(Router.weather(params)) { data($0) }
    }
    
    public func currentWeatherByCityNameAsJson(_ cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName as AnyObject
        
        currentWeather(params) { data($0) }
    }
    
    public func currentWeatherByCoordinatesAsJson(_ coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude) as AnyObject
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude) as AnyObject
        
        currentWeather(params) { data($0) }
    }
    
}

//MARK: - Get Forecast
extension WAPIManager {
    
    fileprivate func forecastWeather(_ parameters: [String:AnyObject], data: @escaping (WeatherResult) -> Void) {
        apiCall(Router.foreCast(params)) { data($0) }
    }
    
    public func forecastWeatherByCityNameAsJson(_ cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName as AnyObject
        
        forecastWeather(params) { data($0) }
    }
    
    public func forecastWeatherByCoordinatesAsJson(_ coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude) as AnyObject
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude) as AnyObject
        
        forecastWeather(params) { data($0) }
    }
    
}

//MARK: - Get Daily Forecast
extension WAPIManager {
    
    fileprivate func dailyForecastWeather(_ parameters: [String:AnyObject], data: @escaping (WeatherResult) -> Void) {
        apiCall(Router.dailyForecast(params)) { data($0) }
    }
    
    public func dailyForecastWeatherByCityNameAsJson(_ cityName: String, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName as AnyObject
        
        dailyForecastWeather(params) { data($0) }
    }
    
    public func dailyForecastWeatherByCoordinatesAsJson(_ coordinates: CLLocationCoordinate2D, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude) as AnyObject
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude) as AnyObject
        
        dailyForecastWeather(params) { data($0) }
    }
    
}


//MARK: - Get Historic Data
extension WAPIManager {
    
    fileprivate func historicData(_ parameters: [String:AnyObject], data: @escaping (WeatherResult) -> Void) {
        params["type"] = "hour" as AnyObject
        
        apiCall(Router.hirstoricData(params)) { data($0) }
    }
    
    public func historicDataByCityNameAsJson(_ cityName: String, start: Date, end: Date?, data: @escaping (WeatherResult) -> Void) {
        params["q"] = cityName as AnyObject
        
        params["start"] = start.timeIntervalSince1970 as AnyObject
        if let endDate = end {
            params["end"] = endDate.timeIntervalSince1970 as AnyObject
        }
        
        historicData(params) { data($0) }
    }
    
    public func historicDataByCoordinatesAsJson(_ coordinates: CLLocationCoordinate2D, start: Date, end: Date?, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: coordinates.latitude) as AnyObject
        params["lon"] = String(stringInterpolationSegment: coordinates.longitude) as AnyObject
        
        params["start"] = start.timeIntervalSince1970 as AnyObject
        if let endDate = end {
            params["end"] = endDate.timeIntervalSince1970 as AnyObject
        }
        
        historicData(params) { data($0) }
    }
    
}

