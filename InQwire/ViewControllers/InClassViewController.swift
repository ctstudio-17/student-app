import UIKit
import Firebase

final class InClassViewController: UIViewController {
    private var lectureProgressObserver: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    @IBAction private func confused() {
        let time = Int(Date().timeIntervalSince1970)
        API.sendConfusionSignal(lectureId: "1", studentId: "fp73", timeStamp: time, completion: nil)
    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
