import Foundation
import Mapper

struct Course: Mappable {
    let number: String
    let professorId: String
    let lectureIds: [Int]

    init(map: Mapper) throws {
        try number = map.from("class_number")
        try lectureIds = map.from("lectures")
        try professorId = map.from("professor")
    }
}
