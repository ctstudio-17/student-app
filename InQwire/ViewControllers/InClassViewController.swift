import UIKit

final class InClassViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func confused() {
        API.sendConfusionSignal(lectureId: "1", studentId: "fp73", timeStamp: 0, completion: nil)
    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
