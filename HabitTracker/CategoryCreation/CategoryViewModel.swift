import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    var categoriesBinding: Binding<[TrackerCategory]>? { get set }
    var trackerCategories: [TrackerCategory] { get }
    func addNewCategory(title: String)
    func trackerCategoriesCount() -> Int
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    private(set) var trackerCategories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(trackerCategories)
        }
    }
    
    var categoriesBinding: Binding<[TrackerCategory]>?
    
    private lazy var dataProvider: DataProviderProtocol = {
        DataProvider(delegate: self)
    }()
    
    init() {
        fetchTrackerCategories()
    }
    
    func addNewCategory(title: String) {
        dataProvider.addTrackerCategory(title: title)
    }
    
    func trackerCategoriesCount() -> Int {
        trackerCategories.count
    }
    
    private func fetchTrackerCategories() {
        trackerCategories = dataProvider.getAllTrackerCategory() ?? []
    }
}

// MARK: - DataProviderDelegate

extension CategoryViewModel: DataProviderDelegate {
    func didUpdate() {
        fetchTrackerCategories()
    }
}
