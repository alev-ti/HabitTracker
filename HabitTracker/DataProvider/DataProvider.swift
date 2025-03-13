import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    func addTrackerCategory(title: String)
    func addTracker(categoryTitle: String, tracker: Tracker)
    
    func getAllTrackerCategory() -> [TrackerCategory]?
    
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
    
    func saveContext() {
        guard let context = persistentContainer?.viewContext else {
            assertionFailure("persistentContainer is nil")
            return
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
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
    
    func addTrackerCategory(title: String) {
        guard let trackerCategoryStore else { return }
        trackerCategoryStore.addTrackerCategory(title: title)
    }
    
    func addTracker(categoryTitle: String, tracker: Tracker) {
        guard let trackerCategoryStore = trackerCategoryStore, let context = context else {
            assertionFailure("trackerCategoryStore or context is nil")
            return
        }
        if let categoryIsExist = trackerCategoryStore.checkCategoryExistence(categoryTitle: categoryTitle) {
            do {
                try trackerStore.addNewTracker(category: categoryIsExist, tracker: tracker)
                print("Новая категория и трекер добавлены")
            } catch {
                print("Не удалось добавить трекер к категории")
            }
            return
        } else {
            let trackerCategory = TrackerCategoryCoreData(context: context)
            trackerCategory.title = categoryTitle
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
