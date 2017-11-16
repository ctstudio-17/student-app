import UIKit

/// Possible states for placeholder view controller
///
/// - loading: Content is loading
/// - notAvailable: Content is not available
enum PlaceholderState {
    case loading
    case notAvailable
}

final class LecturePlaceholderViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    private var state: PlaceholderState = .loading
    private var placeholderTitle: String?

    /// Set the state of the place holder view controller
    ///
    /// - Parameters:
    ///   - state: State to change to
    ///   - title: Title to display
    func set(state: PlaceholderState, title: String?) {
        self.state = state
        self.placeholderTitle = title
        if self.isViewLoaded {
            self.updateUI(with: state, title: title)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI(with: self.state, title: self.placeholderTitle)
    }
    
    private func updateUI(with state: PlaceholderState, title: String?) {
        switch state {
            case .loading:
                self.spinner.startAnimating()
            case .notAvailable:
                self.spinner.stopAnimating()
            }
        
        self.titleLabel.text = title
    }
}
