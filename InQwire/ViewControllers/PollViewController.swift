import UIKit

private let kCellIdentifier = "kPollCell"

private enum Section: Int {
    case question
    case options
    
    var section: Int {
        return self.rawValue
    }
    
    static var all: [Section] {
        return [.question, .options]
    }
}

final class PollViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var headerView: UIView!
    
    fileprivate var poll: Poll? {
        didSet {
            self.selectedIndexPath = nil
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate var selectedIndexPath: IndexPath?

    var lectureId: String?
    var courseId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getPoll), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.beginRefreshing()
        self.getPoll()
    }
    
    @objc
    private func getPoll() {
        guard let lectureId = self.lectureId, let courseId = self.courseId else {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.tableHeaderView = self.headerView
            self.tableView.tableFooterView?.isHidden = true
            return
        }

        API.getCurrentPoll(forLecture: lectureId, courseId: courseId, completion: { [weak self] poll in
            self?.tableView.refreshControl?.endRefreshing()
            if poll == nil {
                self?.tableView.tableHeaderView = self?.headerView
                self?.tableView.tableFooterView?.isHidden = true
            } else {
                self?.tableView.tableHeaderView = nil
                self?.tableView.tableFooterView?.isHidden = false
            }

            self?.poll = poll
        })
    }
    
    @IBAction private func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func submit(sender: SendButton) {
        guard let poll = self.poll, let lectureId = self.lectureId, let courseId = self.courseId,
            let response = self.selectedIndexPath?.row else
        {
            return
        }

        sender.sendState = .sending
        API.submitResponse(toPoll: poll.id, response: response, from: UserManager.currentUserId,
                           lectureId: lectureId, courseId: courseId)
        { [weak self, weak sender] isSuccess in
            if !isSuccess {
                sender?.sendState = .sentFailure
                return
            }
            
            sender?.sendState = .sentSuccess
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self?.dismiss(animated: true, completion: nil)
            })
        }
    }
}

extension PollViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.question.section:
                return self.poll?.question == nil ? 0 : 1
            case Section.options.section:
                return self.poll?.options.count ?? 0
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: kCellIdentifier)
        switch indexPath.section {
            case Section.question.section:
                cell.textLabel?.text = self.poll?.question
                cell.accessoryType = .none
            case Section.options.section:
                cell.textLabel?.text = self.poll?.options[indexPath.row]
                cell.accessoryType = indexPath == self.selectedIndexPath ? .checkmark : .none
            default:
                break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.poll == nil {
            return nil
        }

        switch section {
            case Section.question.section:
                return "Question"
            case Section.options.section:
                return "Select one of the following"
            default:
                return ""
        }
    }
}

extension PollViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == Section.question.section {
            return
        }
        
        self.selectedIndexPath = indexPath
        tableView.reloadData()
    }
}
