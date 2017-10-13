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
            "timeStamp": timeStamp,
            "student": studentId,
        ]

        path.updateChildValues(["\(key)": confusion]) { error, _ in
            completion?(error == nil)
        }
    }
    
    static func observeProgress(forLecture lectureId: String, progressChanged: @escaping (Bool) -> Void)
        -> DatabaseHandle
    {
        let path = API.database.child(Path.lectures.value).child(lectureId).child("in_progress")
        let observer = path.observe(.value) { snapshot in
            let isInProgress = snapshot.value as? Bool ?? false
            progressChanged(isInProgress)
        }

        return observer
    }
    
    static func removeProgressObserver(forLecture lectureId: String, observer: DatabaseHandle) {
        let path = API.database.child(Path.lectures.value).child(lectureId).child("in_progress")
        path.removeObserver(withHandle: observer)
    }
    
    static func rate(lectureId: String, studentId: String, ratings: Int, feedback: String,
                     completion: ((Bool) -> Void)?)
    {
        let path = API.database.child(Path.lectures.value).child(lectureId).child("feedback")
        let key = path.childByAutoId().key
        let feedback: [String: Any] = [
            "content": feedback,
            "rating": ratings,
            "student": studentId
        ]
        
        path.updateChildValues(["\(key)": feedback]) { error, _ in
            completion?(error == nil)
        }
    }
}
