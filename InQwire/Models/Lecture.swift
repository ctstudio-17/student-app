import Foundation
import Mapper

struct Lecture: Mappable {
    let id: String
    let isInProgress: Bool
    let presentation: Presentation?
    
    init(map: Mapper) throws {
        try id = map.from("id")
        try isInProgress = map.from("in_progress")
        presentation = map.optionalFrom("presentation")
    }
}

struct Presentation: Mappable {
    let currentImage: Int
    let title: String?
    let images: [URL]
    
    init(map: Mapper) throws {
        try currentImage = map.from("currentPage")
        try images = map.from("images")
        title = map.optionalFrom("name")
    }
}
