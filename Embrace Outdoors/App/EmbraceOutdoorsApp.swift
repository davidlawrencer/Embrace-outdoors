//
//  Embrace_OutdoorsApp.swift
//  Embrace Outdoors
//
//  Created by David Rifkin on 4/30/24.
//

import SwiftUI
import EmbraceIO
import ZipkinExporter

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
                    platform: .default//,
//                    endpoints: Embrace.Endpoints(
//                        baseURL: "http://localhost:8989/api",
//                        developmentBaseURL: "http://localhost:8989/api",
//                        configBaseURL: "http://localhost:8989/api"
//                    )
                    // add span exporter locations
//                    export: OpenTelemetryExport(
//                        spanExporter: ZipkinTraceExporter(options: ZipkinTraceExporterOptions())
//                        )
                )
            ).start()
        } catch let e {
            print(e.localizedDescription)
        }
    }
}
