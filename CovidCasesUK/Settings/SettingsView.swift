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
    @State private var areaName: String = ""
    private let notification = NotificationController()
    let options: OptionsData
    
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
            Section(header: Text("Area"), content: {
                TextField("England, Bromley, ...", text: $areaName)
                    .modifier(ClearButton(text: $areaName))
                    .font(.system(size: 18))
             
                
            })
            .onChange(of: areaName, perform: { value in
                self.options.saveAreaName(value.trimmingCharacters(in: .whitespacesAndNewlines))
            })
        }
        .navigationBarTitle(Text("Settings")).font(.largeTitle)
        .onAppear(perform: {
            self.isNotificationEnable = options.isNotificationEnabled()
            self.notificationDate = options.getNotificationTime() ?? Date()
            self.areaName = options.getAreaName() ?? ""
        })
    }
}

struct ClearButton: ViewModifier
{
    @Binding var text: String

    public func body(content: Content) -> some View
    {
        HStack
        {
            content

            if !text.isEmpty
            {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}
