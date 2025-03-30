import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    var isPinned: Bool
    let schedule: [WeekDay]
}

