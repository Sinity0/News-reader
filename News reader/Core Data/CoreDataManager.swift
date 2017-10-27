import UIKit
import CoreData

class CoreDataManager {

    func getContext () throws -> NSManagedObjectContext {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw CustomError(title: "CoreData", description: "Can't get AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }

    func fetchNews() throws -> [News] {

        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        var fetchResult: [News] = []

        do {
            fetchResult = try getContext().fetch(fetchRequest)
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
        return fetchResult
    }

    func saveNews(title: String, description: String, url: String) throws {

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

    func deleteOldRecords() throws {

        var managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        do {
            try managedContext = getContext()
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
    }
}
