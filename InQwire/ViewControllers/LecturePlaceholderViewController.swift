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

    /// Set the state of the place holder view controller
    ///
    /// - Parameters:
    ///   - state: State to change to
    ///   - title: Title to display
    func set(state: PlaceholderState, title: String?) {
        if !self.isViewLoaded {
            return
        }

        switch state {
            case .loading:
                self.spinner.startAnimating()
            case .notAvailable:
                self.spinner.startAnimating()
        }
        
        self.titleLabel.text = title
    }
}
