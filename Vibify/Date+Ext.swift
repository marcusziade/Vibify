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
