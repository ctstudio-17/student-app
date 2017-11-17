import Foundation
import Mapper

struct Poll: Mappable {
    let id: String
    let question: String
    let options: [String]
    let isActive: Bool
    
    init(map: Mapper) throws {
        try id = map.from("id")
        try question = map.from("questionText")
        try options = map.from("answers")
        try isActive = map.from("isActive")
    }
}
