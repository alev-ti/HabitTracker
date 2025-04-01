import Foundation

enum WeekDay: String, CaseIterable, Codable, Comparable {
    
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    init?(from string: String) {
        self.init(rawValue: string)
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        return order(lhs) < order(rhs)
    }
    
    private static func order(_ day: WeekDay) -> Int {
        switch day {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    var localized: String {
        switch self {
        case .monday:
            return NSLocalizedString("schedule.monday", comment: "monday")
        case .tuesday:
            return NSLocalizedString("schedule.tuesday", comment: "tuesday")
        case .wednesday:
            return NSLocalizedString("schedule.wednesday", comment: "wednesday")
        case .thursday:
            return NSLocalizedString("schedule.thursday", comment: "thursday")
        case .friday:
            return NSLocalizedString("schedule.friday", comment: "friday")
        case .saturday:
            return NSLocalizedString("schedule.saturday", comment: "saturday")
        case .sunday:
            return NSLocalizedString("schedule.sunday", comment: "sunday")
        }
    }

    func getShortName() -> String {
        switch self {
        case .monday:
            return NSLocalizedString("schedule.monday_short", comment: "Mon")
        case .tuesday:
            return NSLocalizedString("schedule.tuesday_short", comment: "Tue")
        case .wednesday:
            return NSLocalizedString("schedule.wednesday_short", comment: "Wed")
        case .thursday:
            return NSLocalizedString("schedule.thursday_short", comment: "Thu")
        case .friday:
            return NSLocalizedString("schedule.friday_short", comment: "Fri")
        case .saturday:
            return NSLocalizedString("schedule.saturday_short", comment: "Sat")
        case .sunday:
            return NSLocalizedString("schedule.sunday_short", comment: "Sun")
        }
    }
}
