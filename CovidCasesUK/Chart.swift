//
//  Chart.swift
//  CovidCasesUK
//
//  Created by Riccardo Rizzo on 20/06/2021.
//

import SwiftUI
import SwiftUICharts

struct Chart: View {
    
    let data: [Data]
    
    var body: some View {
       
            let barChartStyleNeonBlueDark = ChartStyle(
                backgroundColor: Color(UIColor.systemBackground),
                accentColor: Colors.GradientNeonBlue,
                secondGradientColor: Colors.GradientPurple,
                textColor: Color.primary,
                legendTextColor: Color.primary,
                dropShadowColor: Color.primary)
            
            let d: [Double] = data.map { data in
                Double(data.newCases)
            }
            LineView(data: d, style: barChartStyleNeonBlueDark)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    
}

struct Chart_Previews: PreviewProvider {
    static var previews: some View {
        let data: [Data] = [Data(date: "16-10-2021", newCases: 10, newDeaths28DaysByPublishDate: nil),Data(date: "17-10-2021", newCases: 20, newDeaths28DaysByPublishDate: nil)]
        Chart(data: data)
    }
}
