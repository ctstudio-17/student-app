import UIKit
import SnapKit

final class ConfuseModalViewController: UIViewController {
    @IBOutlet private var dimmerView: UIView!
    @IBOutlet private var modalView: UIView!
    @IBOutlet private var textView: UITextView!
    @IBOutlet fileprivate var placeholderLabel: UILabel!
    @IBOutlet fileprivate var sendButton: SendButton!
    
    var lectureId: String?
    var courseId: String?
    var slideIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dimmerView.alpha = 0
        self.modalView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.top.equalTo(self.view.snp.bottom)
            make.height.equalTo(180)
        }
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(cancel))
        self.dimmerView.addGestureRecognizer(gestureRecognizer)
        self.sendButton.toggleEnabledAppearance(isEnabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)),
                                               name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func show(from presentingViewController: UIViewController) {
        presentingViewController.present(self, animated: false) {
            self.textView.becomeFirstResponder()
        }
    }
    
    @objc
    private func cancel() {
        self.textView.resignFirstResponder()
        self.dimmerView.fadeOut(duration: 0.2) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc
    private func dismissViewController() {
        self.textView.resignFirstResponder()
        self.modalView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.top.equalTo(self.view.snp.bottom)
            make.height.equalTo(self.modalView.bounds.height)
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.dimmerView.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc
    private func keyboardWillShow(sender: Notification) {
        let keyboardFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let availabelHeight = self.view.bounds.height - (keyboardFrame?.height ?? 0)
        let centerY = availabelHeight / 2
        self.modalView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalTo(centerY)
            make.height.equalTo(max(availabelHeight / 2, 120))
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
            self.dimmerView.alpha = 1
        }
    }
    
    @IBAction private func send(sender: SendButton) {
        guard let lectureId = self.lectureId, let courseId = self.courseId else {
            return self.cancel()
        }
        
        let now = Int(Date().timeIntervalSince1970)
        sender.sendState = .sending
        API.sendConfusionSignal(fromStudent: UserManager.currentUserId, aboutSlide: self.slideIndex,
                                withComment: self.textView.text, toLecture: lectureId, forCourse: courseId,
                                timeStamp: now, completion:
        { [weak self, weak sender] isSuccess in
            if !isSuccess {
                sender?.sendState = .sentFailure
                return
            }
            
            sender?.sendState = .sentSuccess
            if let strongSelf = self {
                Timer.scheduledTimer(timeInterval: 1.5, target: strongSelf,
                                     selector: #selector(strongSelf.dismissViewController), userInfo: nil,
                                     repeats: false)
            }
        })
    }
}

extension ConfuseModalViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String)
        -> Bool
    {
        if text.isEmpty && textView.text.count <= 1 {
            self.placeholderLabel.isHidden = false
            self.sendButton.toggleEnabledAppearance(isEnabled: false)
        } else {
            self.placeholderLabel.isHidden = true
            self.sendButton.toggleEnabledAppearance(isEnabled: true)
        }
        
        return true
    }
}
