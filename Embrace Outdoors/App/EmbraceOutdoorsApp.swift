//
//  Embrace_OutdoorsApp.swift
//  Embrace Outdoors
//
//  Created by David Rifkin on 4/30/24.
//

import SwiftUI
import EmbraceIO

@main
struct EmbraceOutdoorsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        do {
            try Embrace.setup(
                options: Embrace.Options(
                    appId: "84eN2",
                    platform: .default,
                    // add span exporter locations
                    export: OpenTelemetryExport()
                )
            ).start()
        } catch let e {
            print(e.localizedDescription)
        }
    }
}
