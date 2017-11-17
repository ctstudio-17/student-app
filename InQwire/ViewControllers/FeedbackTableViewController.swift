import UIKit

enum FeedbackStep: Int {
    case understanding = 1
    case pace
    case engagement
    case comments
    
    /// Represent raw value
    var value: Int {
        return self.rawValue
    }
    
    /// Represent table view cell row
    var row: Int {
        return self.value - 1
    }
}

final class FeedbackTableViewController: UITableViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var topStarsView: StarsView!
    @IBOutlet private var bottomStarsView: StarsView!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var footerView: UIView!
    
    var lectureId: String?
    var course: Course? {
        didSet {
            if self.isViewLoaded {
                self.titleLabel.text = (self.course?.number ?? "") + " " + (self.course?.title ?? "")
            }
        }
    }
    
    private var currentFeedbackStep: FeedbackStep = .understanding

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = (self.course?.number ?? "") + " " + (self.course?.title ?? "")
        self.topStarsView.starsSelectionDidChange = { [weak self] in
            self?.showNextCellIfNeeded(from: .understanding)
        }
        
        self.bottomStarsView.starsSelectionDidChange = { [weak self] in
            self?.showNextCellIfNeeded(from: .engagement)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentFeedbackStep.value
    }
    
    private func showNextCellIfNeeded(from step: FeedbackStep) {
        if step.value < self.currentFeedbackStep.value {
            return
        }
        
        guard let step = FeedbackStep(rawValue: self.currentFeedbackStep.value + 1) else {
            return
        }

        self.currentFeedbackStep = step
        self.tableView.reloadData()
        let indexPath = IndexPath(row: step.row, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        if step == .comments {
            self.footerView.fadeIn()
        }
    }
    
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.showNextCellIfNeeded(from: .pace)
    }

    @IBAction private func close() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func submitFeedback(sender: SendButton) {
        guard let lectureId = self.lectureId, let courseId = self.course?.id else {
            return
        }

        sender.sendState = .sending
        API.rate(lectureId: lectureId, from: UserManager.currentUserId, courseId: courseId,
                 understanding: self.topStarsView.numberOfStarsSelected,
                 pace: self.segmentedControl.selectedSegmentIndex + 1,
                 engagement: self.bottomStarsView.numberOfStarsSelected,
                 comments: self.textView.text)
        { [weak self, weak sender] isSuccess in
            if !isSuccess {
                sender?.sendState = .sentFailure
                return
            }
            
            sender?.sendState = .sentSuccess
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self?.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
}

extension FeedbackTableViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String)
        -> Bool
    {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
