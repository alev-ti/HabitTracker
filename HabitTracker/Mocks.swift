import Foundation

// Моки данных
let mockCategories: [TrackerCategory] = [
    TrackerCategory(
        title: "Домашний уют",
        trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: .systemGreen, emoji: "🌱", schedule: [.Monday, .Wednesday])
        ]
    ),
    TrackerCategory(
        title: "Радостные мелочи",
        trackers: [
            Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .systemYellow, emoji: "🐱", schedule: [.Tuesday, .Thursday, .Sunday]),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсап", color: .systemOrange, emoji: "💌", schedule: [.Saturday, .Sunday])
        ]
    )
]

