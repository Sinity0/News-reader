import UIKit
import SafariServices
import CoreData

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var newsDataSource: [NewsModel] = []

    fileprivate var isRequesting = false
    private let networkManager = NetworkManager()
    private let coreDataManager = CoreDataManager()
    private let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications

    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retrieveNewsFromProvidedSource),
                                               name: Notification.Name(Constants.notificationKey),
                                               object: nil)

        if isRegisteredForRemoteNotifications {
            loadSavedNews()
        } else {
            retrieveNewsFromProvidedSource()
        }
    }

    public func loadSavedNews() {

        let news: [NewsModel] = coreDataManager.fetchNews().flatMap {
            if let title = $0.value(forKey: "title") as? String,
                let description = $0.value(forKey: "descr") as? String,
                let url = $0.value(forKey: "url") as? String {
                return NewsModel(title: title,
                                 description: description,
                                 url: url)
            }
            return nil
        }
        newsDataSource.append(contentsOf: news)
    }

    @objc private func retrieveNewsFromProvidedSource() {

        guard !isRequesting else { return }
        isRequesting = true

        networkManager.fetchNews(source: Constants.newsSource, sortBy: "latest") {[weak self] response -> Void in
            guard let `self` = self else { return }
            self.isRequesting = false

            switch response {
            case .success(let value):
                self.newsDataSource.removeAll()
                if value.count > 0 {
                    self.newsDataSource.append(contentsOf: value)
                }
                self.tableView.reloadData()
                self.updateNewsDB()
            case .failure(let error):
                self.present(self.showAlert(title: "News reader", message: error.localizedDescription), animated: true, completion: nil)
                self.isRequesting = false
            }
        }
    }

    func updateNewsDB() {

        coreDataManager.deleteOldRecords()

        for item in newsDataSource {
            guard let title = item.title, let description = item.description, let url = item.url else { return }
            coreDataManager.saveNews(title: title, description: description, url: url)
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
            present(webViewController, animated: true, completion: nil)
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
        cell.detailTextLabel?.text = news.description
        return cell
    }
}

// MARK: Safari delegate
extension NewsViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
