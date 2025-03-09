import CoreData

protocol TrackerRecordStoreProtocol: AnyObject {
    func addNewRecord(trackerCoreData: TrackerCoreData, trackerRecord: TrackerRecord) throws
    func getAllRecords() -> [TrackerRecord]?
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private lazy var trackerStore: TrackerStore = TrackerStore(context: self.context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}


extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addNewRecord(trackerCoreData: TrackerCoreData, trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    func getAllRecords() -> [TrackerRecord]? {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let trackerRecordsCoreData = try context.fetch(fetchRequest)
            let trackerRecords: [TrackerRecord] = trackerRecordsCoreData.compactMap {
                guard let id = $0.tracker?.id, let dateOfCompletion = $0.date else {
                    return nil
                }
                return TrackerRecord(id: id, date: dateOfCompletion)
            }
            return trackerRecords.isEmpty ? nil : trackerRecords
        } catch {
            return nil
        }
    }

    
    func removeRecord(tracker: Tracker, trackerRecord: TrackerRecord) throws {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordsCoreData = try? context.fetch(fetchRequest)
        
        if let currentRecord = trackerRecordsCoreData?.first(where: {
            guard let dateOfCompletion = $0.date else { return false }
            return $0.tracker?.id == tracker.id && Calendar.current.isDate(dateOfCompletion, inSameDayAs: trackerRecord.date)
        }) {
            context.delete(currentRecord)
            try? context.save()
        } else {
            print("Запись не найдена")
        }
    }
}
