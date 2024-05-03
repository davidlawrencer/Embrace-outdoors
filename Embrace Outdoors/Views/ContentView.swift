//
//  ContentView.swift
//  Embrace Outdoors
//
//  Created by David Rifkin on 4/30/24.
//

import SwiftUI
import EmbraceIO

struct ContentView: View {
    @State private var selectedState = "USA"
    @State private var requestedState = ""
    @State var requestResult: ParkRequestResult? = nil
    
    private let states =  [
        "Alabama": "AL",
        "Kentucky":"KY",
        "Ohio": "OH",
        "Alaska": "AK",
        "Louisiana": "LA",
        "Oklahoma": "OK",
        "Arizona": "AZ",
        "Maine": "ME",
        "Oregon": "OR",
        "Arkansas": "AR",
        "Maryland": "MD",
        "Pennsylvania": "PA",
        "American Samoa": "AS",
        "Massachusetts": "MA",
        "Puerto Rico": "PR",
        "California": "CA",
        "Michigan": "MI",
        "Rhode Island": "RI",
        "Colorado": "CO",
        "Minnesota": "MN",
        "South Carolina": "SC",
        "Connecticut": "CT",
        "Mississippi": "MS",
        "South Dakota": "SD",
        "Delaware": "DE",
        "Missouri": "MO",
        "Tennessee": "TN",
        "District of Columbia": "DC",
        "Montana": "MT",
        "Texas": "TX",
        "Florida": "FL",
        "Nebraska": "NE",
        "Georgia": "GA",
        "Nevada": "NV",
        "Utah": "UT",
        "Guam": "GU",
        "New Hampshire": "NH",
        "Vermont": "VT",
        "Hawaii": "HI",
        "New Jersey": "NJ",
        "Virginia": "VA",
        "Idaho": "ID",
        "New Mexico": "NM",
        "Virgin Islands": "VI",
        "Illinois": "IL",
        "New York": "NY",
        "Washington": "WA",
        "Indiana": "IN",
        "North Carolina": "NC",
        "West Virginia": "WV",
        "Iowa": "IA",
        "North Dakota": "ND",
        "Wisconsin": "WI",
        "Kansas": "KS",
        "Northern Mariana Islands": "MP",
        "Wyoming": "WY"
    ]
    private var dataNotNil: Bool {
        requestResult != nil
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                // Standard Actions
                Section {
                    Picker("Select a state:", selection: $selectedState) {
                        ForEach(
                            ["USA"] + states.keys.sorted(),
                            id:\.self
                        ) {
                            Text($0)
                        }
                    }
                    
                    Button {
                        fetchNationalParkData()
                    } label: {
                        Text("Find national parks in " + selectedState)
                    }
                    
                    Button {
                        fetchEmbraceMockNSF()
                    } label: {
                        Text("Make a request that uses Network Span Forwarding")
                    }

                    Button {
                        fetchForbiddenData()
                    } label: {
                        Text("Make an unauthorized request")
                    }
                    
                    Button {
                        fetchTimeout()
                    } label: {
                        Text("Make a request that times out")
                    }
                                        
                    Button {
                        Embrace.client?.crash()
                    } label: {
                        Text("Crash!")
                    }
                    
                    Button {
                        buildSpans()
                    } label: {
                        Text("Create a trace")
                    }
                    
                } header: {
                    Text("Try these requests!")
                }
                
                
//                Section {
//
//                    Button {
//                        buildSpans()
//                    } label: {
//                        Text("Create a trace")
//                    }
//
//                    Button {
//                        buildSpans2()
//                    } label: {
//                        Text("Create a saucy trace")
//                    }
//
//                    Button {
//                        //TODO: Build trace detail screen
//                    } label: {
//                        Text("Define your own trace")
//                    }
//
//                } header: {
//                    Text("Try some traces")
//                }

                
                // List of items after request
                if dataNotNil {
                    Section {
                        ForEach(requestResult!.data, id: \.fullName ) { park in
                            NavigationLink {
                                DetailView(park: park)
                            } label: {
                                Text(park.fullName)
                            }
                        }
                    } header: {
                        Text("\(requestResult!.data.count) Parks in " + requestedState)
                    }
                }
            }
            .navigationTitle(Text("Embrace Outdoors!"))

//                .padding()
//                .foregroundColor(.brandYellow)
//                .background(Color(.brandBlack))
//                .cornerRadius(10)

        } detail: {
            Text("Something Happened Here")
        }
    }
    
    //MARK: Networking
    func fetchEmbraceMockNSF() {
        
        let url = URL(string: "https://dash-api.embrace.io/mock/trace_forwarding")!
        var request = URLRequest(url: url)
        request.addValue(
            "00-c1ca9fb1491aabd3cc6b81606b124023-d7e035eb3aefa6f6-01",
            forHTTPHeaderField: "traceparent")
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, e in
            guard let _ = data,
                  let response = response else { return }
            print(response)
        }).resume()
        
    }

    func fetchNationalParkData() {
        let stateCode = states[selectedState] ?? ""
        let url = URL(
            string: "https://developer.nps.gov/api/v1/parks?stateCode=\(stateCode)&api_key=snTswDbB4TUdS3BjIh4TUoaJx56xXI0JKfU3kLZF"
        )!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(ParkRequestResult.self, from: data)
                DispatchQueue.main.async {
                    requestResult = decodedData
                    requestedState = selectedState
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func fetchForbiddenData() {
        // No API Key - 403 error
        let url = URL(string: "https://developer.nps.gov/api/v1/lessonplans")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            print(data)
        }.resume()
    }
    
    func fetchTimeout() {
        //Build timeout into URLSession
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 0.1
        sessionConfig.timeoutIntervalForResource = 0.1
        let session = URLSession(configuration: sessionConfig)
        let url = URL(
            string: "https://developer.nps.gov/api/v1/lessonplans?api_key=snTswDbB4TUdS3BjIh4TUoaJx56xXI0JKfU3kLZF"
        )!
        session.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                    print(data)
            }.resume()
        }
    
    //MARK: Tracing
    func buildSpans2() {
        guard let client = Embrace.client else {return}
        //start makin sawwwwce trace
        let trace = client
            .buildSpan(name: "Makin' Sunday Sawwwwce")
            .setStartTime(time: Date.now.addingTimeInterval(-24.0 * 60.0 * 60.0))
            .startSpan()
        
        // start choppin span
        let choppinParentSpan = client
            .buildSpan(name: "Choppin Groceries")
            .setParent(trace)
            .setStartTime(time: Date.now.addingTimeInterval(-24.0 * 60.0 * 60.0))
            .startSpan()
                
        // start choppin garlic span -> add weight attribute
        let choppinGarlicSpan = client
            .buildSpan(name: "Choppin Garlic")
            .setParent(choppinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-24.0 * 60.0 * 60.0))
            .startSpan()
        // end choppin garlic span
        choppinGarlicSpan.end(time: Date.now.addingTimeInterval(-23.5 * 60.0 * 60.0))
        
        // start choppin cherry span -> add weight attribute
        let choppinCherrySpan = client
            .buildSpan(name: "Choppin Cherry Tomatoes")
            .setParent(choppinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-23.5 * 60.0 * 60.0))
            .startSpan()
        
        // end choppin spans
        choppinCherrySpan.end(time: Date.now.addingTimeInterval(-23.0 * 60.0 * 60.0))
        choppinParentSpan.end(time: Date.now.addingTimeInterval(-23.0 * 60.0 * 60.0))
        
        // start stirring span
        let stirrinParentSpan = client
            .buildSpan(name: "Stirrin Sauce")
            .setParent(trace)
            .setStartTime(time: Date.now.addingTimeInterval(-23.0 * 60.0 * 60.0))
            .startSpan()
        
        // start stirring garlic span
        let stirrinGarlicSpan = client
            .buildSpan(name: "Stirrin Garlic")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-23.0 * 60.0 * 60.0))
            .startSpan()
        // end stirring garlic span
        stirrinGarlicSpan.end(time: Date.now.addingTimeInterval(-22.7 * 60.0 * 60.0))
        
        // start stirring spice span
        let stirrinSpicesSpan = client
            .buildSpan(name: "Stirrin Spices")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-22.7 * 60.0 * 60.0))
            .startSpan()
        // end stirring spice span
        stirrinSpicesSpan.end(time: Date.now.addingTimeInterval(-22.5 * 60.0 * 60.0))
        
        // start stirring cherry span
        let stirrinCherrySpan = client
            .buildSpan(name: "Stirrin Cherry Tomatoes")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-22.5 * 60.0 * 60.0))
            .startSpan()
        // end stirring cherry span
        stirrinCherrySpan.end(time: Date.now.addingTimeInterval(-22.0 * 60.0 * 60.0))
        
        // start stirring canned tomatoes span -> add weight
        let stirrinCannedSpan = client
            .buildSpan(name: "Stirrin Canned Tomatoes")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-22.0 * 60.0 * 60.0))
            .startSpan()
        // end stirring canned tomatoes span
        stirrinCannedSpan.end(time: Date.now.addingTimeInterval(-18.5 * 60.0 * 60.0))
        
        // start stirring parm span -> add weight
        let stirrinParmSpan = client
            .buildSpan(name: "Stirrin Parm")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-18.5 * 60.0 * 60.0))
            .startSpan()
        // end stirring parm span
        stirrinParmSpan.end(time: Date.now.addingTimeInterval(-18.0 * 60.0 * 60.0))
        
        // start stirring basil span
        let stirrinBasilSpan = client
            .buildSpan(name: "Stirrin Basil")
            .setParent(stirrinParentSpan)
            .setStartTime(time: Date.now.addingTimeInterval(-18.0 * 60.0 * 60.0))
            .startSpan()
        // end stirring basil span
        stirrinBasilSpan.end(time: Date.now.addingTimeInterval(-17.7 * 60.0 * 60.0))
        // end stirring span
        stirrinParentSpan.end(time: Date.now.addingTimeInterval(-17.7 * 60.0 * 60.0))
        // end makin sawwwwce trace
        trace.end(time: Date.now.addingTimeInterval(-17.7 * 60.0 * 60.0))
    }
    
    func buildSpans() {
        guard let client = Embrace.client else {return}
        
        let span = client.buildSpan(
            name: "Opened Streaming Websocket",
            attributes: ["service-type" : "websocket"]
        ).markAsKeySpan()
        .startSpan()
        
        let childSpan = client
            .buildSpan(name: "Began Streaming Information Inside Websocket Span")
            .setStartTime(time: Date.now)
            .setParent(span)
            .markAsKeySpan()
            .startSpan()
        
        sleep(1)
        childSpan.addEvent(
            name: "Received streamed data",
            attributes: ["data-batch" : .int(1)],
            timestamp: Date.now
        )
        sleep(1)
        childSpan.addEvent(
            name: "Received streamed data",
            attributes: ["data-batch" : .int(2)],
            timestamp: Date.now
        )
        sleep(1)
        childSpan.addEvent(
            name: "Received streamed data",
            attributes: ["data-batch" : .int(3)],
            timestamp: Date.now
        )
        sleep(1)
        span.addEvent(
            name: "Received close notice",
            timestamp: Date.now
        )
        sleep(1)
        childSpan.end(time: Date.now)
        sleep(1)
        span.end(time: Date.now)
    }
}

#Preview {
    ContentView()
}
