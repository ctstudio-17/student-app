import UIKit

private let kCellIdentifier = "courseCell"

final class CourseListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    
    fileprivate var courses = [Course]() {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCourses()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getCourses(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc
    private func getCourses(_ refreshControl: UIRefreshControl? = nil) {
        API.getAllCourses { [weak self, refreshControl] courses in
            self?.courses = courses
            self?.spinner.stopAnimating()
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension CourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as? CourseTableViewCell ??
            CourseTableViewCell()
        cell.populate(from: self.courses[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CourseListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "slidesPage")
        guard let pageViewController = viewController as? SlidesPageViewController else {
            return
        }
        
        pageViewController.course = self.courses[indexPath.row]
        self.show(pageViewController, sender: nil)
    }
}
