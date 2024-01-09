import Foundation

extension Date {
    
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    /// Extension for Date to give the current year.
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
}

// Helper extension to generate a random Date within the past decade
extension Date {
    static func random(in range: ClosedRange<Int>) -> Date {
        let now = Date()
        let calendar = Calendar.current
        let year = Int.random(in: range)
        let dateComponents = DateComponents(year: year, month: Int.random(in: 1...12), day: Int.random(in: 1...28))
        return calendar.date(from: dateComponents) ?? now
    }
}
