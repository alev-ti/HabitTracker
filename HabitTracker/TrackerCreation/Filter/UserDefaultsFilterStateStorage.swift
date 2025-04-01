import Foundation

protocol FilterStateStorage {
    var filterValue: Int { get }
    func store(filterValue: Int)
}

final class UserDefaultsFilterStateStorage: FilterStateStorage {
    
    private let userDefaults = UserDefaults.standard
    
    var filterValue: Int {
        get { userDefaults.integer(forKey: "selectedFilter") }
        set { userDefaults.setValue(newValue, forKey: "selectedFilter") }
    }
    
    func store(filterValue: Int) {
        self.filterValue = filterValue
    }
}
