//
//  Network.swift
//  SwiftUITest1
//
//  Created by Riccardo Rizzo on 25/05/2021.
//

import Foundation


protocol Network {
    func getCases()
    func fetch<T: Decodable>(url: String, completion: @escaping (T) -> ())
}

class NetworkRequest: NSObject, ObservableObject, Network {
    
    @Published var cases: UKCases?
    @Published var isLoading: Bool = false
    
    let baseUrl = "https://api.coronavirus.data.gov.uk/v1/data?filters=areaType=overview"
    let query = "&structure={\"date\":\"date\",\"newCases\":\"newCasesByPublishDate\", \"newDeaths28DaysByPublishDate\":\"newDeaths28DaysByPublishDate\"}".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    
    func getCases() {
        fetch(url: baseUrl + query, completion: { (cases: UKCases) in
            self.cases = cases
        })
    }
    
    func getCasesWithCompletition<T: Decodable>(completion: @escaping (T) -> ()) {
        fetch(url: baseUrl + query, completion: { (cases: UKCases) in
            completion(cases as! T)
        })
    }
    
    func fetch<T: Decodable>(url: String, completion: @escaping (T) -> ()) {
        
        guard let url = URL(string: url) else {
            print("Error in the url:", url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            return }
        self.isLoading = true
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let result = try! JSONDecoder().decode(T.self, from: data!)
            
            DispatchQueue.main.async {
                self.isLoading = false
                completion(result)
            }
        }
        .resume()
    }
}

class MockNetwork: NetworkRequest {
    override func fetch<T>(url: String, completion: @escaping (T) -> ()) where T : Decodable {
        return
    }
    
    override func getCases() {
        self.cases = nil
    }
    
    
}
