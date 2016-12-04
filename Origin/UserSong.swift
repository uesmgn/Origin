import RealmSwift

class UserSong: Object {
    dynamic var itunesId = 0
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var album = ""
    dynamic var artwork:Data? = nil
    dynamic var trackSource = ""
    dynamic var rating = 0
    dynamic var isKnown = 0
    override static func primaryKey() -> String? {
        return "itunesId"
    }
}
