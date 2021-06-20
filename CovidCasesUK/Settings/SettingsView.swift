//
//  SettingsView.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 19/06/2021.
//

import SwiftUI

struct SettingsView: View {
    @State private var isNotificationEnable = false
    @State private var notificationDate = Date()
    private let notification = NotificationController()
    private let options = OptionsData()
    
    var body: some View {
        Form {
            Section(header: Text("Notifications"), content: {
                Toggle(isOn: $isNotificationEnable, label: {
                    Text("Enable notifications")
                        .font(.system(size: 18))
                })

                DatePicker("Notify at", selection: $notificationDate, displayedComponents: .hourAndMinute).font(.system(size: 18))
                    .disabled(!isNotificationEnable)
            })
            .onChange(of: isNotificationEnable, perform: { value in
                options.saveNotification(value)
                if(value) {
                    self.notification.setUpLocalNotification(notificationDate)
                    options.setNotificationDate(date: notificationDate)
                } else {
                    self.notification.removeLocalNotification()
                }
            })
            .onChange(of: notificationDate, perform: { value in
                if(isNotificationEnable) {
                    self.options.setNotificationDate(date: value)
                    self.notification.removeLocalNotification()
                    self.notification.setUpLocalNotification(notificationDate)
                }
            })
        }
        .navigationBarTitle(Text("Settings")).font(.largeTitle)
        .onAppear(perform: {
            self.isNotificationEnable = options.isNotificationEnabled()
            self.notificationDate = options.getNotificationTime() ?? Date()
        })
    }
}
