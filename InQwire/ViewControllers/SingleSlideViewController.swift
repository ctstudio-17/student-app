import UIKit

final class SingleSlideViewController: UIViewController {
    
    @IBOutlet private var cornerButton: UIButton!
    @IBOutlet fileprivate var imageView: UIImageView!
    
    private var imageURL: URL? {
        didSet {
            if self.isViewLoaded {
                self.loadImage(with: imageURL)
            }
        }
    }
    
    private(set) var index: Int?
    private var lectureId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImage(with: self.imageURL)
    }
    
    func set(imageURL: URL, slideIndex: Int, lectureId: String) {
        self.imageURL = imageURL
        self.index = slideIndex
        self.lectureId = lectureId
    }
    
    private func loadImage(with URL: URL?) {
        self.imageView.sd_setImage(with: URL) { _, error, _, _ in
            if error != nil {
                print("Error getting images")
            }
        }
    }
    
    @IBAction private func cornerButtonPressed(sender: UIButton) {
        guard let lectureId = self.lectureId else {
            return
        }
        
        API.sendConfusionSignal(lectureId: lectureId, studentId: UserManager.currentUserId,
                                timeStamp: Int(Date().timeIntervalSince1970), completion:
        { isSuccess in
                
        })
    }
}

extension SingleSlideViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
