import UIKit
import PDFKit

class LectureRatingViewController: UIViewController {
    
    @IBOutlet private var starsView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var textViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc
    private func keyboardWillShow(sender: Notification) {
        let keyboardFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame?.height ?? 0
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        self.scrollView.contentInset = inset
        self.scrollView.scrollIndicatorInsets = inset
        self.scrollView.scrollRectToVisible(CGRect(x: 0, y: self.textViewContainer.frame.maxY, width: 1, height: 1), animated: true)
    }

    @objc
    private func keyboardWillHide(sender: Notification) {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
    
    @IBAction private func starButtonTapped(sender: UIButton) {
        if let selectedIndex = self.starsView.arrangedSubviews.index(of: sender) {
            for (index, star) in self.starsView.arrangedSubviews.enumerated() {
                (star as? UIButton)?.isSelected = index <= selectedIndex
            }
        }
        
        if self.textViewContainer.isHidden == true {
            self.textViewContainer.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.textViewContainer.alpha = 1
            })
        }
    }
    
    @IBAction private func submitFeedback() {
        var ratings = 0
        for button in self.starsView.subviews {
            let isSelected = (button as? UIButton)?.isSelected ?? false
            ratings += isSelected ? 1 : 0
        }
    }
}

extension LectureRatingViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String)
        -> Bool
    {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
