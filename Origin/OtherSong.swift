import RealmSwift

class OtherSong: Object {
    dynamic var itunesId = 0
    dynamic var title = ""
    dynamic var artistName = ""
    dynamic var artistUrl = ""
    dynamic var albumTitle = ""
    dynamic var artwork = ""
    dynamic var trackSource = ""
    dynamic var genre = "1"
    dynamic var rating = 0
    dynamic var isKnown = 0
    override static func primaryKey() -> String? {
        return "itunesId"
    }
}

