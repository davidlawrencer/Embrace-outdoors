//
//  DetailView.swift
//  Embrace Outdoors
//
//  Created by David Rifkin on 4/30/24.
//

import SwiftUI

struct DetailView: View {
    let park: ParkRequestResult.Park
    
    init (park: ParkRequestResult.Park) {
        self.park = park
    }
    
    var body: some View {
        VStack {
            Text(park.description)
        }
        .navigationTitle(park.fullName)
    }
    
}
