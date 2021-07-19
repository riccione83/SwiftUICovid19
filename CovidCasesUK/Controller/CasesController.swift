//
//  CasesController.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 14/06/2021.
//

import Foundation
import SwiftUI

class CasesController:ObservableObject {
    
    @Published var allCases: UKCases?
    @Published var todayCases: Data?
    @Published var yesterdayCases: Data?
    @Published var error = false
    
    var network: NetworkRequest
    
    init(network: NetworkRequest) {
        self.network = network 
    }
    
    func isLoading() -> Bool {
        return network.isLoading
    }
    
    func refreshData(_ areaName: String?) {
        self.network.getCasesWithCompletition(areaName) { (data: UKCases?) in
            if let data = data {
                self.error = false
                self.allCases = data
                let today = Date()
                let yesterday = today.dayBefore
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.todayCases = self.allCases?.data.first {$0.date == formatter.string(from: today)}
                self.yesterdayCases = self.allCases?.data.first {$0.date == formatter.string(from: yesterday)}
            } else {
                self.error = true
            }
        }
    }
}
