import Foundation

enum WeekDay: String, CaseIterable, Codable {
    
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    case Sunday = "Sunday"
    
    init?(from string: String) {
        self.init(rawValue: string)
    }

    var localized: String {
        switch self {
        case .Monday:
            return NSLocalizedString("schedule.monday", comment: "monday")
        case .Tuesday:
            return NSLocalizedString("schedule.tuesday", comment: "tuesday")
        case .Wednesday:
            return NSLocalizedString("schedule.wednesday", comment: "wednesday")
        case .Thursday:
            return NSLocalizedString("schedule.thursday", comment: "thursday")
        case .Friday:
            return NSLocalizedString("schedule.friday", comment: "friday")
        case .Saturday:
            return NSLocalizedString("schedule.saturday", comment: "saturday")
        case .Sunday:
            return NSLocalizedString("schedule.sunday", comment: "sunday")
        }
    }

    func getShortName() -> String {
        switch self {
        case .Monday:
            return NSLocalizedString("schedule.monday_short", comment: "Mon")
        case .Tuesday:
            return NSLocalizedString("schedule.tuesday_short", comment: "Tue")
        case .Wednesday:
            return NSLocalizedString("schedule.wednesday_short", comment: "Wed")
        case .Thursday:
            return NSLocalizedString("schedule.thursday_short", comment: "Thu")
        case .Friday:
            return NSLocalizedString("schedule.friday_short", comment: "Fri")
        case .Saturday:
            return NSLocalizedString("schedule.saturday_short", comment: "Sat")
        case .Sunday:
            return NSLocalizedString("schedule.sunday_short", comment: "Sun")
        }
    }
}
