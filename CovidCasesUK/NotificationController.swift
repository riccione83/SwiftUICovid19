//
//  NotificationController.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 14/06/2021.
//

import Foundation
import SwiftUI


class NotificationController {
    
    func removeLocalNotification()  {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["coviduk.cases.notification"])
    }
    
    func setUpLocalNotification(_ date: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "Covid UK cases"
                notificationContent.body = "Read the new covid-19 cases around the UK"
                notificationContent.badge = NSNumber(value: 1)
                notificationContent.sound = .default
                let calendar = Calendar.current
                var datComp = DateComponents()
                datComp.hour = calendar.component(.hour, from: date)
                datComp.minute = calendar.component(.minute, from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
                let request = UNNotificationRequest(identifier: "coviduk.cases.notification", content: notificationContent, trigger: trigger)
                                UNUserNotificationCenter.current().add(request) { (error : Error?) in
                                    if let theError = error {
                                        print(theError.localizedDescription)
                                    }
                                }
                
                print("Notification set")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }

        
    }
    
}
