import UIKit
import CoreData

public class CoreDataManager {

    static let sharedInstance = CoreDataManager()

    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "News_reader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    public func saveContext () {
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

    public func fetchNews() throws -> [News] {
        let managedContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        var fetchResult: [News] = []

        do {
            fetchResult = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            throw AttributedError(title: "CoreData", description: error.localizedDescription)
        }
        return fetchResult
    }

    func isExist(context: NSManagedObjectContext, title: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", "title", title)

        let res = try! context.count(for: fetchRequest)
        return res > 1 ? true : false
    }

    public func saveNews(data: News) throws {
        let managedContext = persistentContainer.viewContext
        if !isExist(context: managedContext, title: data.title!) {
            guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
                throw AttributedError(title: "CoreData", description: "Can't get context")
            }

            let news = NSManagedObject(entity: entity, insertInto: managedContext)

            news.setValue(data.title, forKey: "title")
            news.setValue(data.descr, forKey: "descr")
            news.setValue(data.url, forKey: "url")

            do {
                try managedContext.save()
            } catch let error as AttributedError {
                throw error
            } catch let error as NSError {
                throw AttributedError(title: "CoreData", description: error.localizedDescription)
            }
        }
    }
}
