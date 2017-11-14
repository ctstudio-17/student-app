import UIKit
import Firebase

final class InLectureViewController: UIViewController {
    private var lectureProgressObserver: DatabaseHandle?
    @IBOutlet private var confuseButton: UIButton!
    
    /// Course this lecture belongs to
    var courseId: String?
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lectureProgressObserver = API.observeProgress(forLecture: "1") { [weak self] isInProgress in
            if isInProgress {
                return
            }

            if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "feedback") {
                self?.show(viewController, sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = self.lectureProgressObserver {
            API.removeProgressObserver(forLecture: "1", observer: observer)
        }
    }
        
    @IBAction private func confused() {}
}
