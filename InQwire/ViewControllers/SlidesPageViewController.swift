import UIKit
import SDWebImage

final class SlidesPageViewController: UIPageViewController {
    
    /// The ID of this course
    var courseId: String? {
        didSet {
            if (self.isViewLoaded) {
                self.getLatestLecture()
            }
        }
    }
    
    private var imageURLs: [URL]?
    private var lecture: Lecture?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.getLatestLecture()
    }
    
    private func getLatestLecture() {
        guard let courseId = self.courseId else {
            return
        }
        
        API.getLatestLecture(forCourse: courseId) { [weak self] lecture in
            let showPlaceholder = {}
            guard let lecture = lecture, lecture.isInProgress == true else {
                return showPlaceholder()
            }
            
            self?.lecture = lecture
            if let presentation = lecture.presentation {
                self?.show(presentation: presentation)
            } else {
                // Show timer
            }
        }
    }
    
    private func show(presentation: Presentation) {
        self.imageURLs = presentation.images
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleSlide")
        if let firstViewController = viewController as? SingleSlideViewController,
            let imageURL = self.imageURLs?.first, let lectureId = self.lecture?.id
        {
            firstViewController.set(imageURL: imageURL, slideIndex: 0, lectureId: lectureId)
            self.setViewControllers([firstViewController], direction: .forward, animated: false)
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension SlidesPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        return nextViewController(forDirection: .reverse, currentViewController: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        return nextViewController(forDirection: .forward, currentViewController: viewController)
    }
    
    private func nextViewController(forDirection direction: UIPageViewControllerNavigationDirection,
                                    currentViewController: UIViewController) -> UIViewController?
    {
        guard let currentIndex = (currentViewController as? SingleSlideViewController)?.index else {
            return nil
        }
        
        let nextIndex = currentIndex + (direction == .forward ? 1 : -1)
        if nextIndex >= self.imageURLs?.count ?? 0 || nextIndex < 0 {
            return nil
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleSlide")
        if let imageURL = self.imageURLs?[nextIndex], let lectureId = self.lecture?.id {
            (viewController as? SingleSlideViewController)?.set(imageURL: imageURL, slideIndex: nextIndex,
                                                                lectureId: lectureId)
        }

        return viewController
    }
}
