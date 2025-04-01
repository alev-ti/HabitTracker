import Foundation

final class FilterSelectionViewModel {
    
    let filterStateSavingService: FilterStateStorage = UserDefaultsFilterStateStorage()
    
    var cellData: [CategoryCellModel] = [
        CategoryCellModel(title: "Все трекеры"),
        CategoryCellModel(title: "Трекеры на сегодня"),
        CategoryCellModel(title: "Завершенные"),
        CategoryCellModel(title: "Не завершенные")
    ]
}

