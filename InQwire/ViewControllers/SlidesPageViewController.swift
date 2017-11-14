import UIKit

final class SlidesPageViewController: UIPageViewController {
    
    /// The ID of this course
    var courseId: String? {
        didSet {
            if (self.isViewLoaded) {
                self.getLatestLecture()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.getLatestLecture()
    }
    
    private func getLatestLecture() {
        guard let courseId = self.courseId else {
            return
        }
        
        API.getLatestLecture(forCourse: courseId) { lecture in
            let showPlaceholder = {}
            guard let lecture = lecture, lecture.isInProgress == true else {
                return showPlaceholder()
            }

            
        }
    }
    
    
}

// MARK: - UIPageViewControllerDataSource
extension SlidesPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        return nil
    }
}
