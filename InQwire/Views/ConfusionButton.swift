import UIKit
import SnapKit

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
        self.addSubview(spinner)
        spinner.snp.makeConstraints { $0.center.equalToSuperview() }
        self.spinner = spinner
        self.layoutIfNeeded()
    }
    
    func transition(to state: ConfusionButtonState) {
        switch state {
            case .idle:
                self.isUserInteractionEnabled = true
                self.spinner?.stopAnimating()
                self.titleLabel?.alpha = 0
                self.setTitle(self.idleTitle, for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
                self.titleLabel?.fadeIn()
            case .sending:
                self.titleLabel?.fadeOut()
                self.isUserInteractionEnabled = false
                self.spinner?.startAnimating()
            case .sent:
                self.isUserInteractionEnabled = false
                self.titleLabel?.alpha = 0
                self.spinner?.stopAnimating()
                self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                self.setTitle(self.sentTitle, for: .normal)
                self.titleLabel?.fadeIn()
        }
    }
}
