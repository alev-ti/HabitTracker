import Foundation

final class StatisticsViewModel {
    
    private let statisticsService: StatisticsProviding
    private(set) var cellData: [CellData] = []
    
    init(statisticsService: StatisticsProviding) {
        self.statisticsService = statisticsService
        reloadAllData()
    }
    
    func reloadAllData() {
        guard hasValidStatistics else {
            cellData = []
            return
        }
        
        cellData = [
            CellData(title: "\(statisticsService.bestPeriod)", text: "Лучший период"),
            CellData(title: "\(statisticsService.perfectDays)", text: "Идеальные дни"),
            CellData(title: "\(statisticsService.trackersCompleted)", text: "Трекеров завершено"),
            CellData(title: String(format: "%.1f", statisticsService.averageValue), text: "Среднее значение")
        ]
    }
    
    private var hasValidStatistics: Bool {
        return statisticsService.bestPeriod > 0 ||
               statisticsService.perfectDays > 0 ||
               statisticsService.trackersCompleted > 0 ||
               statisticsService.averageValue > 0
    }
}

