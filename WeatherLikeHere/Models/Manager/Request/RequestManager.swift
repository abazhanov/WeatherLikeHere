//
//  RequestManager.swift
//  MoyaGetWeatherFromOpenWeatherMap
//
//  Created by Artem Bazhanov on 28.01.2021.
//

import Foundation
import Moya

enum RequestManager{
    case getWheather(lat: Double, lon:Double)
}

extension RequestManager: TargetType {
    var baseURL: URL {
        switch self {
        case .getWheather:
            return URL(string: "https://api.openweathermap.org/data/2.5")!
        }
    }
    
    var path: String {
        switch self {
        case .getWheather:
            return "/weather"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWheather:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getWheather:
            return .requestParameters(parameters: parameters!, encoding: parameterEncoding)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getWheather(lat: let lat, lon: let lon):
            var params = [String: Any]()
           
            //params = ["lat":"56.326887", "lon":"44.005986", "appid":"a6c40d5ab6bb6b87ea73272d831fe569", "units":"metric", "lang":"ru"]
            let lat1 = String(lat)
            let lon1 = String(lon)
            params = ["lat":"\(lat1)", "lon":"\(lon1)", "appid":"a6c40d5ab6bb6b87ea73272d831fe569", "units":"metric", "lang":"ru"]
            
            return params
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getWheather:
            return URLEncoding.default
        }
    }
    
}

