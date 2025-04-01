import Foundation

protocol StatisticsProviding {
    var bestPeriod: Int { get }
    var perfectDays: Int { get }
    var trackersCompleted: Int { get }
    var averageValue: Double { get }
    
    func store(allTrackerCategories: [TrackerCategory], allTrackerRecords: [TrackerRecord])
}

final class StatisticsProvider: StatisticsProviding {
    
    private let userDefaults = UserDefaults.standard
    
    var bestPeriod: Int {
        get { userDefaults.integer(forKey: "bestPeriod") }
        set { userDefaults.setValue(newValue, forKey: "bestPeriod") }
    }
    
    var perfectDays: Int {
        get { userDefaults.integer(forKey: "perfectDays") }
        set { userDefaults.setValue(newValue, forKey: "perfectDays") }
    }
    
    var trackersCompleted: Int {
        get { userDefaults.integer(forKey: "trackersCompleted") }
        set { userDefaults.setValue(newValue, forKey: "trackersCompleted") }
    }
    
    var averageValue: Double {
        get { userDefaults.double(forKey: "averageValue") }
        set { userDefaults.setValue(newValue, forKey: "averageValue") }
    }
    
    func store(allTrackerCategories: [TrackerCategory], allTrackerRecords: [TrackerRecord]) {
        let allTrackers = allTrackerCategories.flatMap { $0.trackers }
        perfectDays = calculatePerfectDays(trackers: allTrackers, records: allTrackerRecords)
        bestPeriod = calculateBestPeriod(trackers: allTrackers, records: allTrackerRecords)
        trackersCompleted = allTrackerRecords.count
        averageValue = calculateAverageValue(trackers: allTrackers, records: allTrackerRecords)
    }
    
    private func calculateAverageValue(trackers: [Tracker], records: [TrackerRecord]) -> Double {
        guard !trackers.isEmpty, !records.isEmpty else { return 0 }
        
        var dateCounts: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let date = calendar.startOfDay(for: record.date)
            dateCounts[date, default: 0] += 1
        }
        
        let total = dateCounts.values.reduce(0, +)
        return Double(total) / Double(dateCounts.count)
    }
    
    private func calculateBestPeriod(trackers: [Tracker], records: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty, !records.isEmpty else { return 0 }
        
        var maxStreak = 0
        let calendar = Calendar.current
        
        for tracker in trackers {
            let trackerRecords = records
                .filter { $0.id == tracker.id }
                .sorted { $0.date < $1.date }
            
            var currentStreak = 1
            guard trackerRecords.count > 1 else {
                maxStreak = max(maxStreak, currentStreak)
                continue
            }
            
            for i in 1..<trackerRecords.count {
                let previousDate = trackerRecords[i - 1].date
                let currentDate = trackerRecords[i].date
                
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: previousDate) else {
                    continue
                }
                
                if calendar.isDate(currentDate, inSameDayAs: nextDate) {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
            
            maxStreak = max(maxStreak, currentStreak)
        }
        
        return maxStreak
    }
    
    private func calculatePerfectDays(trackers: [Tracker], records: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty, !records.isEmpty else { return 0 }
        
        var completionsByDay: [Date: [UUID]] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let dateWithoutTime = calendar.startOfDay(for: record.date)
            completionsByDay[dateWithoutTime, default: []].append(record.id)
        }
        
        return completionsByDay.reduce(0) { count, entry in
            let (date, completedTrackers) = entry
            
            guard let dayOfWeek = getDayOfWeek(from: date) else { return count }
            
            let nonRegularTrackers = trackers.filter { $0.schedule.isEmpty }
            let scheduledTrackers = trackers.filter { $0.schedule.contains(dayOfWeek) }
            
            let allScheduledCompleted = scheduledTrackers.allSatisfy { completedTrackers.contains($0.id) }
            let allNonRegularCompleted = nonRegularTrackers.allSatisfy { tracker in
                records.contains { $0.id == tracker.id }
            }
            
            return count + ((allScheduledCompleted && allNonRegularCompleted && (!scheduledTrackers.isEmpty || !nonRegularTrackers.isEmpty)) ? 1 : 0)
        }
    }
    
    private func getDayOfWeek(from date: Date) -> WeekDay? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "EEEE"
        return WeekDay(from: formatter.string(from: date))
    }
}
