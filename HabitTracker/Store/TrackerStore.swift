import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData?
}

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}


extension TrackerStore: TrackerStoreProtocol {
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let schedule = tracker.schedule as NSObject
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.schedule = schedule
        trackerCoreData.category = category
        try context.save()
    }
    
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackers = try? context.fetch(fetchRequest)
        let currentTracker = trackers?.first(where: {
            $0.id == id
        })
        return currentTracker
    }
}
