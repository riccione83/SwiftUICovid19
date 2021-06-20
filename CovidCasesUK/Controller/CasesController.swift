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
    
    var network: NetworkRequest
    
    init(network: NetworkRequest) {
        self.network = network 
    }
    
    func isLoading() -> Bool {
        return network.isLoading
    }
    
    func refreshData() {
        self.network.getCasesWithCompletition { (data: UKCases) in
            self.allCases = data
            let today = Date()
            let yesterday = today.dayBefore
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.todayCases = self.allCases?.data.first {$0.date == formatter.string(from: today)}
            self.yesterdayCases = self.allCases?.data.first {$0.date == formatter.string(from: yesterday)}
        }
    }
}
