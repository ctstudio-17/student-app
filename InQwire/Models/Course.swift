import Foundation
import Mapper

struct Course: Mappable {
    let id: String
    let number: String
    let title: String
    let professorId: String?

    init(map: Mapper) throws {
        try id = map.from("id")
        try number = map.from("class_number")
        try title = map.from("class_title")
        professorId = map.optionalFrom("professor")
    }
}
