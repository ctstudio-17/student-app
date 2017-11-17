import UIKit
import SDWebImage
import Firebase

final class SlidesPageViewController: UIPageViewController {
    
    /// Course to populate UI with
    var course: Course? {
        didSet {
            if (self.isViewLoaded) {
                self.getLatestLecture()
                self.title = self.course?.number
            }
        }
    }
    
    private var imageURLs: [URL]?
    private var lecture: Lecture?
    private var lectureProgressObserver: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.showPlaceholder(withState: .loading, title: "Loading lecture")
        self.getLatestLecture()
        self.title = self.course?.number
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = self.lectureProgressObserver, let lectureId = self.lecture?.id,
            let courseId = self.course?.id
        {
            API.removeProgressObserver(forLecture: lectureId, ofCourse: courseId, observer: observer)
            self.lectureProgressObserver = nil
        }
    }
    
    private func getLatestLecture() {
        guard let courseId = self.course?.id else {
            return self.showPlaceholder(withState: .notAvailable,
                                        title: "Error getting lecture, please try again later")
        }
        
        API.getLatestLecture(forCourse: courseId) { [weak self] lecture in
            guard let lecture = lecture, lecture.isInProgress == true else {
                self?.showPlaceholder(withState: .notAvailable,
                                      title: "No new lecture, please come back later")
                return
            }
            
            self?.lecture = lecture
            self?.observe(lectureId: lecture.id, courseId: courseId)
            if let presentation = lecture.presentation {
                self?.show(presentation: presentation)
            }
        }
    }
    
    private func observe(lectureId: String, courseId: String) {
        self.lectureProgressObserver = API.observeProgress(ofLecture: lectureId,
                                                           fromCourse: courseId,
                                                           progressChanged:
        { [weak self] isInProgress in
            if isInProgress {
                return
            }
            
            if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "feedbackTable"),
                let feedback = viewController as? FeedbackTableViewController
            {
                feedback.course = self?.course
                feedback.lectureId = lectureId
                self?.show(feedback, sender: nil)
            }
        })
    }
    
    private func show(presentation: Presentation) {
        self.imageURLs = presentation.images
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleSlide")
        if let firstViewController = viewController as? SingleSlideViewController,
            let imageURL = self.imageURLs?.first, let lectureId = self.lecture?.id,
            let courseId = self.course?.id
        {
            firstViewController.set(imageURL: imageURL, slideIndex: 0, lectureId: lectureId,
                                    courseId: courseId)
            self.setViewControllers([firstViewController], direction: .forward, animated: false)
        }
    }
    
    private func showPlaceholder(withState state: PlaceholderState = .loading, title: String?) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "placeholder"),
            let placeholder = viewController as? LecturePlaceholderViewController else
        {
            return
        }
        
        placeholder.set(state: state, title: title)
        self.setViewControllers([placeholder], direction: .forward, animated: false)
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
        guard let currentIndex = (currentViewController as? SingleSlideViewController)?.slideIndex else {
            return nil
        }
        
        let nextIndex = currentIndex + (direction == .forward ? 1 : -1)
        if nextIndex >= self.imageURLs?.count ?? 0 || nextIndex < 0 {
            return nil
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleSlide")
        if let imageURL = self.imageURLs?[nextIndex], let lectureId = self.lecture?.id,
            let courseId = self.course?.id
        {
            (viewController as? SingleSlideViewController)?.set(imageURL: imageURL, slideIndex: nextIndex,
                                                                lectureId: lectureId, courseId: courseId)
        }

        return viewController
    }
}
