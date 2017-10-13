import Foundation
import Firebase

private enum Path: String {
    case courses = "classes"
    case users
    case lectures
    case confusions
    var value: String { return self.rawValue }
}

struct API {
    private static var database = Database.database().reference()

    /// Get all courses
    ///
    /// - Parameter completion: Closure called upon completion
    static func getAllCourses(completion: @escaping ([Course]) -> Void) {
        API.database.child(Path.courses.value).observeSingleEvent(of: .value) { data in
            var courses: [Course] = []
            for child in data.children {
                if let snapshot = child as? DataSnapshot,
                    let value = snapshot.value as? NSDictionary,
                    let course = Course.from(value)
                {
                    courses.append(course)
                }
            }

            completion(courses)
        }
    }
    
    static func sendConfusionSignal(lectureId: String, studentId: String, timeStamp: Int,
                                    completion: ((Bool) -> Void)?)
    {
        let path = API.database.child(Path.lectures.value).child(lectureId).child(Path.confusions.value)
        let key = path.childByAutoId().key
        let confusion: [String: Any] = [
            "timeStamp": 1234,
            "student": studentId,
        ]

        path.updateChildValues(["\(key)": confusion])
    }
}
