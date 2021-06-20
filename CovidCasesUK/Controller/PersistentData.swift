//
//  PersistentData.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 19/06/2021.
//

import Foundation


class OptionsData {
    
    
    
    init() {
        
    }
    
    func isNotificationEnabled() -> Bool {
        return UserDefaults().bool(forKey: "uk.cases.notification")
    }
 
    func saveNotification(_ enabled: Bool) {
        UserDefaults().set(enabled, forKey: "uk.cases.notification")
    }
    
    func setNotificationDate(date: Date) {
        UserDefaults.standard.set(date, forKey: "uk.cases.notification.date")
    }
    
    func getNotificationTime() -> Date? {
        if let date = UserDefaults().object(forKey: "uk.cases.notification.date") as? Date {
            return date
        }
        return nil
    }
}
