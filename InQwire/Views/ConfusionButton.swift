import UIKit

enum ConfusionButtonState {
    case idle
    case sending
    case sent
}

final class ConfusionButton: UIButton {

    private var spinner: UIActivityIndicatorView?
    @IBInspectable private var idleTitle: String?
    @IBInspectable private var sentTitle: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        spinner.center = CGPoint.init(x: self.bounds.width / 2, y: self.bounds.height / 2)
        self.addSubview(spinner)
        self.spinner = spinner
    }
    
    func transition(to state: ConfusionButtonState) {
        switch state {
            case .idle:
                self.isUserInteractionEnabled = true
                self.spinner?.stopAnimating()
                self.titleLabel?.alpha = 0
                self.setTitle(self.idleTitle, for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                self.titleLabel?.fadeIn()
            case .sending:
                self.titleLabel?.fadeOut()
                self.isUserInteractionEnabled = false
                self.spinner?.startAnimating()
            case .sent:
                self.isUserInteractionEnabled = false
                self.titleLabel?.alpha = 0
                self.spinner?.stopAnimating()
                self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                self.setTitle(self.sentTitle, for: .normal)
                self.titleLabel?.fadeIn()
        }
    }
}
