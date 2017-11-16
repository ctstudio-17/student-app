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
                guard let snapshot = child as? DataSnapshot, let value = snapshot.value as? NSDictionary else
                {
                    return
                }
                
                value.setValue(snapshot.key, forKey: "id")
                if let course = Course.from(value) {
                    courses.append(course)
                }
            }

            completion(courses)
        }
    }
    
    /// Get latest lecture data
    ///
    /// - Parameters:
    ///   - courseId: Course this lecture belongs to
    ///   - completion: Closure called upon completion
    static func getLatestLecture(forCourse courseId: String, completion: @escaping (Lecture?) -> Void) {
        API.database.child(Path.courses.value).child(courseId).child(Path.lectures.value)
            .queryLimited(toLast: 1).observeSingleEvent(of: .value)
        { data in
            guard let value = data.value as? NSDictionary,
                let lectureId = value.allKeys.first as? String,
                let lectureData = value.value(forKey: lectureId) as? NSDictionary else
            {
                return completion(nil)
            }
        
            lectureData.setValue(lectureId, forKey: "id")
            guard let presentation = lectureData.value(forKey: "presentation") as? NSDictionary,
                let slides = presentation.value(forKey: "slides") as? NSArray else
            {
                return completion(Lecture.from(lectureData))
            }
            
            var imageURLs = [String]()
            for slide in slides {
                if let UrlString = (slide as? NSDictionary)?.value(forKey: "thumbnailUrl") as? String {
                    imageURLs.append(UrlString)
                }
            }
            
            presentation.setValue(imageURLs, forKey: "images")
            return completion(Lecture.from(lectureData))
        }
    }
    
    static func sendConfusionSignal(fromStudent studentId: String, aboutSlide slideNumber: Int? = nil,
                                    withComment comment: String? = nil, toLecture lectureId: String,
                                    forCourse courseId: String, timeStamp: Int, completion: ((Bool) -> Void)?)
    {
        let path = API.database.child(Path.courses.value).child(courseId).child(Path.lectures.value)
            .child(lectureId).child(Path.confusions.value)
        var value: [String: Any] = [
            "timeStamp": timeStamp,
            "student": studentId,
        ]
        
        value["slide_number"] = slideNumber
        value["comment"] = comment
        let key = path.childByAutoId().key
        path.updateChildValues([key: value]) { error, _ in
            completion?(error == nil)
        }
    }
    
    static func observeProgress(ofLecture lectureId: String, fromCourse courseId: String,
                                progressChanged: @escaping (Bool) -> Void)
        -> DatabaseHandle
    {
        let path = API.database.child(Path.courses.value).child(courseId).child(Path.lectures.value)
            .child(lectureId).child("in_progress")
        let observer = path.observe(.value) { snapshot in
            let isInProgress = snapshot.value as? Bool ?? false
            progressChanged(isInProgress)
        }

        return observer
    }
    
    static func removeProgressObserver(forLecture lectureId: String, ofCourse courseId: String,
                                       observer: DatabaseHandle)
    {
        let path = API.database.child(Path.courses.value).child(courseId).child(Path.lectures.value)
            .child(lectureId).child("in_progress")
        path.removeObserver(withHandle: observer)
    }
    
    static func rate(lectureId: String, from studentId: String, courseId: String, ratings: Int,
                     feedback: String, completion: ((Bool) -> Void)?)
    {
        let path = API.database.child(Path.courses.value).child(courseId).child(Path.lectures.value)
            .child(lectureId).child("feedback")
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
