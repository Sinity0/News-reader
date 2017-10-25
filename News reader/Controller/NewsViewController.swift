import UIKit
import SafariServices

class NewsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    fileprivate var newsDataSource: [NewsModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
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

