import UIKit
import CoreData

class CoreDataManager {

    func getContext () -> NSManagedObjectContext {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func saveNews(title: String, description: String, url: String) -> CustomError {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return CustomError(title: "Core Data", description: "Can't get AppDelegate instance.")
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
            return CustomError(title: "CoreDate", description: "Can't get entity.")
        }
        
        let news = NSManagedObject(entity: entity, insertInto: managedContext)

        news.setValue(title, forKey: "title")
        news.setValue(description, forKey: "descr")
        news.setValue(url, forKey: "url")

        do {
            try managedContext.save()
        } catch let error as NSError {
            return CustomError(title: "CoreData", description: error.localizedDescription)
        }
        return CustomError(title: "CoreData", description: "Something went wrong.")
    }

    func deleteOldRecords() {

        let deleteFetch: NSFetchRequest<News> = News.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try getContext().execute(deleteRequest)
            try getContext().save()
        } catch {
            print("Error when deleting old records: \(error)")
        }
    }
}
