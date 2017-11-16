import UIKit

enum SendButtonState {
    case idle
    case sending
    case sentSuccess
    case sentFailure
}

final class SendButton: UIButton {

    @IBInspectable private var defaultColor: UIColor?
    @IBInspectable private var successColor: UIColor?
    @IBInspectable private var failureColor: UIColor?
    @IBInspectable private var defaultTitle: String?
    @IBInspectable private var successTitle: String?
    @IBInspectable private var failureTitle: String?
    private var spinner: UIActivityIndicatorView?
    
    /// Button's current state
    var sendState: SendButtonState = .idle {
        didSet {
            self.set(state: self.sendState)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.hidesWhenStopped = true
        spinner.center = CGPoint.init(x: self.bounds.width / 2, y: self.bounds.height / 2)
        self.addSubview(spinner)
        self.spinner = spinner
    }
    
    func toggleEnabledAppearance(isEnabled: Bool) {
        self.titleLabel?.alpha = isEnabled ? 1 : 0.4
        self.isUserInteractionEnabled = isEnabled
    }
    
    private func set(state: SendButtonState) {
        switch state {
            case .idle:
                self.setTitle(self.defaultTitle, for: .normal)
                self.backgroundColor = self.defaultColor
                self.spinner?.stopAnimating()
                self.isUserInteractionEnabled = true
            case .sending:
                self.setTitle(nil, for: .normal)
                self.backgroundColor = self.defaultColor
                self.spinner?.startAnimating()
                self.isUserInteractionEnabled = false
            case .sentFailure:
                self.setTitle(self.failureTitle, for: .normal)
                self.backgroundColor = self.failureColor
                self.spinner?.stopAnimating()
                self.isUserInteractionEnabled = true
            case .sentSuccess:
                self.setTitle(self.successTitle, for: .normal)
                self.backgroundColor = self.successColor
                self.spinner?.stopAnimating()
                self.isUserInteractionEnabled = false
        }
    }
}
