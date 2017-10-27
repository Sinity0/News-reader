import UIKit
import CoreData

class CoreDataManager {

    func getContext () -> NSManagedObjectContext {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func fetchNews() throws -> [News] {

        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        var fetchResult: [News] = []

        do {
            fetchResult = try getContext().fetch(fetchRequest)
        } catch {
            print("Fetch request error: \(error)")
        }
        return fetchResult
    }

    func saveNews(title: String, description: String, url: String) throws {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
            return
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

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw CustomError(title: "CoreData", description: "Can't get AppDelegate")
        }

        let context = appDelegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            throw CustomError(title: "CoreData", description: error.localizedDescription)
        }
    }
}
