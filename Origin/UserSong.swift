import RealmSwift

class UserSong: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var album = ""
    dynamic var artwork:Data?
    dynamic var trackSource = ""
    dynamic var rating = 0
    dynamic var isKnown = 0
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Album: Object {
    dynamic var id = ""
    dynamic var artwork:Data?
    dynamic var albumTitle = ""
    dynamic var artistName = ""
    let songs = List<UserSong>()
}

class Artist: Object {
    dynamic var id = ""
    dynamic var artwork:Data?
    dynamic var artistName = ""
    var albums = List<Album>()
}

