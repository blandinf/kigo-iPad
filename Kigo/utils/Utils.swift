//
//  Utils.swift
//  Kigo
//
//  Created by Florian on 10/06/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation
import MapKit

class Utils {    
    static func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    static func convertMinutesToHoursAndMinutes(totalMinutes: Int) -> (hours: Int, minutes: Int) {
        let divider = 1.6667
        let minutesInHours = Double(totalMinutes) / 60.0
        let hours = Int(minutesInHours)
        let minutes = Int((minutesInHours - Double(hours)) * 100)
        let realMinutes = Int(round(Double(minutes) / divider))
        
        return (hours, realMinutes)
    }
}
