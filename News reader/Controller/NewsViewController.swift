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

}

// MARK: UITableView Data Source
extension NewsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = newsDataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as UITableViewCell!
        return cell!
    }

}

// MARK: Safari delegate
extension NewsViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

