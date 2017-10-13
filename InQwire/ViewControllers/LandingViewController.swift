import UIKit

final class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        API.getAllCourses { courses in
            print(courses)
        }
    }
}
