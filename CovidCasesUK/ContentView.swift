//
//  ContentView.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 14/06/2021.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    
    private let options = OptionsData()
    
    @ObservedObject var network: NetworkRequest
    @ObservedObject var casesController: CasesController
    @State var todayCases: Data?
    @State var isOptionOpen = false
    @State var tabSelected = 0
    @State var percentDiffCases = 0
    @State var percentDeathsCase = 0
    
    init() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let _network = NetworkRequest()
        casesController = CasesController(network: _network)
        network = _network
    }
    func getToday() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyy"
        return formatter.string(from: today)
    }
    
    func share(numberOfCases: Int, difference: Int) {
        let data = "UK covid cases today: \(numberOfCases)\nFrom yesterday \(difference)"
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                if let yesterdayCases = casesController.yesterdayCases?.newCases, !casesController.error {
                    let yesterdayDeath = casesController.yesterdayCases?.newDeaths28DaysByPublishDate ?? 0
                    VStack {
                        
                        HStack {
                            Text("Today: \(getToday())")
                                .font(.subheadline)
                                .padding(.leading, 16)
                            Spacer()
                        }
                        Divider()
                            .padding(20.0)
                        Spacer()
                        VStack {
                            Text("Yesterday:")
                                .font(.caption)
                            Text("\(yesterdayCases)")
                                .font(.largeTitle)
                            HStack {
                                Text("Deaths:")
                                    .font(.footnote)
                                Text("\(yesterdayDeath)")
                                    .font(.footnote)
                            }
                        }
                        .padding(.bottom, 20.0)
                        VStack {
                            if let numberOfCases = casesController.todayCases?.newCases {
                                let todayDeath = casesController.todayCases?.newDeaths28DaysByPublishDate ?? 0
                                let difference = numberOfCases - yesterdayCases
                                
                                VStack {
                                    Text("New cases today:")
                                        .font(.caption)
                                    HStack {
                                        Text("\(numberOfCases)")
                                            .font(.system(size: 60))
                                        Button(action: {
                                            share(numberOfCases: numberOfCases, difference: difference)
                                        }) {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                    }
                                    
                                    HStack {
                                        Text("from Yesterday: \(difference)")
                                            .font(.subheadline)
                                        Image(systemName: difference > 0 ? "arrow.up.square.fill" : "arrow.down.square.fill")
                                            .foregroundColor( difference > 0 ? Color.red : Color.green)
                                    }
                                    HStack {
                                        Text("Deaths:")
                                            .font(.footnote)
                                        Text("\(todayDeath)")
                                            .font(.footnote)
                                    }
                                }
                                .onAppear(perform: {
                                    self.percentDiffCases = Int(Double(Double(difference) / Double(yesterdayCases)) * 100)
                                    self.percentDeathsCase = Int(Double(Double(todayDeath-yesterdayDeath) / Double(yesterdayDeath)) * 100)
                                })
                            } else {
                                Text("No updates for today")
                                    .font(.system(size: 30))
                            }
                        }
                        NavigationLink(destination: SettingsView(options: options), isActive: $isOptionOpen) {
                        }
                        
                        Spacer()
                        if casesController.isLoading() {
                            ProgressView()
                        }
                        
                        Divider()
                        
                        VStack {
                            
                            HStack(alignment: .center) {
                                Spacer()
                                Button(action: {
                                    self.tabSelected = 0
                                }) {
                                    Text("Overview")
                                        .fontWeight(self.tabSelected == 0 ? .bold : .none)
                                }
                                Spacer()
                                Button(action: {
                                    self.tabSelected = 1
                                }) {
                                    Text("Last 7 days")
                                        .fontWeight(self.tabSelected == 1 ? .bold : .none)
                                }
                                Spacer()
                                Button(action: {
                                    self.tabSelected = 2
                                }) {
                                    Text("All data")
                                        .fontWeight(self.tabSelected == 2 ? .bold : .none)
                                }
                                Spacer()
                                Button(action: {
                                    self.tabSelected = 3
                                }) {
                                    Text("All data list")
                                        .fontWeight(self.tabSelected == 3 ? .bold : .none)
                                }
                                Spacer()
                            }
                            Divider()
                            if let data = casesController.allCases?.data {
                                switch(tabSelected) {
                                case 0:
                                    HStack {
                                        Spacer()
                                        LineChartView(data: data.reversed().suffix(7).map {Double($0.newCases)}, title: "Cases", rateValue: self.percentDiffCases )
                                        Spacer()
                                        LineChartView(data: data.reversed().suffix(7).map {Double($0.newDeaths28DaysByPublishDate ?? 0)}, title: "Deaths", rateValue: self.percentDeathsCase)
                                        Spacer()
                                    }
                                    .frame(minHeight: UIScreen.main.bounds.size.height / 3)
                                case 1,2:
                                    let d = tabSelected == 1 ?  data.reversed().suffix(7) :  data.reversed()
                                    Chart(data: d)
                                        .frame(minHeight: UIScreen.main.bounds.size.height / 3)
                                default:
                                    
                                    List(data, id: \.date) { cases in
                                        HStack {
                                            let splitDate = cases.date.split(separator: "-")
                                            Text("\(splitDate.reversed().joined(separator: "-"))")
                                            Spacer()
                                            Text("\(cases.newCases)")
                                        }
                                    }
                                    .listStyle(InsetListStyle())
                                    
                                }
                            }
                            
                        }
                    }
                }
                else {
                    HStack {

                        if !casesController.error {
                            Text("Loading...")
                                .padding()
                                .onAppear(perform: {
                                    casesController.refreshData(options.getAreaName())
                                })
                            ProgressView()
                        } else {
                            VStack {
                                Text("Unable to load data")
                                Text("Please check your settings")
                                    .padding()
                                Button(action: {
                                    isOptionOpen.toggle()
                                }, label: {
                                    Text("Or tap here")
                                })
                                
                            }
                        }
                    }
                }
            }
            .onAppear(perform: {
                isOptionOpen = false
                casesController.refreshData(options.getAreaName())
            })
            .navigationTitle("Covid UK cases")
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: {
                                            casesController.refreshData(options.getAreaName())
                                            
                                        }, label: {
                                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                                .padding(.trailing, 10)
                                        })
                                        
                                        Button(action: {
                                            isOptionOpen = true
                                            
                                        }, label: {
                                            Image(systemName: "gearshape")
                                        })
                                        NavigationLink(destination: SettingsView(options: options), isActive: $isOptionOpen) {
                                        }
                                    })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        ContentView()
        
    }
}
