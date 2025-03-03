import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    func addTrackerCategory(categoryHeader: String)
    func addTracker(categoryHeader: String, tracker: Tracker)
    
    func getAllTrackerCategory() -> [TrackerCategory]?
    
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class DataProvider: NSObject {
    
    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        guard let delegate = delegate else { return nil }
        trackerCategoryStore = TrackerCategoryStore(context: self.context, delegate: delegate)
        return trackerCategoryStore
        
    }()
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore(context: self.context)
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore(context: self.context)
    
    private weak var delegate: DataProviderDelegate?
    private let context: NSManagedObjectContext
    
    var persistentContainer: NSPersistentContainer!
    
    init(delegate: DataProviderDelegate) {
        let container = NSPersistentContainer(name: "HabitTracker")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.persistentContainer = container
        self.context = persistentContainer.viewContext
        self.delegate = delegate
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


extension DataProvider: DataProviderProtocol {
    func addNewRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        if let trackerCoreDataIsExist = trackerStore.getTrackerCoreDataForId(id: tracker.id) {
            do {
                try trackerRecordStore.addNewRecord(trackerCoreData: trackerCoreDataIsExist, trackerRecord: trackerRecord)
            } catch {
                print("failed to addNewRecord")
            }
        }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        guard let trackerRecords = trackerRecordStore.getAllRecords() else  { return [] }
        return trackerRecords
    }
    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.removeRecord(tracker: tracker, trackerRecord: trackerRecord)
    }
    
    func addTrackerCategory(categoryHeader: String) {
        guard let trackerCategoryStore else { return }
        trackerCategoryStore.addTrackerCategory(categoryHeader: categoryHeader)
    }
    
    func addTracker(categoryHeader: String, tracker: Tracker) {
        guard let trackerCategoryStore else { return }
        if let categoryIsExist = trackerCategoryStore.checkCategoryExistence(categoryHeader: categoryHeader) {
            do {
                try trackerStore.addNewTracker(category: categoryIsExist, tracker: tracker)
                print("Новая категория и трекер добавлены")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
            return
        } else {
            let trackerCategory = TrackerCategoryCoreData(context: self.context)
            trackerCategory.title = categoryHeader
            try? context.save()
            do {
                try trackerStore.addNewTracker(category: trackerCategory, tracker: tracker)
                print("Новая категория и трекер добавлены")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
        }
    }
    
    func getAllTrackerCategory() -> [TrackerCategory]? {
        guard let trackerCategoryStore else { return nil }
        return trackerCategoryStore.getAllTrackerCategory()
    }
}
