//
//  WeatherWeather.swift
//  WeatherLikeHere
//
//  Created by Artem Bazhanov on 29.01.2021.
//

import Foundation
import ObjectMapper

extension weatherWeather: Mappable{
    func mapping(map: Map) {
        icon <- map["icon"]
    }
}

class weatherWeather: NSObject {
    
    var icon: String?
  
    required init?(map: Map) { super.init() }

}
