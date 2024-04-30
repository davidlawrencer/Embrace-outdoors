//
//  ParkRequestResult.swift
//  Embrace Outdoors
//
//  Created by David Rifkin on 4/30/24.
//

import Foundation

struct ParkRequestResult: Codable {
    let total: String
    let limit: String
    let data: [Park]
    
    struct Park: Codable {
        let url: String
        let fullName: String
        let parkCode: String
        let description: String
        let latitude: String
        let longitude: String
    }
}

