import UIKit
import CoreData

public class CoreDataManager {

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "News_reader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private func getContext () throws -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    public func fetchNews() throws -> [News] {
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        var fetchResult: [News] = []

        do {
            fetchResult = try getContext().fetch(fetchRequest)
        } catch let error as CustomError {
            throw error
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
        return fetchResult
    }

    public func saveNews(title: String, description: String, url: String) throws {
        var managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        do {
            try managedContext = getContext()
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
            throw CustomError(title: "CoreData", description: "Can't get context")
        }
        
        let news = NSManagedObject(entity: entity, insertInto: managedContext)

        news.setValue(title, forKey: "title")
        news.setValue(description, forKey: "descr")
        news.setValue(url, forKey: "url")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    public func deleteOldRecords() throws {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try getContext().execute(deleteRequest)
            try getContext().save()
        } catch let error as CustomError {
            throw error
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
    }
}
