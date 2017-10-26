import UIKit
import SafariServices
import CoreData

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var newsDataSource: [NewsModel] = []

    fileprivate var isRequesting = false
    private let networkManager = NetworkManager()
    private let coreDataManager = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveNews()
    }

    func retrieveNews() {
        guard !isRequesting else { return }
        isRequesting = true

        networkManager.fetchNews(source: "engadget", sortBy: "latest") {[weak self] response -> Void in
            guard let `self` = self else { return }

            switch response {
            case .success(let value):
                if value.count > 0 {
                    self.newsDataSource.append(contentsOf: value)
                }
                self.updateNewsDB()
                self.tableView.reloadData()
                self.isRequesting = false
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
            do {
                try coreDataManager.saveNews(title: title, description: description, url: url)
            } catch let error as CustomError {
                self.present(self.showAlert(title: error.title, message: error.localizedDescription), animated: true, completion: nil)
            } catch let error {
                self.present(self.showAlert(title: "News reader", message: error.localizedDescription), animated: true, completion: nil)
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

