import UIKit

final class StarsView: UIStackView {

    /// Return number of stars selected
    var numberOfStarsSelected: Int {
        var count = 0
        for button in self.arrangedSubviews {
            let isSelected = (button as? UIButton)?.isSelected ?? false
            count += isSelected ? 1 : 0
        }
        
        return count
    }
    
    var starsSelectionDidChange: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for star in self.arrangedSubviews {
            (star as? UIButton)?.addTarget(self, action: #selector(starButtonPressed),
                for: .touchUpInside)
        }
    }

    @objc private func starButtonPressed(sender: UIButton) {
        guard let selectedIndex = self.arrangedSubviews.index(of: sender) else {
            return
        }

        for (index, star) in self.arrangedSubviews.enumerated() {
            (star as? UIButton)?.isSelected = index <= selectedIndex
        }
        
        self.starsSelectionDidChange?()
    }
}
