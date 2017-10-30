import UIKit
import CoreData

public class CoreDataManager {

    private lazy var persistentContainer: NSPersistentContainer = {
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
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
        return fetchResult
    }

    public func saveNews(title: String, description: String, url: String) throws {
        let managedContext = persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
            throw CustomError(title: "CoreData", description: "Can't get context")
        }
        
        let news = NSManagedObject(entity: entity, insertInto: managedContext)

        news.setValue(title, forKey: "title")
        news.setValue(description, forKey: "descr")
        news.setValue(url, forKey: "url")

        do {
            try managedContext.save()
        } catch let error as CustomError {
            throw error
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
    }
}
