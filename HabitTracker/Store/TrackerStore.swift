import CoreData
import UIKit

protocol TrackerStoreProtocol: AnyObject {
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData?
    func pinnedTracker(id: UUID)
    func getCategoryTitleForTrackerId(id: UUID) -> String?
    func removeTrackerForI(id: UUID)
    func getAllTrackers() -> [Tracker]?
}

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}


extension TrackerStore: TrackerStoreProtocol {
    func getAllTrackers() -> [Tracker]? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")

        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            let trackers = trackersCoreData.compactMap { trackerCoreData -> Tracker? in
                guard let id = trackerCoreData.id,
                      let emoji = trackerCoreData.emoji,
                      let name = trackerCoreData.name,
                      let schedule = trackerCoreData.schedule as? [WeekDay],
                      let color = UIColor(hex: trackerCoreData.color ?? "")
                else { return nil }

                return Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: trackerCoreData.isPinned, schedule: schedule)
            }
            
            return trackers.isEmpty ? nil : trackers
        } catch {
            return nil
        }
    }

    
    func removeTrackerForI(id: UUID) {
        guard let trackerCoreData = getTrackerCoreDataForId(id: id) else { return }
        context.delete(trackerCoreData)
        try? context.save()
    }
    
    func getCategoryTitleForTrackerId(id: UUID) -> String? {
        guard let trackerCoreData = getTrackerCoreDataForId(id: id) else { return nil }
        return trackerCoreData.category?.title
    }
    
    func addNewTracker(category: TrackerCategoryCoreData, tracker: Tracker) throws {
        if let trackerCoreDataAlreadyExist = getTrackerCoreDataForId(id: tracker.id) {
            let schedule = tracker.schedule as NSObject
            trackerCoreDataAlreadyExist.name = tracker.name
            trackerCoreDataAlreadyExist.id = tracker.id
            trackerCoreDataAlreadyExist.emoji = tracker.emoji
            trackerCoreDataAlreadyExist.color = tracker.color.hexString
            trackerCoreDataAlreadyExist.schedule = schedule
            trackerCoreDataAlreadyExist.isPinned = tracker.isPinned
            trackerCoreDataAlreadyExist.category = category
            do {
                try context.save()
            } catch {
                print("[addNewTracker]: error while edit tracker")
            }
            
            return
            
        } else {
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
    }
    
    func getTrackerCoreDataForId(id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackers = try? context.fetch(fetchRequest)
        let currentTracker = trackers?.first(where: {
            $0.id == id
        })
        return currentTracker
    }
    
    func pinnedTracker(id: UUID) {
        let trackerCoreData = getTrackerCoreDataForId(id: id)
        guard let trackerIsPinned = trackerCoreData?.isPinned else { return }
        trackerCoreData?.isPinned = !trackerIsPinned
        do {
            try context.save()
        } catch {
            return
        }
    }
}
