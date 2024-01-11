import Foundation
import SwiftUI

struct DecadePickerView: View {
    @Binding var selectedDecade: Double
    let startYear: Int
    let endYear: Int
    let step: Int
    
    var body: some View {
        VStack {
            Text("Decade: \(String(format: "%d", Int(selectedDecade)))'s").font(.headline)
            Picker(selection: $selectedDecade, label: Text("Decade")) {
                ForEach(Array(stride(from: startYear, to: endYear + 1, by: step)), id: \.self) { year in
                    Text("\(String(format: "%d", year))'s").tag(Double(year))
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}


#Preview {
    DecadePickerView(selectedDecade: .constant(1990), startYear: 1860, endYear: 2024, step: 10)
}
