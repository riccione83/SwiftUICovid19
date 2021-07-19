//
//  Network.swift
//  SwiftUITest1
//
//  Created by Riccardo Rizzo on 25/05/2021.
//

import Foundation


protocol Network {
    func getCases(_ area: String?)
    func fetch<T: Decodable>(url: String, completion: @escaping (T?, Bool) -> ())
}

class NetworkRequest: NSObject, ObservableObject, Network {
    
    @Published var cases: UKCases?
    @Published var isLoading: Bool = false
    
    let baseUrl = "https://api.coronavirus.data.gov.uk/v1/data?filters=areaType=overview"
    let query = "&structure={\"date\":\"date\",\"newCases\":\"newCasesByPublishDate\", \"newDeaths28DaysByPublishDate\":\"newDeaths28DaysByPublishDate\"}".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    
    private func buildURL(_ area: String?) -> String {
        guard area != nil,area != "", area != "England".lowercased() else {
            return baseUrl
        }
        return "https://api.coronavirus.data.gov.uk/v1/data?filters=areaType=utla;areaName=\(area!.lowercased())"
    }
    
    func getCases(_ area: String?) {
        fetch(url: buildURL(area) + query, completion: { (cases: UKCases?, error: Bool) in
            self.cases = cases
        })
    }
    
    func getCasesWithCompletition<T: Decodable>(_ area: String?, completion: @escaping (T?) -> ()) {
        fetch(url: buildURL(area) + query, completion: { (cases: UKCases?, error: Bool) in
                completion(cases as? T)
        })
    }
    
    func fetch<T: Decodable>(url: String, completion: @escaping (T?, Bool) -> ()) {
        
        guard let url = URL(string: url) else {
            print("Error in the url:", url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            DispatchQueue.main.async {
                self.isLoading = false
                completion(nil, false)
            }
            return
        }
        self.isLoading = true
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            do {
                let result = try JSONDecoder().decode(T.self, from: data!)
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(result, true)
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(nil, false)
                }
            }
        }
        .resume()
    }
}

class MockNetwork: NetworkRequest {
    override func fetch<T>(url: String, completion: @escaping (T?, Bool) -> ()) where T : Decodable {
        return
    }
    
    override func getCases(_ area: String?) {
        self.cases = nil
    }
    
    
}
