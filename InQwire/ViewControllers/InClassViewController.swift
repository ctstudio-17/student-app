import UIKit

final class InClassViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
