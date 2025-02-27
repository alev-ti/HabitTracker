import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalid
}

protocol TrackerCategoryStoreProtocol: AnyObject {
    func getAllTrackerCategory() -> [TrackerCategory]?
    func checkCategoryExistence(categoryHeader: String) -> TrackerCategoryCoreData?
    func addTrackerCategory(categoryHeader: String)
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.title),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private weak var delegate: DataProviderDelegate?
    
    init(context: NSManagedObjectContext, delegate: DataProviderDelegate) {
        self.context = context
        self.delegate = delegate
    }
    
    private func convertObjectInTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        guard let trackersSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalid
        }
        
        do {
            let trackers = try trackersSet.map{
                guard let id = $0.id,
                      let name = $0.name,
                      let emoji = $0.emoji,
                      let schedule = $0.schedule as? [WeekDays] else {throw TrackerCategoryStoreError.decodingErrorInvalid}
                
                guard let colorString = $0.color, let color = UIColor(hex: colorString) else {
                    throw TrackerCategoryStoreError.decodingErrorInvalid
                }

                return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule )
            }
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}


extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getAllTrackerCategory() -> [TrackerCategory]? {
        let trackerCategoryArray = fetchedResultsController.fetchedObjects?.compactMap {
            do {
                return try convertObjectInTrackerCategory(from: $0)
            } catch {
                return nil
            }
        }
        return trackerCategoryArray
    }
    
    func checkCategoryExistence(categoryHeader: String) -> TrackerCategoryCoreData? {
        if let categoryAlreadyExists = fetchedResultsController.fetchedObjects?.first(where: { $0.title == categoryHeader}) {
            return categoryAlreadyExists
        }
        return nil
    }
    
    func addTrackerCategory(categoryHeader: String) {
        guard let fetchedCategory = fetchedResultsController.fetchedObjects else { return }
        if fetchedCategory.contains(where: { $0.title == categoryHeader }) {
            return
        }
        let trackerCategory = TrackerCategoryCoreData(context: context)
        trackerCategory.title = categoryHeader
        do {
            try context.save()
            print("Категория сохранилась")
        } catch {
            print("Не удалось сохранить категорию")
        }
    }
}


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
