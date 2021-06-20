//
//  Case.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 14/06/2021.
//

import Foundation

struct UKCases: Codable {
    let length: Int
    let maxPageLimit: Int
    let totalRecords: Int
    let data: [Data]
}

struct Data: Codable {
    let date: String
    let newCases: Int
    let newDeaths28DaysByPublishDate: Int?
}
