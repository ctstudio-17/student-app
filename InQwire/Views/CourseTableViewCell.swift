import UIKit

final class CourseTableViewCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    /// Populate cell's UI with a course
    ///
    /// - Parameter course: Course to populate the cell's UI with
    func populate(from course: Course) {
        self.titleLabel.text = course.number
        self.subtitleLabel.text = course.title
    }
}
