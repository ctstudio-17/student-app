import Foundation
import Mapper

struct Lecture: Mappable {
    let isInProgress: Bool
    var id: String = ""
    
    init(map: Mapper) throws {
        try isInProgress = map.from("in_progress")
    }
}
