import Foundation
import Mapper

enum UserType: String {
    case student
    case professor
}

struct User: Mappable {
    let firstName: String
    let lastName: String
    let type: UserType
    
    init(map: Mapper) throws {
        try firstName = map.from("first_name")
        try lastName = map.from("last_name")
        try type = map.from("type")
    }
}
