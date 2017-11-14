import UIKit
import Firebase

final class InLectureViewController: UIViewController {
    private var lectureProgressObserver: DatabaseHandle?
    @IBOutlet private var confuseButton: UIButton!
    
    /// Course this lecture belongs to
    var courseId: String?
    
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
    
    private func randomStudentId() -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyz"
        let length = UInt32(3)
        var randomString = ""
        for _ in 0 ..< length {
            var nextChar = letters.character(at: Int(arc4random_uniform(length)))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        randomString += String(Int(arc4random_uniform(100)))
        return randomString
    }
    
    @IBAction private func confused() {
        let time = Int(Date().timeIntervalSince1970)
        API.sendConfusionSignal(lectureId: "1", studentId: self.randomStudentId(), timeStamp: time,
                                completion: nil)
    }
}
