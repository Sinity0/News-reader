import UIKit
import SafariServices
import CoreData

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var newsDataSource: [News] = []

    private var isRequesting = false
    private let networkManager = NetworkManager()
    private let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retrieveNewsFromProvidedSource),
                                               name: Notification.Name(Constants.notificationKey),
                                               object: nil)
        if !isRegisteredForRemoteNotifications, checkInternetConnection() {
            retrieveNewsFromProvidedSource()
        } else {
            loadSavedNews()
        }
    }

    private func checkInternetConnection() -> Bool {
        do {
            return try Connectivity.isConnectedToInternet()
        } catch let error as AttributedError {
            self.present(self.showAlert(title: error.title,
                                        message: error.description ?? "Something went wrong."), animated: true)
            return false
        } catch {
            self.present(self.showAlert(title: "News reader", message: "Something went wrong."), animated: true)
            return false
        }
    }

    private func loadSavedNews() {
        var fetchedNews: [News] = []
        do {
            fetchedNews = try CoreDataManager.sharedInstance.fetchNews()
        } catch let error as AttributedError {
            self.present(self.showAlert(title: error.title,
                                        message: error.description ?? "Something went wrong."), animated: true)
            return
        } catch {
            self.present(self.showAlert(title: "News reader", message: "Something went wrong."), animated: true)
            return
        }
        newsDataSource.removeAll()
        newsDataSource.append(contentsOf: fetchedNews)
        tableView.reloadData()
    }

    @objc private func retrieveNewsFromProvidedSource() {
        guard !isRequesting else { return }
        isRequesting = true

        networkManager.fetchNews(source: Constants.newsSource, sortBy: sortBy.latest) {[weak self] response -> Void in
            guard let `self` = self else { return }
            self.isRequesting = false

            switch response {
            case .success(let value):
                if !value.isEmpty {
                    var val: [News] = []
                    do {
                        val = try self.parse(data: value)
                    } catch let error as AttributedError {
                        self.present(self.showAlert(title: error.title,
                                                    message: error.description ?? "Something went wrong."), animated: true)
                    } catch {
                        self.present(self.showAlert(title: "News reader", message: "Something went wrong."), animated: true)
                    }
                    self.updateNewsDB(with: val)
                    self.loadSavedNews()
                }
            case .failure(let error):
                self.present(self.showAlert(title: "News reader", message: error.localizedDescription), animated: true)
                self.isRequesting = false
            }
        }
    }

    private func parse(data: [[String: Any]]) throws -> [News] {
        var result: [News] = []

        let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "News", in: managedContext) else {
            throw AttributedError(title: "CoreData", description: "Can't get context")
        }

        for item in data {
            let newsItem = News(entity: entity, insertInto: managedContext)
            if let title = item["title"] as? String,
                let description = item["description"] as? String,
                let url = item["url"] as? String {
                    newsItem.title = title
                    newsItem.descr = description
                    newsItem.url = url
                    result.append(newsItem)
            }
        }
        return result
    }

    public func updateNewsDB(with: [News]) {
        for item in with {
            do {
                try CoreDataManager.sharedInstance.saveNews(data: item)
            } catch let error as AttributedError {
                self.present(self.showAlert(title: error.title,
                                            message: error.description ?? "Something went wrong."), animated: true)
            } catch {
                self.present(self.showAlert(title: "NewsModel reader", message: "Something went wrong."), animated: true)
            }
        }
    }
}

// MARK: - UITableView Delegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let news = newsDataSource[indexPath.row]
        if let urlStr = news.url {
            guard let url = URL(string: urlStr) else { return }
            let webViewController = SFSafariViewController(url: url)
            webViewController.delegate = self
            present(webViewController, animated: true)
        }
    }
}

// MARK: UITableView Data Source
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) else {
            let cell = UITableViewCell()
            return cell
        }

        let news = newsDataSource[indexPath.row]
        cell.textLabel?.text = news.title
        cell.detailTextLabel?.text = news.descr
        return cell
    }
}

// MARK: Safari delegate
extension NewsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}
