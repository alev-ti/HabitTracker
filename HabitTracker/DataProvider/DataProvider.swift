import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    func addTrackerCategory(title: String)
    func addTracker(categoryTitle: String, tracker: Tracker)
    func removeTracker(id: UUID)
    func getAllTrackers() -> [Tracker]
    
    func getAllTrackerCategory() -> [TrackerCategory]?
    func pinnedTracker(id: UUID)
    func getCategoryTitleForTrackerId(id: UUID) -> String?
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class DataProvider: NSObject {
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        guard let delegate = delegate, let context = self.context else {
            assertionFailure("Delegate or context is nil")
            return nil
        }
        return TrackerCategoryStore(context: context, delegate: delegate)
    }()
    private lazy var trackerStore: TrackerStoreProtocol = {
        guard let context = self.context else {
            assertionFailure("Context is nil")
            return TrackerStore(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
        return TrackerStore(context: context)
    }()
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = {
        guard let context = self.context else {
            assertionFailure("Context is nil")
            return TrackerRecordStore(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
        return TrackerRecordStore(context: context)
    }()
    
    private weak var delegate: DataProviderDelegate?
    private var context: NSManagedObjectContext? {
        return persistentContainer?.viewContext
    }
    
    var persistentContainer: NSPersistentContainer?
    
    init(delegate: DataProviderDelegate) {
        let container = NSPersistentContainer(name: "HabitTracker")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.persistentContainer = container
        self.delegate = delegate
    }
}

// MARK: - DataProviderProtocol

extension DataProvider: DataProviderProtocol {
    func getAllTrackers() -> [Tracker] {
        return trackerStore.getAllTrackers() ?? []
    }
    
    func removeTracker(id: UUID) {
        trackerStore.removeTrackerForI(id: id)
    }
    
    func getCategoryTitleForTrackerId(id: UUID) -> String? {
        return trackerStore.getCategoryTitleForTrackerId(id: id)
    }
    
    func pinnedTracker(id: UUID) {
        trackerStore.pinnedTracker(id: id)
    }
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        if let trackerCoreDataIsExist = trackerStore.getTrackerCoreDataForId(id: tracker.id) {
            try? trackerRecordStore.addNewRecord(trackerCoreData: trackerCoreDataIsExist, trackerRecord: trackerRecord)
        }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        guard let trackerRecords = trackerRecordStore.getAllRecords() else  { return [] }
        return trackerRecords
    }
    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.removeRecord(tracker: tracker, trackerRecord: trackerRecord)
    }
    
    func addTrackerCategory(title: String) {
        guard let trackerCategoryStore else { return }
        trackerCategoryStore.addTrackerCategory(title: title)
    }
    
    func addTracker(categoryTitle: String, tracker: Tracker) {
        guard let trackerCategoryStore else { return }
        if let categoryIsExist = trackerCategoryStore.checkCategoryExistence(categoryTitle: categoryTitle) {
            do {
                try trackerStore.addNewTracker(category: categoryIsExist, tracker: tracker)
                print("[addTracker]: Трекер добавлен в существующую категорию")
            } catch {
                print("[addTracker]: Не удалось добавить трекер к категории")
            }
            delegate?.didUpdate()
            return
        } else {
            let trackerCategory = TrackerCategoryCoreData(context: self.context!)
            trackerCategory.title = categoryTitle
            try? context!.save()
            do {
                try trackerStore.addNewTracker(category: trackerCategory, tracker: tracker)
                print("[addTracker]: Новая категория и трекер добавлены")
            } catch {
                print("[addTracker]: Не удалось добавить трекер к категории")
            }
        }
    }
    
    func getAllTrackerCategory() -> [TrackerCategory]? {
        guard let trackerCategoryStore else { return nil }
        return trackerCategoryStore.getAllTrackerCategory()
    }
}
