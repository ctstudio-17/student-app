import UIKit

final class SingleSlideViewController: UIViewController {
    @IBOutlet private var cornerButton: ConfusionButton!
    @IBOutlet fileprivate var imageView: UIImageView!
    
    private var imageURL: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadImage(with: imageURL)
            }
        }
    }
    
    private(set) var slideIndex: Int?
    private var lectureId: String?
    private var courseId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImage(with: self.imageURL)
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(toggleControls))
        self.imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func set(imageURL: URL, slideIndex: Int, lectureId: String, courseId: String) {
        self.imageURL = imageURL
        self.slideIndex = slideIndex
        self.lectureId = lectureId
        self.courseId = courseId
    }
    
    @objc
    private func toggleControls() {
        let isHidden = self.navigationController?.navigationBar.isHidden ?? false
        self.navigationController?.setNavigationBarHidden(!isHidden, animated: true)
    }

    private func loadImage(with URL: URL?) {
        self.imageView.sd_setImage(with: URL) { _, error, _, _ in
            if error != nil {
                print("Error getting images")
            }
        }
    }

    @IBAction private func cornerButtonPressed(sender: ConfusionButton) {
        guard let lectureId = self.lectureId, let courseId = self.courseId else {
            return
        }

        let now = Int(Date().timeIntervalSince1970)
        sender.transition(to: .sending)
        API.sendConfusionSignal(fromStudent: UserManager.currentUserId, aboutSlide: self.slideIndex,
                                toLecture: lectureId, forCourse: courseId, timeStamp: now)
        { [weak sender] isSuccess in
            if !isSuccess {
                sender?.transition(to: .idle)
                return
            }

            sender?.transition(to: .sent)
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                sender?.transition(to: .idle)
            })
        }
    }
    
    @IBAction private func cornerButtonDraggedOutside(sender: ConfusionButton) {
        if self.presentingViewController != nil {
            return
        }

        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "confuseModal"),
            let model = viewController as? ConfuseModalViewController
        {
            model.courseId = self.courseId
            model.lectureId = self.lectureId
            model.slideIndex = self.slideIndex
            model.show(from: self)
        }
    }
}

extension SingleSlideViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
